part of '../desktop_shell.dart';

extension _DesktopShellExportResultState on _DesktopShellState {
  void _applyExportResultState({
    required _ExportTarget target,
    required String exportLabel,
    required bool exportedOk,
    required String actualPath,
    required _ExportSyncResult syncedResult,
    required String exportedMessage,
  }) {
    _setShellState(() {
      exported = exportedOk;
      exportResult = exportedOk
          ? ExportResultVm(
              kind: _artifactKindForTarget(target),
              localPath: actualPath,
              storageStatus: syncedResult.storageStatus,
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
          ? '$exportLabel 已导出：$actualPath'
          : '$exportLabel 导出失败，可重试';
    });
  }

  void _applyExportExceptionState({
    required _ExportTarget target,
    required String message,
  }) {
    _setShellState(() {
      exported = false;
      exportResult = ExportResultVm(
        kind: _artifactKindForTarget(target),
        localPath: '',
        storageStatus: 'failed',
        errorReason: message,
      );
      statusMessage = message;
    });
  }
}
