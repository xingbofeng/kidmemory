part of '../desktop_shell.dart';

extension _DesktopShellExportSync on _DesktopShellState {
  Future<_ExportSyncResult> _maybeSyncExportArtifact(String artifactId) async {
    if (artifactId.isEmpty) {
      return _ExportSyncResult(
        storageStatus: 'local_only',
        errorReason: 'sidecar 未返回导出物记录',
      );
    }
    if (!supabaseStorage.configured) {
      return _ExportSyncResult.localOnly();
    }
    final childId = selectedChildId;
    if (childId == null || childId.isEmpty) {
      return _ExportSyncResult(
        storageStatus: 'local_only',
        errorReason: '缺少孩子档案，暂不能同步导出物',
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
            : '同步入队失败',
      );
    }
    final worker = await gateway.runStorageSyncDto(limit: 5);
    final storageStatus = worker.failedValue > 0
        ? 'failed'
        : worker.retriedValue > 0
        ? 'retry_wait'
        : 'synced';
    final share = await gateway.getExportArtifactShareDto(artifactId: artifactId);
    return _ExportSyncResult(
      storageStatus: storageStatus,
      remoteUrl: share.urlValue.trim(),
      shareText: share.okValue ? share.textValue.trim() : '',
      errorReason: share.okValue
          ? ''
          : _stringOrDefault(
              share.messageValue,
              worker.failedValue > 0 ? 'Supabase Storage 同步失败' : '',
            ),
    );
  }
}
