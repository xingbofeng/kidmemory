part of '../../desktop_shell.dart';

extension _DesktopShellSetupTargetedChecks on _DesktopShellState {
  Future<void> _runTargetedSetupCheck(String checkTitle) async {
    _appendLog(
      AppLocalizations.of(context)!.setupManualCheckTriggeredLog(checkTitle),
    );
    final checkResult = await (() async {
      if (checkTitle == AppLocalizations.of(context)!.setupPostgresTitle) {
        return await gateway.checkPostgresDto();
      }
      if (checkTitle == _sidecarSetupTitle(context)) {
        final ready = await _sidecarApiReady();
        return ReadinessCheckDto.fromJson({
          'ok': ready,
          'message': ready
              ? AppLocalizations.of(context)!.setupSidecarConnected
              : AppLocalizations.of(context)!.setupSidecarDisconnected,
        });
      }
      if (checkTitle == AppLocalizations.of(context)!.setupPgvectorTitle) {
        return await gateway.checkPgvectorDto();
      }
      if (checkTitle == AppLocalizations.of(context)!.setupOpenAiTitle) {
        return await gateway.checkOpenAiDto();
      }
      return ReadinessCheckDto.fromJson(const {});
    })();
    final message = checkResult.message ?? '';
    if (checkResult.okOrNull == null && message.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.setupCheckRequestNoResult);
    } else {
      final success = checkResult.okOrNull == true;
      final displayMessage = message.trim().isEmpty
          ? (success
                ? AppLocalizations.of(context)!.setupTestConnectionSuccess
                : AppLocalizations.of(context)!.setupTestConnectionFailed)
          : message.trim();
      _showSnackBar(
        success
            ? displayMessage
            : AppLocalizations.of(
                context,
              )!.setupTestConnectionFailedWithMessage(displayMessage),
      );
    }
    await refreshReadiness();
  }
}
