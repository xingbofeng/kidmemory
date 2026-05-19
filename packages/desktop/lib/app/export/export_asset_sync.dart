part of '../desktop_shell.dart';

extension _DesktopShellExportAssetSync on _DesktopShellState {
  Future<bool> syncAssetToStorage(String assetId) async {
    if (!supabaseStorage.configured) {
      _showSnackBar(AppLocalizations.of(context)!.exportAssetSyncS862);
      return false;
    }
    final result = await gateway.enqueueAssetSyncDto(assetId: assetId);
    if (!result.enqueuedValue) return false;
    await gateway.runStorageSyncDto(limit: 3);
    await refreshDataset();
    return true;
  }
}
