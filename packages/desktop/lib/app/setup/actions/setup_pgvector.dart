part of '../../desktop_shell.dart';

extension _DesktopShellSetupPgvector on _DesktopShellState {
  Future<bool> _ensurePostgresReadyForPgvector(String title) async {
    _setSetupProgress(
      title,
      0.10,
      AppLocalizations.of(context)!.setupCheckPostgresConnection,
      state: AppLocalizations.of(context)!.setupChecking,
    );
    var postgres = await gateway.checkPostgresDto();
    if (postgres.okOrNull == true) return true;

    _setSetupProgress(
      title,
      0.18,
      AppLocalizations.of(context)!.setupPostgresNotReadyAutoInstall,
      state: AppLocalizations.of(context)!.setupInstalling,
    );
    _appendLog(AppLocalizations.of(context)!.setupPgvectorWaitForPostgres);
    await _runPostgresSetupWorkflow();

    _setSetupProgress(
      title,
      0.50,
      AppLocalizations.of(context)!.setupRecheckPostgresConnection,
      state: AppLocalizations.of(context)!.setupChecking,
    );
    postgres = await gateway.checkPostgresDto();
    if (postgres.okOrNull == true) return true;

    _finishSetupProgress(
      title,
      AppLocalizations.of(context)!.setupPostgresNotReadyNeedConfig,
      ok: false,
    );
    _showSnackBar(
      AppLocalizations.of(context)!.setupPostgresNotReadyCheckConfigRetry,
    );
    return false;
  }

  Future<bool> _installPgvectorOnMacOSIfNeeded({required String title}) async {
    if (!Platform.isMacOS) return true;
    _setSetupProgress(
      title,
      0.72,
      AppLocalizations.of(context)!.setupVerifyBuiltinPgvectorExtension,
      state: AppLocalizations.of(context)!.setupInstalling,
    );
    if (!_bundledPostgresRuntimeAvailable()) {
      _finishSetupProgress(
        title,
        AppLocalizations.of(
          context,
        )!.setupBundledPostgresRuntimeReleaseRequired,
        ok: false,
      );
      _showSnackBar(
        AppLocalizations.of(context)!.setupBundledPostgresRuntimeMissing,
      );
      return false;
    }
    if (_pgvectorInstalledForPostgres16()) {
      return true;
    }
    _finishSetupProgress(
      title,
      AppLocalizations.of(context)!.setupBuiltinPostgresNoPgvectorInstruction,
      ok: false,
    );
    _showSnackBar(AppLocalizations.of(context)!.setupBuiltinPostgresNoPgvector);
    return false;
  }

  Future<bool> _verifyPgvectorReadiness(String title) async {
    _setSetupProgress(
      title,
      0.85,
      AppLocalizations.of(context)!.setupEnableVectorExtensionAndInit,
      state: AppLocalizations.of(context)!.setupInstalling,
    );
    final schemaCheck = await gateway.initSchemaDto();
    if (schemaCheck.okOrNull == false) {
      _finishSetupProgress(
        title,
        AppLocalizations.of(context)!.setupPgvectorInitFailed,
        ok: false,
      );
      _showSnackBar(
        AppLocalizations.of(context)!.setupPgvectorInitFailedExtMissing,
      );
      return false;
    }

    _setSetupProgress(
      title,
      0.95,
      AppLocalizations.of(context)!.setupRecheckPgvectorExtension,
      state: AppLocalizations.of(context)!.setupChecking,
    );
    final pgvectorCheck = await gateway.checkPgvectorDto();
    if (pgvectorCheck.okOrNull == true) return true;
    _finishSetupProgress(
      title,
      (pgvectorCheck.message ?? '').isNotEmpty
          ? (pgvectorCheck.message ?? '')
          : AppLocalizations.of(context)!.setupPgvectorNotReady,
      ok: false,
    );
    _showSnackBar(
      AppLocalizations.of(context)!.setupPgvectorNotReadyInstallExtRetry,
    );
    return false;
  }

  Future<void> _runPgvectorSetupWorkflow() async {
    final title = AppLocalizations.of(context)!.setupPgvectorTitle;
    final localPgv = _detectPgvectorLocal();
    _appendLog(
      AppLocalizations.of(
        context,
      )!.setupPgvectorWorkflowStartedLog('$localPgv'),
    );

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

      _setSetupProgress(
        title,
        1,
        AppLocalizations.of(context)!.setupPgvectorReady,
        state: AppLocalizations.of(context)!.setupConfigured,
      );
      _showSnackBar(AppLocalizations.of(context)!.setupPgvectorReady);
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
