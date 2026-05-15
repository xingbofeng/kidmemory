part of '../../desktop_shell.dart';

extension _DesktopShellSetupSystem on _DesktopShellState {
  Future<void> _installPgvectorFromSourceForPostgres16() async {
    final pgConfig = _postgresPgConfig();
    if (pgConfig == null) {
      throw const _SetupCommandException(
        'pgvector source install',
        1,
        '未找到 PostgreSQL 16 的 pg_config，无法按官方源码编译 pgvector。',
      );
    }

    final git = _findExecutable('git');
    final make = _findExecutable('make');
    if (git == null || make == null) {
      throw const _SetupCommandException(
        'pgvector source install',
        1,
        '未找到 git 或 make，无法按官方源码编译 pgvector。请先安装 Xcode Command Line Tools。',
      );
    }

    final workDir =
        '/tmp/kidmemory-pgvector-${DateTime.now().millisecondsSinceEpoch}';
    await _runSetupCommandStreaming(
      '/bin/sh',
      [
        '-lc',
        [
          r'rm -rf "$0"',
          r'git clone --depth 1 https://github.com/pgvector/pgvector.git "$0"',
          r'cd "$0"',
          r'make PG_CONFIG="$1"',
          r'make install PG_CONFIG="$1"',
        ].join(' && '),
        workDir,
        pgConfig,
      ],
      timeout: const Duration(minutes: 12),
      onOutput: (line, kind) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) return;
        if (trimmed.contains('Cloning')) {
          _setSetupProgress(
            'pgvector 检测',
            0.80,
            '正在拉取 pgvector 官方源码',
            state: '安装中',
          );
        } else if (trimmed.startsWith('clang') || trimmed.startsWith('cc ')) {
          _setSetupProgress(
            'pgvector 检测',
            0.83,
            '正在编译 pgvector for PostgreSQL 16',
            state: '安装中',
          );
        } else if (trimmed.contains('vector.control') ||
            trimmed.contains('vector.dylib') ||
            trimmed.contains('vector.so')) {
          _setSetupProgress(
            'pgvector 检测',
            0.88,
            '正在安装 PG16 扩展文件',
            state: '安装中',
          );
        }
      },
    );
  }

  Future<void> _ensureHomebrewWritable(
    String brew, {
    required String packageName,
  }) async {
    if (!Platform.isMacOS) return;

    final prefix = await _runCommandText(brew, ['--prefix']);
    if (prefix.isEmpty) return;
    final cache = await _runCommandText(brew, ['--cache']);
    final home = Platform.environment['HOME'] ?? '';
    final paths = <String>[
      prefix,
      '$prefix/Cellar',
      '$prefix/opt',
      '$prefix/var',
      '$prefix/var/homebrew',
      '$prefix/var/homebrew/locks',
      '$prefix/var/postgresql@16',
      if (cache.isNotEmpty) cache,
      if (home.isNotEmpty) '$home/Library/LaunchAgents',
    ];
    final blocked = <String>[];
    for (final path in paths) {
      final dir = Directory(path);
      if (!dir.existsSync()) continue;
      if (!_directoryWritable(dir)) blocked.add(path);
    }
    if (blocked.isEmpty) return;

    throw _SetupCommandException(
      'Homebrew 权限预检',
      1,
      _homebrewPermissionFixMessage(
        packageName: packageName,
        prefix: prefix,
        blockedPaths: blocked,
      ),
    );
  }

}
