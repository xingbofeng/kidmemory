part of '../../desktop_shell.dart';

extension _DesktopShellSetupFlow on _DesktopShellState {
  Future<void> _runSidecarSetupWorkflow() async {
    _setSetupProgress(
      _sidecarSetupTitle,
      0.15,
      '正在启动 Sidecar...',
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
