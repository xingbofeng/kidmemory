part of '../desktop_shell.dart';

extension _DesktopShellExportAssetSync on _DesktopShellState {
  Future<bool> syncAssetToStorage(String assetId) async {
    if (!supabaseStorage.configured) {
      _showSnackBar('请先配置 Supabase Storage');
      return false;
    }
    final result = await gateway.enqueueAssetSyncDto(assetId: assetId);
    if (!result.enqueued) return false;
    await gateway.runStorageSyncDto(limit: 3);
    await refreshDataset();
    return true;
  }
}
