part of '../../desktop_shell.dart';

extension _DesktopShellSetupFlow on _DesktopShellState {
  Future<void> _runSidecarSetupWorkflow() async {
    final l10n = AppLocalizations.of(context)!;
    final sidecarSetupTitle = _sidecarSetupTitle(context);
    _setSetupProgress(
      sidecarSetupTitle,
      0.15,
      l10n.setupSidecarStarting,
      state: l10n.setupStatusStarting,
    );
    final ready = await _ensureSidecarRunning();
    if (!mounted) return;
    if (!ready) {
      _finishSetupProgress(
        sidecarSetupTitle,
        l10n.setupSidecarStartFailedNodeOrBundled,
        ok: false,
      );
      _showSnackBar(l10n.setupSidecarStartFailed);
      return;
    }
    _finishSetupProgress(sidecarSetupTitle, l10n.setupSidecarStarted, ok: true);
    await refreshReadiness();
  }
}
