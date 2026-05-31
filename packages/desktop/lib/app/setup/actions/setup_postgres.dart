part of '../../desktop_shell.dart';

extension _DesktopShellSetupPostgres on _DesktopShellState {
  Future<bool> _preparePostgresOnMacOS({required String title}) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_bundledPostgresRuntimeAvailable()) {
      _finishSetupProgress(
        title,
        l10n.setupPostgresRuntimeNotDetected,
        ok: false,
      );
      _showSnackBar(l10n.setupBundledPostgresRuntimeMissing);
      return false;
    }
    _appendLog(l10n.setupRuntimeFoundInitialize);
    return _ensureBundledPostgresReady(title);
  }

  Future<void> _runPostgresSetupWorkflow() async {
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.setupPostgresTitle;
    _appendLog(l10n.setupStartPostgresWorkflow);

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

      _setSetupProgress(
        title,
        1,
        l10n.setupPostgresConfigured,
        state: l10n.setupConfigured,
      );
      _showSnackBar(l10n.setupPostgresConfigured);
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
    final l10n = AppLocalizations.of(context)!;
    final sidecarSetupTitle = _sidecarSetupTitle(context);
    _setSetupProgress(
      sidecarSetupTitle,
      0.15,
      l10n.setupSidecarStarting,
      state: l10n.setupStatusStarting,
    );
    final sidecarReady = await _ensureSidecarRunning();
    if (!sidecarReady) {
      _finishSetupProgress(
        sidecarSetupTitle,
        l10n.setupSidecarStartFailedNodeOrBundled,
        ok: false,
      );
      _showSnackBar(l10n.setupPostgresHandledButSidecarNotStarted);
      return false;
    }
    _finishSetupProgress(sidecarSetupTitle, l10n.setupSidecarStarted, ok: true);

    _setSetupProgress(
      title,
      0.78,
      l10n.setupCheckPostgresService,
      state: l10n.setupChecking,
    );
    final postgres = await gateway.checkPostgresDto();
    if (postgres.okOrNull != true) {
      _finishSetupProgress(title, l10n.setupPostgresNotDetected, ok: false);
      _showSnackBar(l10n.setupPostgresNotReadyStartLocalService);
      return false;
    }

    _setSetupProgress(
      title,
      0.92,
      l10n.setupInitDatabaseSchema,
      state: l10n.setupInitStarted,
    );
    final schema = await gateway.initSchemaDto();
    if (schema.okOrNull == false) {
      final schemaMessage = schema.message ?? '';
      _finishSetupProgress(
        title,
        schemaMessage.isNotEmpty
            ? schemaMessage
            : l10n.setupInitDatabaseSchemaFailed,
        ok: false,
      );
      _showSnackBar(l10n.setupInitDatabaseSchemaFailed);
      return false;
    }
    return true;
  }
}
