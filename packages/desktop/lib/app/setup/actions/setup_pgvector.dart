part of '../../desktop_shell.dart';

extension _DesktopShellSetupPgvector on _DesktopShellState {
  Future<bool> _ensurePostgresReadyForPgvector(String title) async {
    final l10n = AppLocalizations.of(context)!;
    _setSetupProgress(
      title,
      0.10,
      l10n.setupCheckPostgresConnection,
      state: l10n.setupChecking,
    );
    var postgres = await gateway.checkPostgresDto();
    if (postgres.okOrNull == true) return true;

    _setSetupProgress(
      title,
      0.18,
      l10n.setupPostgresNotReadyAutoInstall,
      state: l10n.setupInstalling,
    );
    _appendLog(l10n.setupPgvectorWaitForPostgres);
    await _runPostgresSetupWorkflow();

    _setSetupProgress(
      title,
      0.50,
      l10n.setupRecheckPostgresConnection,
      state: l10n.setupChecking,
    );
    postgres = await gateway.checkPostgresDto();
    if (postgres.okOrNull == true) return true;

    _finishSetupProgress(
      title,
      l10n.setupPostgresNotReadyNeedConfig,
      ok: false,
    );
    _showSnackBar(l10n.setupPostgresNotReadyCheckConfigRetry);
    return false;
  }

  Future<bool> _installPgvectorOnMacOSIfNeeded({required String title}) async {
    final l10n = AppLocalizations.of(context)!;
    if (!Platform.isMacOS) return true;
    _setSetupProgress(
      title,
      0.72,
      l10n.setupVerifyBuiltinPgvectorExtension,
      state: l10n.setupInstalling,
    );
    if (!_bundledPostgresRuntimeAvailable()) {
      _finishSetupProgress(
        title,
        l10n.setupBundledPostgresRuntimeReleaseRequired,
        ok: false,
      );
      _showSnackBar(l10n.setupBundledPostgresRuntimeMissing);
      return false;
    }
    if (_pgvectorInstalledForPostgres16()) {
      return true;
    }
    _finishSetupProgress(
      title,
      l10n.setupBuiltinPostgresNoPgvectorInstruction,
      ok: false,
    );
    _showSnackBar(l10n.setupBuiltinPostgresNoPgvector);
    return false;
  }

  Future<bool> _verifyPgvectorReadiness(String title) async {
    final l10n = AppLocalizations.of(context)!;
    _setSetupProgress(
      title,
      0.85,
      l10n.setupEnableVectorExtensionAndInit,
      state: l10n.setupInstalling,
    );
    final schemaCheck = await gateway.initSchemaDto();
    if (schemaCheck.okOrNull == false) {
      _finishSetupProgress(title, l10n.setupPgvectorInitFailed, ok: false);
      _showSnackBar(l10n.setupPgvectorInitFailedExtMissing);
      return false;
    }

    _setSetupProgress(
      title,
      0.95,
      l10n.setupRecheckPgvectorExtension,
      state: l10n.setupChecking,
    );
    final pgvectorCheck = await gateway.checkPgvectorDto();
    if (pgvectorCheck.okOrNull == true) return true;
    _finishSetupProgress(
      title,
      (pgvectorCheck.message ?? '').isNotEmpty
          ? (pgvectorCheck.message ?? '')
          : l10n.setupPgvectorNotReady,
      ok: false,
    );
    _showSnackBar(l10n.setupPgvectorNotReadyInstallExtRetry);
    return false;
  }

  Future<void> _runPgvectorSetupWorkflow() async {
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.setupPgvectorTitle;
    final localPgv = _detectPgvectorLocal();
    _appendLog(l10n.setupPgvectorWorkflowStartedLog('$localPgv'));

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
        l10n.setupPgvectorReady,
        state: l10n.setupConfigured,
      );
      _showSnackBar(l10n.setupPgvectorReady);
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
