part of '../../desktop_shell.dart';

extension _DesktopShellSetupPostgres on _DesktopShellState {
  Future<bool> _preparePostgresOnMacOS({
    required String title,
  }) async {
    if (!_bundledPostgresRuntimeAvailable()) {
      _finishSetupProgress(
        title,
        AppLocalizations.of(context)!.setupPostgresRuntimeNotDetected,
        ok: false,
      );
      _showSnackBar(AppLocalizations.of(context)!.setupBundledPostgresRuntimeMissing);
      return false;
    }
    _appendLog(AppLocalizations.of(context)!.setupRuntimeFoundInitialize);
    return _ensureBundledPostgresReady(title);
  }

  Future<void> _runPostgresSetupWorkflow() async {
    const title = 'PostgreSQL 配置';
    _appendLog(AppLocalizations.of(context)!.setupStartPostgresWorkflow);

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

      _setSetupProgress(title, 1, AppLocalizations.of(context)!.setupPostgresConfigured, state: AppLocalizations.of(context)!.setupConfigured);
      _showSnackBar(AppLocalizations.of(context)!.setupPostgresConfigured);
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
    _setSetupProgress(
      _sidecarSetupTitle,
      0.15,
      AppLocalizations.of(context)!.setupSidecarStarting,
      state: AppLocalizations.of(context)!.setupStatusStarting,
    );
    final sidecarReady = await _ensureSidecarRunning();
    if (!sidecarReady) {
      _finishSetupProgress(
        _sidecarSetupTitle,
        AppLocalizations.of(context)!.setupSidecarStartFailedNodeOrBundled,
        ok: false,
      );
      _showSnackBar(AppLocalizations.of(context)!.setupPostgresHandledButSidecarNotStarted);
      return false;
    }
    _finishSetupProgress(_sidecarSetupTitle, AppLocalizations.of(context)!.setupSidecarStarted, ok: true);

    _setSetupProgress(title, 0.78, AppLocalizations.of(context)!.setupCheckPostgresService, state: AppLocalizations.of(context)!.setupChecking);
    final postgres = await gateway.checkPostgresDto();
    if (postgres.okOrNull != true) {
      _finishSetupProgress(title, AppLocalizations.of(context)!.setupPostgresNotDetected, ok: false);
      _showSnackBar(AppLocalizations.of(context)!.setupPostgresNotReadyStartLocalService);
      return false;
    }

    _setSetupProgress(title, 0.92, AppLocalizations.of(context)!.setupInitDatabaseSchema, state: AppLocalizations.of(context)!.setupInitStarted);
    final schema = await gateway.initSchemaDto();
    if (schema.okOrNull == false) {
      final schemaMessage = schema.message ?? '';
      _finishSetupProgress(
        title,
        schemaMessage.isNotEmpty ? schemaMessage : AppLocalizations.of(context)!.setupInitDatabaseSchemaFailed,
        ok: false,
      );
      _showSnackBar(AppLocalizations.of(context)!.setupInitDatabaseSchemaFailed);
      return false;
    }
    return true;
  }
}
