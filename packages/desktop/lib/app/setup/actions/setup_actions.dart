part of '../../desktop_shell.dart';

extension _DesktopShellSetupActions on _DesktopShellState {
  void _runSetupAction(SetupCheckVm check) {
    final action = check.action.trim();
    final isOpenAiConfig =
        check.title == AppLocalizations.of(context)!.setupOpenAiTitle;
    final allowOpenAiConfigWhenBlocked =
        isOpenAiConfig &&
        action.contains(AppLocalizations.of(context)!.actionConfigure);
    if (!check.actionEnabled) {
      if (allowOpenAiConfigWhenBlocked) {
        unawaited(_configureOpenAI());
        return;
      }
      _showSnackBar(
        AppLocalizations.of(context)!.setupCompletePreviousStepFirst,
      );
      return;
    }
    if (action == AppLocalizations.of(context)!.actionRefreshChecks) {
      unawaited(refreshReadiness());
      return;
    }
    if (action.contains(AppLocalizations.of(context)!.actionTest) ||
        action.contains(AppLocalizations.of(context)!.actionCheck)) {
      unawaited(_runTargetedSetupCheck(check.title));
      return;
    }
    if (action.contains(AppLocalizations.of(context)!.actionInstall)) {
      unawaited(_runInstallAndConfigure(check.title));
      return;
    }
    if (action.contains(AppLocalizations.of(context)!.actionStart)) {
      if (check.title == AppLocalizations.of(context)!.setupPostgresTitle) {
        unawaited(_runPostgresSetupWorkflow());
        return;
      }
      if (check.title == _sidecarSetupTitle(context)) {
        unawaited(_runSidecarSetupWorkflow());
        return;
      }
      _showSnackBar(
        AppLocalizations.of(context)!.setupAutoStartUnsupported(check.title),
      );
      return;
    }
    if (action.contains(AppLocalizations.of(context)!.actionDirectory)) {
      if (check.title == AppLocalizations.of(context)!.setupLocalDataDirTitle) {
        unawaited(_selectLocalDataRoot());
        return;
      }
      _showSnackBar(AppLocalizations.of(context)!.setupDirectoryCannotEdit);
      return;
    }
    if (action.contains(AppLocalizations.of(context)!.actionConfigure)) {
      if (check.title == AppLocalizations.of(context)!.setupPostgresTitle) {
        unawaited(_runPostgresSetupWorkflow());
        return;
      }
      if (check.title == AppLocalizations.of(context)!.setupOpenAiTitle) {
        unawaited(_configureOpenAI());
        return;
      }
      if (check.title == AppLocalizations.of(context)!.setupLocalDataDirTitle) {
        unawaited(_selectLocalDataRoot());
        return;
      }
      _showSnackBar(AppLocalizations.of(context)!.setupNoConfigDialog);
      return;
    }
    _showSnackBar(
      AppLocalizations.of(context)!.setupConfigItemRecorded(check.title),
    );
  }

  Future<void> _runInstallAndConfigure(String checkTitle) async {
    if (checkTitle == AppLocalizations.of(context)!.setupPostgresTitle) {
      await _runPostgresSetupWorkflow();
      return;
    }
    if (checkTitle == _sidecarSetupTitle(context)) {
      await _runSidecarSetupWorkflow();
      return;
    }
    if (checkTitle == AppLocalizations.of(context)!.setupPgvectorTitle) {
      await _runPgvectorSetupWorkflow();
      return;
    }
    _showSnackBar(AppLocalizations.of(context)!.setupNoAutoInstallFlow);
  }
}
