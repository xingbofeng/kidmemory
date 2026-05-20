part of '../../desktop_shell.dart';

extension _DesktopShellSetupSystem on _DesktopShellState {
  Directory? _bundledPostgresRuntimeDirectory() {
    final explicitDir = Platform.environment['KIDMEMORY_POSTGRES_RUNTIME_DIR']
        ?.trim();
    if (explicitDir != null && explicitDir.isNotEmpty) {
      final runtime = Directory(explicitDir);
      if (_isValidPostgresRuntime(runtime)) return runtime;
      _appendLog(
        AppLocalizations.of(
          context,
        )!.setupInvalidPostgresRuntimeDir(explicitDir),
      );
    }

    final resourcesDir = Directory(
      '${File(Platform.resolvedExecutable).parent.path}/../Resources',
    );
    final postgresDir = Directory('${resourcesDir.path}/postgres');
    if (_isValidPostgresRuntime(postgresDir)) return postgresDir;

    // Dev fallback: when running from source checkout, allow a deterministic
    // workspace path without scanning the full filesystem.
    final cwdCandidates = <String>[
      '${Directory.current.path}/../../third_party/postgres/macos',
      '${Directory.current.path}/../third_party/postgres/macos',
      '${Directory.current.path}/third_party/postgres/macos',
    ];
    for (final path in cwdCandidates) {
      final candidate = Directory(path);
      if (_isValidPostgresRuntime(candidate)) return candidate;
    }

    return null;
  }

  bool _isValidPostgresRuntime(Directory dir) {
    return Directory('${dir.path}/bin').existsSync() &&
        Directory('${dir.path}/lib').existsSync() &&
        Directory('${dir.path}/share').existsSync();
  }

  bool _bundledPostgresRuntimeAvailable() {
    if (!Platform.isMacOS) return false;
    final runtimeDir = _bundledPostgresRuntimeDirectory();
    if (runtimeDir == null) return false;
    return _bundledPostgresTool('pg_ctl') != null &&
        _bundledPostgresTool('initdb') != null &&
        _bundledPostgresTool('psql') != null;
  }

  String? _bundledPostgresTool(String name) {
    final runtimeDir = _bundledPostgresRuntimeDirectory();
    if (runtimeDir == null) return null;
    final candidate = File('${runtimeDir.path}/bin/$name');
    return candidate.existsSync() ? candidate.path : null;
  }

  String _bundledPostgresDataDir() {
    final appRoot = Directory(_defaultKidMemoryPaths().dataDir).parent.path;
    return '$appRoot${Platform.pathSeparator}postgres-data';
  }

  String _bundledPostgresLogPath() {
    final appRoot = Directory(_defaultKidMemoryPaths().dataDir).parent.path;
    return '$appRoot${Platform.pathSeparator}logs${Platform.pathSeparator}postgres.log';
  }

  String _bundledPostgresOwnerPath() {
    final appRoot = Directory(_defaultKidMemoryPaths().dataDir).parent.path;
    return '$appRoot${Platform.pathSeparator}logs${Platform.pathSeparator}postgres.owner.pid';
  }

  Future<int> _reserveLocalPostgresPort() async {
    final socket = await ServerSocket.bind(_pgDefaultLoopback, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }

  void _stopBundledPostgresIfRunning({bool force = false}) {
    final pgCtl = _bundledPostgresTool('pg_ctl');
    if (pgCtl == null) return;
    final dataDir = Directory(_bundledPostgresDataDir());
    if (!dataDir.existsSync()) return;
    final ownerFile = File(_bundledPostgresOwnerPath());
    if (!force) {
      final ownerPid = ownerFile.existsSync()
          ? ownerFile.readAsStringSync().trim()
          : '';
      if (ownerPid != '$pid') return;
    }
    try {
      Process.runSync(
        pgCtl,
        ['-D', dataDir.path, 'stop', '-m', 'fast'],
        environment: {...Platform.environment, 'PATH': _setupCommandPath},
      );
      if (ownerFile.existsSync()) {
        ownerFile.deleteSync();
      }
    } catch (_) {}
  }

  Future<void> _runBundledPostgresCommand(
    String executable,
    List<String> arguments, {
    required void Function(String line, _StreamKind kind) onOutput,
    bool allowFailure = false,
    Duration timeout = _setupCommandTimeout,
    Map<String, String>? environment,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      environment: {
        ...Platform.environment,
        'PATH': _setupCommandPath,
        ...?environment,
      },
    );
    final stdoutDone = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => onOutput(line, _StreamKind.stdout))
        .asFuture<void>();
    final stderrDone = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => onOutput(line, _StreamKind.stderr))
        .asFuture<void>();

    var timedOut = false;
    final exitCode = await process.exitCode.timeout(
      timeout,
      onTimeout: () {
        timedOut = true;
        process.kill(ProcessSignal.sigterm);
        return -1;
      },
    );
    await Future.wait([stdoutDone, stderrDone]);

    if (timedOut) {
      throw _SetupCommandException(
        [executable, ...arguments].join(' '),
        exitCode,
        'Bundled PostgreSQL command timed out.',
      );
    }
    if (!allowFailure && exitCode != 0) {
      throw _SetupCommandException(
        [executable, ...arguments].join(' '),
        exitCode,
        'Bundled PostgreSQL command failed.',
      );
    }
  }

  Future<bool> _ensureBundledPostgresReady(String title) async {
    final pgCtl = _bundledPostgresTool('pg_ctl');
    final initdb = _bundledPostgresTool('initdb');
    final createdb = _bundledPostgresTool('createdb');
    final psql = _bundledPostgresTool('psql');
    if (pgCtl == null || initdb == null || createdb == null || psql == null) {
      _finishSetupProgress(
        title,
        AppLocalizations.of(context)!.setupNoPostgresRuntimeFound,
        ok: false,
      );
      return false;
    }

    _stopBundledPostgresIfRunning(force: true);
    _bundledPostgresPort = await _reserveLocalPostgresPort();
    _appendLog(
      AppLocalizations.of(
        context,
      )!.setupBundledPostgresPortLog(_bundledPostgresPort),
    );

    final dataDir = Directory(_bundledPostgresDataDir());
    final logFile = File(_bundledPostgresLogPath());
    dataDir.createSync(recursive: true);
    logFile.parent.createSync(recursive: true);
    if (!logFile.existsSync()) {
      logFile.writeAsStringSync('', flush: true);
    }

    final locale = Platform.environment['LANG'] ?? 'C';
    final runtimeDir = _bundledPostgresRuntimeDirectory();
    final runtimeLibDir = runtimeDir == null ? '' : '${runtimeDir.path}/lib';
    final runtimeShareRoot = runtimeDir == null
        ? ''
        : '${runtimeDir.path}/share';
    final runtimeShareDir =
        runtimeDir != null &&
            Directory('${runtimeDir.path}/share/postgresql@16').existsSync()
        ? '${runtimeDir.path}/share/postgresql@16'
        : runtimeShareRoot;
    final runtimeEnv = <String, String>{
      'LANG': locale,
      if (runtimeLibDir.isNotEmpty) 'DYLD_LIBRARY_PATH': runtimeLibDir,
      if (runtimeShareDir.isNotEmpty) 'PGSHAREDIR': runtimeShareDir,
    };

    final versionFile = File('${dataDir.path}/PG_VERSION');
    if (!versionFile.existsSync()) {
      _setSetupProgress(
        title,
        0.12,
        AppLocalizations.of(context)!.setupInitBuiltinDataDir,
        state: AppLocalizations.of(context)!.setupInitStarted,
      );
      await _runBundledPostgresCommand(
        initdb,
        [
          '-D',
          dataDir.path,
          '-L',
          runtimeShareDir,
          '--username=postgres',
          '--auth=trust',
        ],
        environment: runtimeEnv,
        timeout: const Duration(minutes: 3),
        onOutput: (line, kind) => _appendLog('initdb: $line'),
      );
    }

    _setSetupProgress(
      title,
      0.30,
      AppLocalizations.of(context)!.setupStartBuiltinPostgres,
      state: AppLocalizations.of(context)!.setupStatusStarting,
    );
    await _runBundledPostgresCommand(
      pgCtl,
      [
        '-D',
        dataDir.path,
        '-l',
        logFile.path,
        '-o',
        '-h $_pgDefaultLoopback -p $_bundledPostgresPort',
        '-w',
        '-t',
        '20',
        'start',
      ],
      allowFailure: false,
      timeout: const Duration(minutes: 2),
      environment: runtimeEnv,
      onOutput: (line, kind) => _appendLog('pg_ctl start: $line'),
    );
    final ownerFile = File(_bundledPostgresOwnerPath());
    ownerFile.parent.createSync(recursive: true);
    ownerFile.writeAsStringSync('$pid', flush: true);

    _setSetupProgress(
      title,
      0.42,
      AppLocalizations.of(context)!.setupCreateLocalDatabase,
      state: AppLocalizations.of(context)!.setupInitStarted,
    );
    await _runBundledPostgresCommand(
      createdb,
      [
        '-h',
        _pgDefaultLoopback,
        '-p',
        '$_bundledPostgresPort',
        '-U',
        'postgres',
        _pgDefaultDatabase,
      ],
      allowFailure: true,
      environment: runtimeEnv,
      onOutput: (line, kind) => _appendLog('createdb: $line'),
    );

    _setSetupProgress(
      title,
      0.50,
      AppLocalizations.of(context)!.setupEnableVectorExtension,
      state: AppLocalizations.of(context)!.setupInitStarted,
    );
    await _runBundledPostgresCommand(
      psql,
      [
        '-h',
        _pgDefaultLoopback,
        '-p',
        '$_bundledPostgresPort',
        '-U',
        'postgres',
        '-d',
        _pgDefaultDatabase,
        '-c',
        'CREATE EXTENSION IF NOT EXISTS vector;',
      ],
      environment: runtimeEnv,
      onOutput: (line, kind) => _appendLog('psql: $line'),
    );
    return true;
  }
}
