part of '../desktop_shell.dart';

extension _DesktopShellAssetActions on _DesktopShellState {
  Future<void> _handleAssetLibraryChildChanged(String childId) async {
    _setShellState(() {
      selectedChildId = childId;
      selectedAssets.clear();
    });
    _invalidateCreationPlanForInputChange();
    await refreshDataset();
  }

  void _toggleSelectedAsset(String id) {
    _setShellState(() {
      selectedAssets.contains(id)
          ? selectedAssets.remove(id)
          : selectedAssets.add(id);
    });
    _invalidateCreationPlanForInputChange();
  }

  void _replaceSelectedAssets(Set<String> ids) {
    _setShellState(() {
      selectedAssets
        ..clear()
        ..addAll(ids);
    });
    _invalidateCreationPlanForInputChange();
  }

  Future<bool> _updateAssetFromLibrary(
    String id,
    AssetMetadataUpdate payload,
  ) async {
    final result = await gateway.updateAssetDto(
      assetId: id,
      payload: UpdateAssetInput(
        title: payload.title,
        description: payload.description,
        tags: payload.tags,
        capturedAt: payload.capturedAt,
        type: payload.type,
      ),
    );
    await refreshDataset();
    return result.hasAsset;
  }

  Future<bool> _deleteSingleAssetFromLibrary(String id) async {
    final result = await gateway.deleteAssetDto(assetId: id);
    selectedAssets.remove(id);
    _invalidateCreationPlanForInputChange();
    await refreshDataset();
    return result.okValue;
  }

  Future<int> _deleteSelectedAssetsFromLibrary() async {
    final visibleAssetIds = assets.map((asset) => asset.id).toSet();
    final ids = selectedAssets.where(visibleAssetIds.contains).toList();
    var deletedCount = 0;
    for (final id in ids) {
      final result = await gateway.deleteAssetDto(assetId: id);
      if (result.okValue) {
        selectedAssets.remove(id);
        deletedCount++;
      }
    }
    if (deletedCount > 0) {
      _invalidateCreationPlanForInputChange();
    }
    await refreshDataset();
    return deletedCount;
  }
}
