part of '../desktop_shell.dart';

extension _DesktopShellDatasetActions on _DesktopShellState {
  Future<void> refreshDataset() async {
    final snapshot = await controllers.dataset.refresh(
      selectedChildId: selectedChildId,
    );
    final assetItems = snapshot.assetRows.map(_assetFromRecord).toList();
    if (!mounted) return;
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
        : '搜索完成，共 ${data.totalValue} 条';
    return AssetSearchResult(assets: results, statusMessage: status);
  }

  Future<String> refreshSearchIndexingMessage() async {
    final childId = selectedChildId;
    if (childId == null || childId.isEmpty) return '请先选择孩子档案';
    final data = await gateway.getIndexingStatusDto(childId: childId);
    final indexing =
        data.pendingValue + data.runningValue + data.retryWaitValue;
    final base = '可语义搜索 ${data.searchableValue} · 索引中 $indexing';
    return data.failedValue > 0 ? '$base · 失败 ${data.failedValue}' : base;
  }

  Future<void> importSampleDataset() async {
    if (sampleImporting) return;
    _setShellState(() {
      sampleImporting = true;
      sampleImportFailed = false;
    });
    _appendLog('开始导入示例数据集');
    _showSnackBar('正在导入示例数据集...');
    try {
      final result = await gateway.importSampleDatasetDto();
      if (!mounted) return;
      if (result.raw.isEmpty) {
        _setShellState(() {
          sampleImported = false;
          sampleImportFailed = true;
        });
        _appendLog('示例数据集导入失败：sidecar 无响应或数据库未就绪');
        _showSnackBar('导入失败：Sidecar 未连接或数据库未就绪');
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
            ? '示例数据集导入完成：${result.assetCountValue} 个素材'
            : '示例数据集导入未完成：${jsonEncode(result.raw)}',
      );
      _showSnackBar(imported ? '示例数据集已导入，素材库已刷新' : '示例数据集导入未完成，请检查 sidecar');
    } catch (error) {
      if (!mounted) return;
      _setShellState(() {
        sampleImportFailed = true;
      });
      _appendLog('示例数据集导入异常：$error');
      _showSnackBar('示例数据集导入失败：$error');
    } finally {
      if (mounted) _setShellState(() => sampleImporting = false);
    }
  }
}
