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
      final visibleAssetIds = assetItems.map((asset) => asset.id).toSet();
      selectedAssets.removeWhere((id) => !visibleAssetIds.contains(id));
    });
  }

  Future<AssetSearchResponse> searchAssetsInline(
    AssetSearchRequest request,
  ) async {
    final data = await gateway.searchAssetsDto(
      payload: AssetSearchRequestPayload(
        childId: request.childId,
        query: request.query,
        types: request.type == 'all' ? const [] : [request.type],
      ),
    );
    final results = data.items
        .map((item) => _assetFromRecord(item.asset, matchReasons: item.reasons))
        .toList();
    final status = data.code.isNotEmpty
        ? (data.message.isNotEmpty ? data.message : data.code)
        : '搜索完成，共 ${data.total} 条';
    return AssetSearchResponse(assets: results, statusMessage: status);
  }

  Future<String> refreshSearchIndexingMessage() async {
    final childId = selectedChildId;
    if (childId == null || childId.isEmpty) return '请先选择孩子档案';
    final data = await gateway.getIndexingStatusDto(childId: childId);
    final indexing = data.pending + data.running + data.retryWait;
    final base = '可语义搜索 ${data.searchable} · 索引中 $indexing';
    return data.failed > 0 ? '$base · 失败 ${data.failed}' : base;
  }

  Future<void> importSampleDataset() async {
    if (sampleImporting) return;
    _setShellState(() => sampleImporting = true);
    _appendLog('开始导入示例数据集');
    _showSnackBar('正在导入示例数据集...');
    try {
      final result = await gateway.importSampleDatasetDto();
      if (!mounted) return;
      if (result.raw.isEmpty) {
        _setShellState(() => sampleImported = false);
        _appendLog('示例数据集导入失败：sidecar 无响应或数据库未就绪');
        _showSnackBar('导入失败：Sidecar 未连接或数据库未就绪');
        return;
      }
      final imported = result.ok || result.childId.isNotEmpty;
      _setShellState(() {
        sampleImported = imported;
        if (result.childId.isNotEmpty) {
          selectedChildId = result.childId;
        }
      });
      await refreshDataset();
      if (!mounted) return;
      _appendLog(
        imported
            ? '示例数据集导入完成：${result.assetCount} 个素材'
            : '示例数据集导入未完成：${jsonEncode(result.raw)}',
      );
      _showSnackBar(imported ? '示例数据集已导入，素材库已刷新' : '示例数据集导入未完成，请检查 sidecar');
    } catch (error) {
      if (!mounted) return;
      _appendLog('示例数据集导入异常：$error');
      _showSnackBar('示例数据集导入失败：$error');
    } finally {
      if (mounted) _setShellState(() => sampleImporting = false);
    }
  }

}
