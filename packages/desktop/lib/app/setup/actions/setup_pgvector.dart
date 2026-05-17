part of '../../desktop_shell.dart';

extension _DesktopShellSetupPgvector on _DesktopShellState {
  Future<bool> _ensurePostgresReadyForPgvector(String title) async {
    _setSetupProgress(title, 0.10, '检测 PostgreSQL 连接', state: '检测中');
    var postgres = await gateway.checkPostgresDto();
    if (postgres.okOrNull == true) return true;

    _setSetupProgress(
      title,
      0.18,
      'PostgreSQL 未就绪，自动执行 PostgreSQL 安装与配置',
      state: '安装中',
    );
    _appendLog('pgvector 流程检测到 PostgreSQL 未就绪，自动联动执行 PostgreSQL 安装配置');
    await _runPostgresSetupWorkflow();

    _setSetupProgress(title, 0.50, '复查 PostgreSQL 连接', state: '检测中');
    postgres = await gateway.checkPostgresDto();
    if (postgres.okOrNull == true) return true;

    _finishSetupProgress(
      title,
      'PostgreSQL 仍未就绪，安装 pgvector 前请先完成数据库配置',
      ok: false,
    );
    _showSnackBar('PostgreSQL 未就绪，请检查数据库配置后重试');
    return false;
  }

  Future<bool> _installPgvectorOnMacOSIfNeeded({required String title}) async {
    if (!Platform.isMacOS) return true;
    _setSetupProgress(title, 0.72, '校验内置 pgvector 扩展', state: '安装中');
    if (!_bundledPostgresRuntimeAvailable()) {
      _finishSetupProgress(
        title,
        '未检测到内置 PostgreSQL runtime，请使用带 runtime 的 Release 包。',
        ok: false,
      );
      _showSnackBar('未检测到内置 PostgreSQL runtime');
      return false;
    }
    if (_pgvectorInstalledForPostgres16()) {
      return true;
    }
    _finishSetupProgress(
      title,
      '内置 PostgreSQL runtime 未包含 pgvector 扩展，请补齐后重试。',
      ok: false,
    );
    _showSnackBar('内置 PostgreSQL runtime 未包含 pgvector 扩展');
    return false;
  }

  Future<bool> _verifyPgvectorReadiness(String title) async {
    _setSetupProgress(title, 0.85, '启用 vector 扩展并初始化 schema', state: '安装中');
    final schemaCheck = await gateway.initSchemaDto();
    if (schemaCheck.okOrNull == false) {
      _finishSetupProgress(title, 'pgvector 初始化失败', ok: false);
      _showSnackBar('pgvector 初始化失败，请确认扩展已安装');
      return false;
    }

    _setSetupProgress(title, 0.95, '复查 pgvector 扩展', state: '检测中');
    final pgvectorCheck = await gateway.checkPgvectorDto();
    if (pgvectorCheck.okOrNull == true) return true;
    _finishSetupProgress(
      title,
      (pgvectorCheck.message ?? '').isNotEmpty
          ? (pgvectorCheck.message ?? '')
          : 'pgvector 尚未就绪',
      ok: false,
    );
    _showSnackBar('pgvector 尚未就绪，请安装扩展后重试');
    return false;
  }

  Future<void> _runPgvectorSetupWorkflow() async {
    const title = 'pgvector 检测';
    final localPgv = _detectPgvectorLocal();
    _appendLog('开始 pgvector 安装与配置流程（本地 pgvector: $localPgv）');

    try {
      if (!await _ensurePostgresReadyForPgvector(title)) {
        return;
      }
      if (!await _installPgvectorOnMacOSIfNeeded(title: title)) {
        return;
      }
      if (!await _verifyPgvectorReadiness(title)) {
        return;
      }

      _setSetupProgress(title, 1, 'pgvector 已安装并通过检测', state: '已配置');
      _showSnackBar('pgvector 已安装并通过检测');
      await refreshReadiness();
    } catch (error) {
      final message = _friendlySetupError(
        error,
        packageName: 'bundled-pgvector',
      );
      _finishSetupProgress(title, message, ok: false);
      _showSnackBar(message);
    }
  }
}
