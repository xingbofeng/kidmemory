part of '../../desktop_shell.dart';

extension _DesktopShellSetupFlow on _DesktopShellState {
  Future<void> _runSidecarSetupWorkflow() async {
    final localPg = _detectPgLocal();
    if (localPg != _PgLocalStatus.running) {
      _appendLog('本地 PostgreSQL 未确认就绪，仍将尝试启动 Sidecar。');
    }

    _setSetupProgress(
      _sidecarSetupTitle,
      0.15,
      localPg == _PgLocalStatus.running
          ? '正在启动 Sidecar...'
          : '正在启动 Sidecar，并继续检测 PostgreSQL 配置...',
      state: '启动中',
    );
    final ready = await _ensureSidecarRunning();
    if (!ready) {
      _finishSetupProgress(
        _sidecarSetupTitle,
        'Sidecar 未能启动，请检查 Node.js 或 bundled sidecar',
        ok: false,
      );
      _showSnackBar('Sidecar 未能启动');
      return;
    }
    _finishSetupProgress(_sidecarSetupTitle, 'Sidecar 已启动', ok: true);
    await refreshReadiness();
  }
}
