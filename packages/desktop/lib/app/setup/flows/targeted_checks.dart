part of '../../desktop_shell.dart';

extension _DesktopShellSetupTargetedChecks on _DesktopShellState {
  Future<void> _runTargetedSetupCheck(String checkTitle) async {
    final l10n = AppLocalizations.of(context)!;
    final sidecarSetupTitle = _sidecarSetupTitle(context);
    _appendLog(l10n.setupManualCheckTriggeredLog(checkTitle));
    final checkResult = await (() async {
      if (checkTitle == l10n.setupPostgresTitle) {
        return await gateway.checkPostgresDto();
      }
      if (checkTitle == sidecarSetupTitle) {
        final ready = await _sidecarApiReady();
        return ReadinessCheckDto.fromJson({
          'ok': ready,
          'message': ready
              ? l10n.setupSidecarConnected
              : l10n.setupSidecarDisconnected,
        });
      }
      if (checkTitle == l10n.setupPgvectorTitle) {
        return await gateway.checkPgvectorDto();
      }
      if (checkTitle == l10n.setupOpenAiTitle) {
        return await gateway.checkOpenAiDto();
      }
      return ReadinessCheckDto.fromJson(const {});
    })();
    if (!mounted) return;
    final message = checkResult.message ?? '';
    if (checkResult.okOrNull == null && message.isEmpty) {
      _showSnackBar(l10n.setupCheckRequestNoResult);
    } else {
      final success = checkResult.okOrNull == true;
      final displayMessage = message.trim().isEmpty
          ? (success
                ? l10n.setupTestConnectionSuccess
                : l10n.setupTestConnectionFailed)
          : message.trim();
      _showSnackBar(
        success
            ? displayMessage
            : l10n.setupTestConnectionFailedWithMessage(displayMessage),
      );
    }
    await refreshReadiness();
  }
}
