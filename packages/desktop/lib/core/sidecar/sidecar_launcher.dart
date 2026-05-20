import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'sidecar_api.dart';
import '../../../l10n/app_localizations.dart';

typedef ExecutableFinder = String? Function(String name);
typedef SidecarLocalizationsProvider = AppLocalizations? Function();

class SidecarLauncher {
  const SidecarLauncher({
    required this.api,
    required this.findExecutable,
    required this.ensureNodeAvailable,
    required this.onLog,
    this.onReadinessMessage,
    this.extraEnvironment,
    this.localizationsProvider,
  });

  final SidecarApi api;
  final ExecutableFinder findExecutable;
  final Future<bool> Function() ensureNodeAvailable;
  final void Function(String message) onLog;
  final void Function(String message)? onReadinessMessage;
  final Map<String, String> Function()? extraEnvironment;
  final SidecarLocalizationsProvider? localizationsProvider;

  String _localized(
    String Function(AppLocalizations l10n) selector,
    String fallback,
  ) {
    final l10n = localizationsProvider?.call();
    return l10n == null ? fallback : selector(l10n);
  }

  Future<bool> ensureRunning({bool forceRestart = false}) async {
    // In test environments the sidecar API is mocked; never attempt
    // socket connection or process launch (both block FakeAsync).
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherS679,
          'Test environment detected; skipped sidecar auto-start.',
        ),
      );
      return true;
    }

    if (forceRestart) {
      await _terminateProcessesOnSidecarPort();
    } else if (await apiReady()) {
      return true;
    }
    if (await _sidecarReachable()) {
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherS98,
          'Port 4317 is already in use, but KidMemory sidecar health did not respond.',
        ),
      );
      return false;
    }

    final sidecarDir = _resolveSidecarDirectory();
    if (sidecarDir == null) {
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherS584,
          'Sidecar runtime directory was not found. Confirm the app bundle contains Resources/sidecar, or set KIDMEMORY_SIDECAR_DIR.',
        ),
      );
      return false;
    }

    onLog(
      _localized(
        (l10n) => l10n.sidecarLauncherS146,
        'Sidecar is not ready; attempting automatic start.',
      ),
    );
    onReadinessMessage?.call(
      _localized((l10n) => l10n.sidecarLauncherS141, 'Starting Sidecar'),
    );
    if (!await ensureNodeAvailable()) return false;
    final node = _bundledNodePath(sidecarDir) ?? findExecutable('node');
    if (node == null) {
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherS592,
          'No Node.js runtime was found for starting sidecar.',
        ),
      );
      return false;
    }

    final launch = _resolveSidecarLaunchCommand(
      sidecarDir,
      nodeExecutable: node,
    );
    if (launch == null) {
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherS591,
          'No runnable sidecar entry point was found; skipped automatic start.',
        ),
      );
      return false;
    }

    try {
      final launchCommand = '${launch.$1} ${launch.$2.join(' ')}';
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherLaunchCommandLog(launchCommand),
          'Starting sidecar command: $launchCommand',
        ),
      );
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
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherStartedPidLog(process.pid),
          'Sidecar process started successfully: PID ${process.pid}',
        ),
      );
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => onLog('sidecar stdout: $line'));
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => onLog('sidecar stderr: $line'));
      if (await waitForApiReady(attempts: 120)) {
        onLog(
          _localized(
            (l10n) => l10n.sidecarLauncherS140,
            'Sidecar initialized successfully.',
          ),
        );
        return true;
      }
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherS193,
          'Sidecar start failed: service did not pass the health check in time.',
        ),
      );
    } catch (error) {
      debugPrint('KidMemory sidecar auto-start failed: $error');
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherStartFailedLog(error),
          'Sidecar start failed: $error',
        ),
      );
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
          onLog(
            _localized(
              (l10n) => l10n.sidecarLauncherTerminatedOldPidLog(pid),
              'Terminated old sidecar process PID=$pid on port 4317',
            ),
          );
        }
      }
      if (await _waitUntilSidecarPortFree()) return;

      final remainingPids = await _listSidecarPortListenerPids();
      for (final pid in remainingPids) {
        final killResult = await Process.run('/bin/kill', ['-KILL', pid]);
        if (killResult.exitCode == 0) {
          onLog(
            _localized(
              (l10n) => l10n.sidecarLauncherForceTerminatedOldPidLog(pid),
              'Old sidecar process did not exit in time; force terminated PID=$pid on port 4317',
            ),
          );
        }
      }
      await _waitUntilSidecarPortFree();
    } catch (error) {
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherTerminateOldFailedLog(error),
          'Failed to terminate old sidecar process: $error',
        ),
      );
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
    onLog(
      _localized(
        (l10n) =>
            l10n.sidecarLauncherDirectoryProbeCwdLog(Directory.current.path),
        'Sidecar directory probe: cwd=${Directory.current.path}',
      ),
    );
    onLog(
      _localized(
        (l10n) => l10n.sidecarLauncherDirectoryProbeExecutableLog(
          Platform.resolvedExecutable,
        ),
        'Sidecar directory probe: executable=${Platform.resolvedExecutable}',
      ),
    );
    final explicitDir = Platform.environment['KIDMEMORY_SIDECAR_DIR']?.trim();
    if (explicitDir != null && explicitDir.isNotEmpty) {
      final candidate = Directory(explicitDir);
      if (_hasDistEntry(candidate)) return candidate;
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherInvalidExplicitDirLog(explicitDir),
          'KIDMEMORY_SIDECAR_DIR does not contain a runnable sidecar (missing dist/main.js): $explicitDir',
        ),
      );
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
      final status = ok ? 'OK' : 'MISS';
      onLog(
        _localized(
          (l10n) => l10n.sidecarLauncherDirectoryProbeCandidateLog(
            candidate.path,
            status,
          ),
          'Sidecar directory probe: ${candidate.path} => $status',
        ),
      );
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
        onLog(
          _localized(
            (l10n) => l10n.sidecarLauncherDirectoryProbeFoundLog(packaged.path),
            'Sidecar directory probe: found ${packaged.path}',
          ),
        );
        return packaged;
      }

      final monorepo = Directory('${current.path}/packages/sidecar');
      if (_hasDistEntry(monorepo)) {
        onLog(
          _localized(
            (l10n) => l10n.sidecarLauncherDirectoryProbeFoundLog(monorepo.path),
            'Sidecar directory probe: found ${monorepo.path}',
          ),
        );
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
    onLog(
      _localized(
        (l10n) => l10n.sidecarLauncherS194,
        'Sidecar start failed: runtime directory is missing dist/main.js.',
      ),
    );
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
    final connectionUrl =
        'postgresql://$credentials@${host!}:${port!}/${database!}';
    env['DATABASE_URL'] = connectionUrl;
    env['POSTGRES_URL'] = connectionUrl;
  }

  return env;
}
