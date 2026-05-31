part of '../desktop_shell.dart';

extension _DesktopShellReadiness on _DesktopShellState {
  Future<void> refreshReadiness() async {
    try {
      final snapshot = await controllers.readiness.load();
      if (!mounted) return;
      final loadedUiConfig = _parseUiConfig(snapshot.uiConfig);
      _applyReadinessUiConfig(loadedUiConfig);

      if (!snapshot.available) {
        _markSidecarUnavailable(
          AppLocalizations.of(context)!.setupSidecarConfigUnavailable,
        );
        return;
      }
      _applyReadinessStorageAndPaths(snapshot.config);

      final checks = [snapshot.openai];
      final readyCount = checks.where((check) => check.isOk).length;
      final schemaReady = snapshot.schema.isOk;
      if (!schemaReady) {
        final schemaMessage = snapshot.schema.message ?? '';
        final message = schemaMessage.isNotEmpty
            ? schemaMessage
            : AppLocalizations.of(context)!.setupSchemaInitFailed;
        _appendLog(
          AppLocalizations.of(context)!.setupSchemaInitIncompleteLog(message),
        );
      }
      _setShellState(() {
        readinessMessage = schemaReady
            ? AppLocalizations.of(
                context,
              )!.setupReadinessCompleteMessage(readyCount + 1, 2)
            : AppLocalizations.of(context)!.setupSidecarStartedSchemaNotReady;
        readinessChecks = _buildReadinessChecks(openai: snapshot.openai);
      });
      if (schemaReady) {
        await refreshDataset();
      }
    } catch (error) {
      debugPrint('KidMemory readiness refresh failed: $error');
      if (!mounted) return;
      _markSidecarUnavailable(
        AppLocalizations.of(context)!.setupInitializationFailed(error),
      );
      return;
    }
  }
}
