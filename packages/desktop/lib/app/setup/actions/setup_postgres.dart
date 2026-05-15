part of '../../desktop_shell.dart';

extension _DesktopShellSetupPostgres on _DesktopShellState {
  Future<bool> _preparePostgresOnMacOS({
    required String title,
    required _PgLocalStatus local,
  }) async {
    final brew = _findExecutable('brew');
    if (brew == null) {
      _finishSetupProgress(
        title,
        '未找到 Homebrew，暂时无法自动安装 PostgreSQL',
        ok: false,
      );
      _showSnackBar('未找到 Homebrew，无法自动安装 PostgreSQL');
      return false;
    }
    await _ensureHomebrewWritable(brew, packageName: 'postgresql@16');

    if (local == _PgLocalStatus.notInstalled) {
      _setSetupProgress(
        title,
        0.05,
        '正在通过 Homebrew 安装 PostgreSQL...',
        state: '安装中',
      );
      final tracker = _BrewPhaseTracker(
        baseProgress: 0.05,
        maxProgress: 0.38,
        onUpdate: (progress, label) {
          if (!mounted) return;
          _setSetupProgress(title, progress, label, state: '安装中');
        },
      );
      await _runSetupCommandStreaming(brew, [
        'install',
        'postgresql@16',
      ], onOutput: (line, kind) => tracker.feed(line));
    } else {
      _setSetupProgress(title, 0.38, 'PostgreSQL 已安装，跳过下载', state: '安装中');
    }

    if (local != _PgLocalStatus.running) {
      _setSetupProgress(title, 0.42, '正在启动 PostgreSQL 服务...', state: '启动中');
      await _runSetupCommandStreaming(
        brew,
        ['services', 'start', 'postgresql@16'],
        onOutput: (line, kind) {
          final trimmed = line.trim();
          if (trimmed.contains('Successfully') ||
              trimmed.contains('already started')) {
            _setSetupProgress(
              title,
              0.48,
              'PostgreSQL 服务已启动',
              state: '启动中',
            );
          }
        },
      );
    } else {
      _setSetupProgress(title, 0.48, 'PostgreSQL 服务已在运行', state: '启动中');
    }

    _setSetupProgress(title, 0.52, '创建 KidMemory 本地资料库', state: '初始化');
    await _runSetupCommandStreaming(
      _postgresTool('createdb') ?? 'createdb',
      ['kidmemory'],
      allowFailure: true,
      onOutput: (line, kind) {},
    );
    return true;
  }

  Future<void> _runPostgresSetupWorkflow() async {
    const title = 'PostgreSQL 配置';
    final local = _detectPgLocal();
    _appendLog('开始 PostgreSQL 安装与配置流程（本地检测: $local）');

    try {
      final databaseUser = Platform.environment['USER'] ?? 'postgres';

      if (Platform.isMacOS) {
        final prepared = await _preparePostgresOnMacOS(
          title: title,
          local: local,
        );
        if (!prepared) {
          return;
        }
      }

      final configured = await _configureAndVerifyPostgres(
        title: title,
        databaseUser: databaseUser,
      );
      if (!configured) {
        return;
      }

      _setSetupProgress(title, 1, 'PostgreSQL 已配置完成', state: '已配置');
      _showSnackBar('PostgreSQL 已配置完成');
      await refreshReadiness();
    } catch (error) {
      final message = _friendlySetupError(error, packageName: 'postgresql@16');
      _finishSetupProgress(title, message, ok: false);
      _showSnackBar(message);
    }
  }

  Future<bool> _configureAndVerifyPostgres({
    required String title,
    required String databaseUser,
  }) async {
    _setSetupProgress(
      _sidecarSetupTitle,
      0.15,
      '正在启动 Sidecar...',
      state: '启动中',
    );
    final sidecarReady = await _ensureSidecarRunning();
    if (!sidecarReady) {
      _finishSetupProgress(
        _sidecarSetupTitle,
        'Sidecar 未能启动，请检查 Node.js 或 bundled sidecar',
        ok: false,
      );
      _showSnackBar('PostgreSQL 已处理，但 Sidecar 未能启动');
      return false;
    }
    _finishSetupProgress(_sidecarSetupTitle, 'Sidecar 已启动', ok: true);

    _setSetupProgress(title, 0.62, '写入默认本地连接配置', state: '配置中');
    final configureResult = await gateway.configurePostgresDto(
      payload: PostgresConfigRequest(
        host: _pgDefaultHost,
        port: _pgDefaultPort,
        database: _pgDefaultDatabase,
        user: databaseUser,
      ),
    );
    if (!configureResult.ok) {
      _finishSetupProgress(
        title,
        configureResult.message.isNotEmpty
            ? configureResult.message
            : '写入 PostgreSQL 配置失败',
        ok: false,
      );
      _showSnackBar('PostgreSQL 配置写入失败');
      return false;
    }

    _setSetupProgress(title, 0.78, '检测 PostgreSQL 服务', state: '检测中');
    final postgres = await gateway.checkPostgresDto();
    if (postgres.okOrNull != true) {
      _finishSetupProgress(title, '未检测到 PostgreSQL，请确认本机服务已安装并启动', ok: false);
      _showSnackBar('PostgreSQL 还未就绪，请启动本机服务后重试');
      return false;
    }

    _setSetupProgress(title, 0.92, '初始化 KidMemory 数据库结构', state: '初始化');
    final schema = await gateway.initSchemaDto();
    if (schema.okOrNull == false) {
      _finishSetupProgress(
        title,
        schema.message.isNotEmpty ? schema.message : '数据库结构初始化失败',
        ok: false,
      );
      _showSnackBar('数据库结构初始化失败');
      return false;
    }
    return true;
  }
}
