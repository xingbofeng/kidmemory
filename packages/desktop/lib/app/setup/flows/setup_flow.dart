part of '../../desktop_shell.dart';

extension _DesktopShellSetupFlow on _DesktopShellState {
  Future<void> _runSidecarSetupWorkflow() async {
    _setSetupProgress(
      _sidecarSetupTitle(context),
      0.15,
      AppLocalizations.of(context)!.setupSidecarStarting,
      state: AppLocalizations.of(context)!.setupStatusStarting,
    );
    final ready = await _ensureSidecarRunning();
    if (!ready) {
      _finishSetupProgress(
        _sidecarSetupTitle(context),
        AppLocalizations.of(context)!.setupSidecarStartFailedNodeOrBundled,
        ok: false,
      );
      _showSnackBar(AppLocalizations.of(context)!.setupSidecarStartFailed);
      return;
    }
    _finishSetupProgress(
      _sidecarSetupTitle(context),
      AppLocalizations.of(context)!.setupSidecarStarted,
      ok: true,
    );
    await refreshReadiness();
  }
}
