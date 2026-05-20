part of '../desktop_shell.dart';

extension _DesktopShellExportResultState on _DesktopShellState {
  void _applyExportResultState({
    required _ExportTarget target,
    required String exportLabel,
    required bool exportedOk,
    required String actualPath,
    required String artifactId,
    required _ExportSyncResult syncedResult,
    required String exportedMessage,
  }) {
    _setShellState(() {
      exported = exportedOk;
      creationWorkflowPhase = exportedOk
          ? CreationWorkflowPhase.published
          : CreationWorkflowPhase.failed;
      exportResult = exportedOk
          ? ExportResultVm(
              kind: _artifactKindForTarget(target),
              localPath: actualPath,
              storageStatus: syncedResult.storageStatus,
              artifactId: artifactId,
              remoteUrl: syncedResult.remoteUrl,
              shareText: syncedResult.shareText,
              errorReason: syncedResult.errorReason,
            )
          : ExportResultVm(
              kind: _artifactKindForTarget(target),
              localPath: '',
              storageStatus: 'failed',
              errorReason: exportedMessage.trim(),
            );
      statusMessage = exported
          ? AppLocalizations.of(
              context,
            )!.exportResultSucceededStatus(exportLabel, actualPath)
          : AppLocalizations.of(context)!.exportResultFailedStatus(exportLabel);
    });
  }

  void _applyExportExceptionState({
    required _ExportTarget target,
    required String message,
  }) {
    _setShellState(() {
      exported = false;
      creationWorkflowPhase = CreationWorkflowPhase.failed;
      exportResult = ExportResultVm(
        kind: _artifactKindForTarget(target),
        localPath: '',
        storageStatus: 'failed',
        errorReason: message,
      );
      statusMessage = message;
    });
  }

  void _applyShareResultState(Map<String, dynamic> share) {
    final shareUrl = '${share['shareUrl'] ?? ''}'.trim();
    final current = exportResult;
    _setShellState(() {
      shareCreating = false;
      exportResult = current?.copyWith(
        storageStatus: shareUrl.isNotEmpty ? 'shared' : 'failed',
        remoteUrl: shareUrl,
        shareText: shareUrl.isNotEmpty
            ? AppLocalizations.of(context)!.generateExportShareText(shareUrl)
            : current.shareText,
        errorReason: shareUrl.isEmpty
            ? AppLocalizations.of(context)!.generateExportShareFailedStatus
            : '',
      );
      statusMessage = shareUrl.isNotEmpty
          ? AppLocalizations.of(context)!.generateExportShareCreatedStatus
          : AppLocalizations.of(context)!.generateExportShareFailedStatus;
    });
    _appendLog(statusMessage);
  }

  void _applyShareExceptionState(Object error) {
    final current = exportResult;
    final message = AppLocalizations.of(
      context,
    )!.generateExportShareExceptionMessage(error);
    _setShellState(() {
      shareCreating = false;
      exportResult = current?.copyWith(
        storageStatus: 'failed',
        errorReason: message,
      );
      statusMessage = message;
    });
    _appendLog(message);
  }
}
