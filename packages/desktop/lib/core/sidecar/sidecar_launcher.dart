import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'sidecar_api.dart';

typedef ExecutableFinder = String? Function(String name);
typedef InstallCommandRunner =
    Future<bool> Function(
      String executable,
      List<String> args,
      String action, {
      String? workingDirectory,
    });

class SidecarLauncher {
  const SidecarLauncher({
    required this.api,
    required this.findExecutable,
    required this.ensureNodeAvailable,
    required this.runInstallCommand,
    required this.onLog,
    this.onReadinessMessage,
  });

  final SidecarApi api;
  final ExecutableFinder findExecutable;
  final Future<bool> Function() ensureNodeAvailable;
  final InstallCommandRunner runInstallCommand;
  final void Function(String message) onLog;
  final void Function(String message)? onReadinessMessage;

  Future<bool> ensureRunning() async {
    // In test environments the sidecar API is mocked; never attempt
    // socket connection or process launch (both block FakeAsync).
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      onLog('测试环境，跳过 sidecar 自动启动。');
      return true;
    }

    if (await apiReady()) return true;
    if (await _sidecarReachable()) {
      onLog('4317 端口已被占用，但未响应 KidMemory sidecar health。');
      return false;
    }

    final sidecarDir = _findSidecarDirectory();
    if (sidecarDir == null) {
      onLog('未能找到 sidecar 目录，已跳过自动启动。');
      return false;
    }

    onLog('Sidecar 未就绪，开始尝试自动启动。');
    onReadinessMessage?.call('Sidecar 启动中');
    final bundledSidecar = _isBundledSidecar(sidecarDir);
    if (!bundledSidecar && !await ensureNodeAvailable()) return false;
    final node = bundledSidecar
        ? _bundledNodePath(sidecarDir) ?? findExecutable('node')
        : findExecutable('node');
    if (node == null) {
      onLog('未检测到可用于启动 sidecar 的 Node.js。');
      return false;
    }

    final npm = bundledSidecar ? null : findExecutable('npm');
    final launch = await _resolveSidecarLaunchCommand(
      sidecarDir,
      nodeExecutable: node,
      npmExecutable: npm,
    );
    if (launch == null) {
      onLog('未检测到可启动的 sidecar 入口，已跳过自动启动。');
      return false;
    }

    try {
      onLog('启动 sidecar 命令：${launch.$1} ${launch.$2.join(' ')}');
      final process = await Process.start(
        launch.$1,
        launch.$2,
        workingDirectory: sidecarDir.path,
        environment: {
          ...Platform.environment,
          'KIDMEMORY_SIDECAR_HOST': '127.0.0.1',
          'KIDMEMORY_SIDECAR_PORT': '4317',
        },
        mode: ProcessStartMode.detached,
      );
      onLog('Sidecar 进程启动成功：PID ${process.pid}');
      if (await waitForApiReady(attempts: 60)) {
        onLog('Sidecar 初始化成功。');
        return true;
      }
      onLog('sidecar 启动失败：服务未在预期时间内通过 health 检查。');
    } catch (error) {
      debugPrint('KidMemory sidecar auto-start failed: $error');
      onLog('sidecar 启动失败：$error');
    }
    return false;
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

  Directory? _findSidecarDirectory() {
    final bundled = _resolveBundledSidecarPath();
    if (bundled != null) return bundled;

    for (final root in _candidateRoots()) {
      if (File('${root.path}/package.json').existsSync()) {
        return root;
      }
      for (final rel in const [
        'packages/backend',
        'sidecar',
        'resources/sidecar',
        'Resources/sidecar',
        'app/sidecar',
      ]) {
        final candidate = Directory('${root.path}/$rel');
        if (File('${candidate.path}/package.json').existsSync()) {
          return candidate;
        }
      }
    }
    return null;
  }

  Directory? _resolveBundledSidecarPath() {
    final resourcesDir = Directory(
      '${File(Platform.resolvedExecutable).parent.path}/../Resources/sidecar',
    );
    final manifest = File('${resourcesDir.path}/sidecar-manifest.json');
    return manifest.existsSync() ? resourcesDir : null;
  }

  Iterable<Directory> _candidateRoots() sync* {
    for (final rawPath in [
      Platform.environment['KIDMEMORY_SIDECAR_DIR'],
      Platform.environment['KIDMEMORY_REPO_ROOT'],
      Platform.environment['SRCROOT'],
      Platform.environment['PROJECT_DIR'],
    ]) {
      if (rawPath == null || rawPath.trim().isEmpty) continue;
      var cursor = Directory(rawPath.trim());
      for (var depth = 0; depth < 6; depth++) {
        yield cursor;
        final parent = cursor.parent;
        if (parent.path == cursor.path) break;
        cursor = parent;
      }
    }

    for (final start in [
      Directory.current,
      File(Platform.resolvedExecutable).parent,
    ]) {
      var cursor = start;
      while (true) {
        yield cursor;
        final parent = cursor.parent;
        if (parent.path == cursor.path) break;
        cursor = parent;
      }
    }
  }

  Future<(String, List<String>)?> _resolveSidecarLaunchCommand(
    Directory sidecarDir, {
    required String nodeExecutable,
    String? npmExecutable,
  }) async {
    if (_isBundledSidecar(sidecarDir)) {
      final nodeBin = _bundledNodePath(sidecarDir);
      final mainEntry = _bundledMainPath(sidecarDir);
      if (nodeBin != null && mainEntry != null) {
        return (nodeBin, _nodeEntryArgs(mainEntry));
      }
      if (mainEntry != null) {
        return (nodeExecutable, _nodeEntryArgs(mainEntry));
      }
    }

    final sourceMain = File('${sidecarDir.path}/src/main.ts');
    if (sourceMain.existsSync()) {
      if (npmExecutable != null &&
          _sidecarPackageHasScript(sidecarDir.path, 'dev')) {
        await _ensureSidecarDependencies(
          sidecarDir,
          npmExecutable: npmExecutable,
        );
        return (npmExecutable, ['run', 'dev']);
      }
      return (nodeExecutable, ['--experimental-strip-types', sourceMain.path]);
    }

    final builtCandidates = [
      '${sidecarDir.path}/dist/main.js',
      '${sidecarDir.path}/bundle/main.js',
      '${sidecarDir.path}/main.js',
    ];
    for (final candidate in builtCandidates) {
      final file = File(candidate);
      if (file.existsSync()) {
        return (nodeExecutable, [file.path]);
      }
    }

    if (npmExecutable != null) {
      await _prepareSidecarBundle(sidecarDir, npmExecutable: npmExecutable);
      for (final candidate in builtCandidates) {
        final file = File(candidate);
        if (file.existsSync()) {
          return (nodeExecutable, [file.path]);
        }
      }
    }

    if (npmExecutable != null &&
        _sidecarPackageHasScript(sidecarDir.path, 'dev')) {
      return (npmExecutable, ['run', 'dev']);
    }

    return null;
  }

  bool _sidecarPackageHasScript(String sidecarDir, String scriptName) {
    try {
      final packageJson = File('$sidecarDir/package.json');
      if (!packageJson.existsSync()) return false;
      final payload = jsonDecode(packageJson.readAsStringSync());
      final scripts = payload is Map ? payload['scripts'] : null;
      if (scripts is! Map) return false;
      final target = scripts[scriptName];
      return target is String && target.trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _isBundledSidecar(Directory dir) =>
      File('${dir.path}/sidecar-manifest.json').existsSync();

  String? _bundledNodePath(Directory dir) {
    final universal = '${dir.path}/node';
    if (File(universal).existsSync()) return universal;

    final arch = _currentDarwinNodeArch();
    if (arch == null) return null;
    final candidate = '${dir.path}/node-darwin-$arch';
    return File(candidate).existsSync() ? candidate : null;
  }

  String? _bundledMainPath(Directory dir) {
    final candidates = [
      '${dir.path}/src/main.ts',
      '${dir.path}/dist/main.js',
      '${dir.path}/main.js',
    ];
    for (final candidate in candidates) {
      if (File(candidate).existsSync()) return candidate;
    }
    return null;
  }

  List<String> _nodeEntryArgs(String entryPath) {
    if (entryPath.endsWith('.ts')) {
      return ['--experimental-strip-types', entryPath];
    }
    return [entryPath];
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

  Future<void> _prepareSidecarBundle(
    Directory sidecarDir, {
    required String npmExecutable,
  }) async {
    if (!_sidecarPackageHasScript(sidecarDir.path, 'build')) return;
    await _ensureSidecarDependencies(sidecarDir, npmExecutable: npmExecutable);
    await runInstallCommand(
      npmExecutable,
      ['run', 'build'],
      '构建 Sidecar 运行脚本',
      workingDirectory: sidecarDir.path,
    );
  }

  Future<void> _ensureSidecarDependencies(
    Directory sidecarDir, {
    required String npmExecutable,
  }) async {
    if (Directory('${sidecarDir.path}/node_modules').existsSync()) return;
    final hasLockfile = File(
      '${sidecarDir.path}/package-lock.json',
    ).existsSync();
    await runInstallCommand(
      npmExecutable,
      [hasLockfile ? 'ci' : 'install'],
      '安装 Sidecar 依赖',
      workingDirectory: sidecarDir.path,
    );
  }
}
