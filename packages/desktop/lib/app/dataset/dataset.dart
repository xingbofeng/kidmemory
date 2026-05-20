part of '../desktop_shell.dart';

extension _DesktopShellDatasetActions on _DesktopShellState {
  Future<void> refreshDataset() async {
    final snapshot = await controllers.dataset.refresh(
      selectedChildId: selectedChildId,
    );
    final assetItems = snapshot.assetRows.map(_assetFromRecord).toList();
    if (!mounted) return;
    final previousSelectedAssets = Set<String>.from(selectedAssets);
    _setShellState(() {
      children = snapshot.children;
      selectedChildId = snapshot.activeChildId;
      assets = assetItems;
      if (_hasSampleChild(snapshot.children)) {
        sampleImported = true;
        sampleImportFailed = false;
      }
      final visibleAssetIds = assetItems.map((asset) => asset.id).toSet();
      selectedAssets.removeWhere((id) => !visibleAssetIds.contains(id));
    });
    if (!_setEquals(previousSelectedAssets, selectedAssets)) {
      _invalidateCreationPlanForInputChange();
    }
  }

  bool _setEquals(Set<String> left, Set<String> right) {
    if (left.length != right.length) return false;
    return left.containsAll(right);
  }

  bool _hasSampleChild(List<ChildVm> childItems) {
    for (final child in childItems) {
      if (child.id.startsWith('sample-child')) return true;
    }
    return false;
  }

  Future<AssetSearchResult> searchAssetsInline(AssetSearchInput request) async {
    final data = await gateway.searchAssetsDto(
      payload: AssetSearchInputPayload(
        childId: request.childId,
        query: request.query,
        page: 1,
        pageSize: 30,
        filters: request.type == 'all'
            ? null
            : <String, Object>{
                'types': <Object>[request.type],
              },
      ),
    );
    final results = data.itemsValue
        .map(
          (item) => _assetFromRecord(
            item.assetValue,
            matchReasons: item.reasonsValue,
          ),
        )
        .toList();
    final status = data.codeValue.isNotEmpty
        ? (data.messageValue.isNotEmpty ? data.messageValue : data.codeValue)
        : AppLocalizations.of(
            context,
          )!.datasetSearchCompletedStatus(data.totalValue);
    return AssetSearchResult(assets: results, statusMessage: status);
  }

  Future<String> refreshSearchIndexingMessage() async {
    final childId = selectedChildId;
    if (childId == null || childId.isEmpty) {
      return AppLocalizations.of(context)!.datasetS857;
    }
    final data = await gateway.getIndexingStatusDto(childId: childId);
    final indexing =
        data.pendingValue + data.runningValue + data.retryWaitValue;
    final base = AppLocalizations.of(
      context,
    )!.datasetSearchIndexingBaseStatus(data.searchableValue, indexing);
    return data.failedValue > 0
        ? AppLocalizations.of(
            context,
          )!.datasetSearchIndexingFailedStatus(base, data.failedValue)
        : base;
  }

  Future<void> importSampleDataset() async {
    if (sampleImporting) return;
    _setShellState(() {
      sampleImporting = true;
      sampleImportFailed = false;
    });
    _appendLog(AppLocalizations.of(context)!.datasetS469);
    _showSnackBar(AppLocalizations.of(context)!.datasetS657);
    try {
      final result = await gateway.importSampleDatasetDto();
      if (!mounted) return;
      if (result.raw.isEmpty) {
        _setShellState(() {
          sampleImported = false;
          sampleImportFailed = true;
        });
        _appendLog(AppLocalizations.of(context)!.datasetS776);
        _showSnackBar(AppLocalizations.of(context)!.datasetS391);
        return;
      }
      final imported = result.okValue || result.childIdValue.isNotEmpty;
      _setShellState(() {
        sampleImported = imported;
        sampleImportFailed = !imported;
        if (result.childIdValue.isNotEmpty) {
          selectedChildId = result.childIdValue;
        }
      });
      await refreshDataset();
      if (!mounted) return;
      _appendLog(
        imported
            ? AppLocalizations.of(
                context,
              )!.datasetSampleImportCompletedLog(result.assetCountValue)
            : AppLocalizations.of(
                context,
              )!.datasetSampleImportIncompleteLog(jsonEncode(result.raw)),
      );
      _showSnackBar(
        imported
            ? AppLocalizations.of(context)!.datasetS781
            : AppLocalizations.of(context)!.datasetS779,
      );
    } catch (error) {
      if (!mounted) return;
      _setShellState(() {
        sampleImportFailed = true;
      });
      _appendLog(
        AppLocalizations.of(context)!.datasetSampleImportExceptionLog(error),
      );
      _showSnackBar(
        AppLocalizations.of(context)!.datasetSampleImportFailedWithError(error),
      );
    } finally {
      if (mounted) _setShellState(() => sampleImporting = false);
    }
  }
}
