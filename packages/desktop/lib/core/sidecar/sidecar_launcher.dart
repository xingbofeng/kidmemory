import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'sidecar_api.dart';
import '../../../l10n/app_localizations.dart';

typedef ExecutableFinder = String? Function(String name);

class SidecarLauncher {
  const SidecarLauncher({
    required this.api,
    required this.findExecutable,
    required this.ensureNodeAvailable,
    required this.onLog,
    this.onReadinessMessage,
    this.extraEnvironment,
  });

  final SidecarApi api;
  final ExecutableFinder findExecutable;
  final Future<bool> Function() ensureNodeAvailable;
  final void Function(String message) onLog;
  final void Function(String message)? onReadinessMessage;
  final Map<String, String> Function()? extraEnvironment;

  Future<bool> ensureRunning({bool forceRestart = false}) async {
    // In test environments the sidecar API is mocked; never attempt
    // socket connection or process launch (both block FakeAsync).
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      onLog(AppLocalizations.of(context)!.sidecarLauncherS679);
      return true;
    }

    if (forceRestart) {
      await _terminateProcessesOnSidecarPort();
    } else if (await apiReady()) {
      return true;
    }
    if (await _sidecarReachable()) {
      onLog(AppLocalizations.of(context)!.sidecarLauncherS98);
      return false;
    }

    final sidecarDir = _resolveSidecarDirectory();
    if (sidecarDir == null) {
      onLog(AppLocalizations.of(context)!.sidecarLauncherS584);
      return false;
    }

    onLog(AppLocalizations.of(context)!.sidecarLauncherS146);
    onReadinessMessage?.call(AppLocalizations.of(context)!.sidecarLauncherS141);
    if (!await ensureNodeAvailable()) return false;
    final node = _bundledNodePath(sidecarDir) ?? findExecutable('node');
    if (node == null) {
      onLog(AppLocalizations.of(context)!.sidecarLauncherS592);
      return false;
    }

    final launch = _resolveSidecarLaunchCommand(
      sidecarDir,
      nodeExecutable: node,
    );
    if (launch == null) {
      onLog(AppLocalizations.of(context)!.sidecarLauncherS591);
      return false;
    }

    try {
      onLog('启动 sidecar 命令：${launch.$1} ${launch.$2.join(' ')}');
      final launchEnv = buildSidecarLaunchEnvironment(
        platformEnv: Platform.environment,
        extraEnvironment: extraEnvironment?.call(),
      );
      if (_requiresStripTypes(launch.$2)) {
        final existingNodeOptions = launchEnv['NODE_OPTIONS']?.trim();
        final stripFlag = '--experimental-strip-types';
        if (existingNodeOptions == null || existingNodeOptions.isEmpty) {
          launchEnv['NODE_OPTIONS'] = stripFlag;
        } else if (!existingNodeOptions.contains(stripFlag)) {
          launchEnv['NODE_OPTIONS'] = '$stripFlag $existingNodeOptions';
        }
      }
      final process = await Process.start(
        launch.$1,
        launch.$2,
        workingDirectory: sidecarDir.path,
        environment: launchEnv,
        mode: ProcessStartMode.normal,
      );
      onLog('Sidecar 进程启动成功：PID ${process.pid}');
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => onLog('sidecar stdout: $line'));
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => onLog('sidecar stderr: $line'));
      if (await waitForApiReady(attempts: 120)) {
        onLog(AppLocalizations.of(context)!.sidecarLauncherS140);
        return true;
      }
      onLog(AppLocalizations.of(context)!.sidecarLauncherS193);
    } catch (error) {
      debugPrint('KidMemory sidecar auto-start failed: $error');
      onLog('sidecar 启动失败：$error');
    }
    return false;
  }

  bool _requiresStripTypes(List<String> args) {
    return args.any((arg) => arg.endsWith('.ts'));
  }

  Future<bool> apiReady() async {
    try {
      final health = await api.get('/health');
      return health['ok'] == true && health['service'] == 'kidmemory-sidecar';
    } catch (_) {
      return false;
    }
  }

  Future<bool> waitForApiReady({int attempts = 12}) async {
    for (var attempt = 0; attempt < attempts; attempt++) {
      if (await apiReady()) return true;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }

  Future<bool> _sidecarReachable() async {
    try {
      final socket = await Socket.connect(
        '127.0.0.1',
        4317,
        timeout: const Duration(milliseconds: 250),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _terminateProcessesOnSidecarPort() async {
    try {
      final pids = await _listSidecarPortListenerPids();
      if (pids.isEmpty) return;
      for (final pid in pids) {
        final killResult = await Process.run('/bin/kill', ['-TERM', pid]);
        if (killResult.exitCode == 0) {
          onLog('已终止旧 sidecar 进程 PID=$pid（端口 4317）');
        }
      }
      if (await _waitUntilSidecarPortFree()) return;

      final remainingPids = await _listSidecarPortListenerPids();
      for (final pid in remainingPids) {
        final killResult = await Process.run('/bin/kill', ['-KILL', pid]);
        if (killResult.exitCode == 0) {
          onLog('旧 sidecar 进程未及时退出，已强制终止 PID=$pid（端口 4317）');
        }
      }
      await _waitUntilSidecarPortFree();
    } catch (error) {
      onLog('终止旧 sidecar 进程失败：$error');
    }
  }

  Future<Set<String>> _listSidecarPortListenerPids() async {
    final pidLookup = await Process.run('/usr/sbin/lsof', [
      '-tiTCP:4317',
      '-sTCP:LISTEN',
    ]);
    if (pidLookup.exitCode != 0) return const <String>{};
    return '${pidLookup.stdout}'
        .split(RegExp(r'\s+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  Future<bool> _waitUntilSidecarPortFree() async {
    for (var attempt = 0; attempt < 20; attempt++) {
      if (!await _sidecarReachable()) return true;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  Directory? _resolveSidecarDirectory() {
    onLog('sidecar 目录探测: cwd=${Directory.current.path}');
    onLog('sidecar 目录探测: executable=${Platform.resolvedExecutable}');
    final explicitDir = Platform.environment['KIDMEMORY_SIDECAR_DIR']?.trim();
    if (explicitDir != null && explicitDir.isNotEmpty) {
      final candidate = Directory(explicitDir);
      if (_hasDistEntry(candidate)) return candidate;
      onLog('KIDMEMORY_SIDECAR_DIR 未包含可运行 sidecar（缺少 dist/main.js）：$explicitDir');
    }

    // Dev fallback: deterministic workspace-relative lookup without broad scan.
    final cwdCandidates = <String>[
      '${Directory.current.path}/../../sidecar',
      '${Directory.current.path}/../sidecar',
      '${Directory.current.path}/sidecar',
      '${Directory.current.path}/packages/sidecar',
    ];
    for (final path in cwdCandidates) {
      final candidate = Directory(path);
      final ok = _hasDistEntry(candidate);
      onLog('sidecar 目录探测: ${candidate.path} => ${ok ? 'OK' : 'MISS'}');
      if (ok) return candidate;
    }

    for (final root in <Directory>[
      Directory.current,
      File(Platform.resolvedExecutable).parent,
    ]) {
      final discovered = _findSidecarFromAncestorRoots(root, maxDepth: 8);
      if (discovered != null) return discovered;
    }

    final resourcesDir = Directory(
      '${File(Platform.resolvedExecutable).parent.path}/../Resources/sidecar',
    );
    return _isValidSidecarRuntimeDirectory(resourcesDir) ? resourcesDir : null;
  }

  Directory? _findSidecarFromAncestorRoots(
    Directory start, {
    required int maxDepth,
  }) {
    var current = start;
    for (var depth = 0; depth <= maxDepth; depth++) {
      final packaged = Directory('${current.path}/sidecar');
      if (_hasDistEntry(packaged)) {
        onLog('sidecar 目录探测: 命中 ${packaged.path}');
        return packaged;
      }

      final monorepo = Directory('${current.path}/packages/sidecar');
      if (_hasDistEntry(monorepo)) {
        onLog('sidecar 目录探测: 命中 ${monorepo.path}');
        return monorepo;
      }

      final parent = current.parent;
      if (parent.path == current.path) break;
      current = parent;
    }
    return null;
  }

  (String, List<String>)? _resolveSidecarLaunchCommand(
    Directory sidecarDir, {
    required String nodeExecutable,
  }) {
    final distEntry = File('${sidecarDir.path}/dist/main.js');
    if (distEntry.existsSync()) {
      return (nodeExecutable, [distEntry.path]);
    }
    onLog(AppLocalizations.of(context)!.sidecarLauncherS194);
    return null;
  }

  bool _isValidSidecarRuntimeDirectory(Directory dir) =>
      File('${dir.path}/sidecar-manifest.json').existsSync() &&
      _hasDistEntry(dir);

  bool _hasDistEntry(Directory dir) =>
      File('${dir.path}/dist/main.js').existsSync();

  String? _bundledNodePath(Directory dir) {
    final universal = '${dir.path}/node';
    if (File(universal).existsSync()) return universal;

    final arch = _currentDarwinNodeArch();
    if (arch == null) return null;
    final candidate = '${dir.path}/node-darwin-$arch';
    return File(candidate).existsSync() ? candidate : null;
  }

  String? _currentDarwinNodeArch() {
    if (!Platform.isMacOS) return null;
    try {
      final result = Process.runSync('uname', ['-m']);
      final machine = '${result.stdout}'.trim();
      return switch (machine) {
        'arm64' => 'arm64',
        'x86_64' => 'x64',
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }

}

Map<String, String> buildSidecarLaunchEnvironment({
  required Map<String, String> platformEnv,
  Map<String, String>? extraEnvironment,
}) {
  final env = <String, String>{...platformEnv};
  env['KIDMEMORY_SIDECAR_HOST'] = '127.0.0.1';
  env['KIDMEMORY_SIDECAR_PORT'] = '4317';
  env.addAll(extraEnvironment ?? const <String, String>{});

  final hasDatabaseUrl = (env['DATABASE_URL'] ?? '').trim().isNotEmpty;
  final hasPostgresUrl = (env['POSTGRES_URL'] ?? '').trim().isNotEmpty;
  if (hasDatabaseUrl || hasPostgresUrl) {
    return env;
  }

  final host = env['POSTGRES_HOST']?.trim();
  final port = env['POSTGRES_PORT']?.trim();
  final database = env['POSTGRES_DATABASE']?.trim();
  final user = env['POSTGRES_USER']?.trim();
  if ((host ?? '').isNotEmpty &&
      (port ?? '').isNotEmpty &&
      (database ?? '').isNotEmpty &&
      (user ?? '').isNotEmpty) {
    final password = env['POSTGRES_PASSWORD'] ?? '';
    final credentials = password.isEmpty
        ? Uri.encodeComponent(user!)
        : '${Uri.encodeComponent(user!)}:${Uri.encodeComponent(password)}';
    final connectionUrl = 'postgresql://$credentials@${host!}:${port!}/${database!}';
    env['DATABASE_URL'] = connectionUrl;
    env['POSTGRES_URL'] = connectionUrl;
  }

  return env;
}
