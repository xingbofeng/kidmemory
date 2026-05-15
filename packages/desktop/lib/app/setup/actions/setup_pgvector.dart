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

  Future<bool> _installPgvectorOnMacOSIfNeeded({
    required String title,
    required _PgvectorLocalStatus localStatus,
  }) async {
    if (!Platform.isMacOS) return true;
    final brew = _findExecutable('brew');
    if (brew == null) {
      _finishSetupProgress(
        title,
        '未找到 Homebrew，暂时无法自动安装 pgvector',
        ok: false,
      );
      _showSnackBar('未找到 Homebrew，无法自动安装 pgvector');
      return false;
    }
    await _ensureHomebrewWritable(brew, packageName: 'pgvector');

    if (localStatus == _PgvectorLocalStatus.notInstalled) {
      _setSetupProgress(title, 0.55, '正在通过 Homebrew 安装 pgvector...', state: '安装中');
      final tracker = _BrewPhaseTracker(
        baseProgress: 0.55,
        maxProgress: 0.78,
        onUpdate: (progress, label) {
          if (!mounted) return;
          _setSetupProgress(title, progress, label, state: '安装中');
        },
      );
      await _runSetupCommandStreaming(brew, [
        'install',
        'pgvector',
      ], onOutput: (line, kind) => tracker.feed(line));
    } else {
      _setSetupProgress(
        title,
        0.72,
        'pgvector 已安装，检查 PostgreSQL 16 扩展文件',
        state: '安装中',
      );
    }

    if (!_pgvectorInstalledForPostgres16()) {
      _setSetupProgress(
        title,
        0.78,
        'Homebrew 未提供 PG16 扩展文件，正在按官方源码编译安装',
        state: '安装中',
      );
      await _installPgvectorFromSourceForPostgres16();
    }
    return true;
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
      pgvectorCheck.message.isNotEmpty ? pgvectorCheck.message : 'pgvector 尚未就绪',
      ok: false,
    );
    _showSnackBar('pgvector 尚未就绪，请安装扩展后重试');
    return false;
  }

  Future<void> _runPgvectorSetupWorkflow() async {
    const title = 'pgvector 检测';
    final localPg = _detectPgLocal();
    final localV = _detectPgvectorLocal();
    _appendLog('开始 pgvector 安装与配置流程（本地 PG: $localPg, pgvector: $localV）');

    try {
      if (!await _ensurePostgresReadyForPgvector(title)) {
        return;
      }
      if (!await _installPgvectorOnMacOSIfNeeded(
        title: title,
        localStatus: localV,
      )) {
        return;
      }
      if (!await _verifyPgvectorReadiness(title)) {
        return;
      }

      _setSetupProgress(title, 1, 'pgvector 已安装并通过检测', state: '已配置');
      _showSnackBar('pgvector 已安装并通过检测');
      await refreshReadiness();
    } catch (error) {
      final message = _friendlySetupError(error, packageName: 'pgvector');
      _finishSetupProgress(title, message, ok: false);
      _showSnackBar(message);
    }
  }
}
