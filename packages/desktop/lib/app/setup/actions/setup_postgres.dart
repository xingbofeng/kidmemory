part of '../../desktop_shell.dart';

extension _DesktopShellSetupPostgres on _DesktopShellState {
  Future<bool> _preparePostgresOnMacOS({
    required String title,
  }) async {
    if (!_bundledPostgresRuntimeAvailable()) {
      _finishSetupProgress(
        title,
        '未检测到 PostgreSQL runtime，请确认 Resources/postgres 或仓库 third_party/postgres/macos 可用。',
        ok: false,
      );
      _showSnackBar('未检测到内置 PostgreSQL runtime');
      return false;
    }
    _appendLog('检测到内置 PostgreSQL runtime，开始初始化。');
    return _ensureBundledPostgresReady(title);
  }

  Future<void> _runPostgresSetupWorkflow() async {
    const title = 'PostgreSQL 配置';
    _appendLog('开始 PostgreSQL 安装与配置流程');

    try {
      if (Platform.isMacOS) {
        final prepared = await _preparePostgresOnMacOS(title: title);
        if (!prepared) {
          return;
        }
      }

      final configured = await _configureAndVerifyPostgres(title: title);
      if (!configured) {
        return;
      }

      _setSetupProgress(title, 1, 'PostgreSQL 已配置完成', state: '已配置');
      _showSnackBar('PostgreSQL 已配置完成');
      await refreshReadiness();
    } catch (error) {
      final message = _friendlySetupError(
        error,
        packageName: 'bundled-postgres',
      );
      _finishSetupProgress(title, message, ok: false);
      _showSnackBar(message);
    }
  }

  Future<bool> _configureAndVerifyPostgres({required String title}) async {
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
      final schemaMessage = schema.message ?? '';
      _finishSetupProgress(
        title,
        schemaMessage.isNotEmpty ? schemaMessage : '数据库结构初始化失败',
        ok: false,
      );
      _showSnackBar('数据库结构初始化失败');
      return false;
    }
    return true;
  }
}
