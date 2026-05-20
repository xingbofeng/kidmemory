part of '../desktop_shell.dart';

extension _DesktopShellExportSync on _DesktopShellState {
  Future<_ExportSyncResult> _maybeSyncExportArtifact(String artifactId) async {
    final l10n = AppLocalizations.of(context)!;
    if (artifactId.isEmpty) {
      return _ExportSyncResult(
        storageStatus: 'local_only',
        errorReason: l10n.exportSyncS195,
      );
    }
    if (!supabaseStorage.configured) {
      return _ExportSyncResult.localOnly();
    }
    final childId = selectedChildId;
    if (childId == null || childId.isEmpty) {
      return _ExportSyncResult(
        storageStatus: 'local_only',
        errorReason: l10n.exportSyncS837,
      );
    }

    final enqueued = await gateway.enqueueExportArtifactSyncDto(
      artifactId: artifactId,
      childId: childId,
    );
    if (!enqueued.enqueuedValue) {
      return _ExportSyncResult(
        storageStatus: 'failed',
        errorReason: enqueued.reasonValue.isNotEmpty
            ? enqueued.reasonValue
            : l10n.exportSyncS337,
      );
    }
    final worker = await gateway.runStorageSyncDto(limit: 5);
    final storageStatus = worker.failedValue > 0
        ? 'failed'
        : worker.retriedValue > 0
        ? 'retry_wait'
        : 'synced';
    final share = await gateway.getExportArtifactShareDto(
      artifactId: artifactId,
    );
    return _ExportSyncResult(
      storageStatus: storageStatus,
      remoteUrl: share.urlValue.trim(),
      shareText: share.okValue ? share.textValue.trim() : '',
      errorReason: share.okValue
          ? ''
          : _stringOrDefault(
              share.messageValue,
              worker.failedValue > 0 ? l10n.exportSyncS157 : '',
            ),
    );
  }
}
