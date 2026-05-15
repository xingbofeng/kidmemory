part of '../desktop_shell.dart';

extension _DesktopShellDatasetSample on _DesktopShellState {
  Future<void> resetSampleDataset() async {
    final targetChild = _resolveSampleChildId();
    if (targetChild == null) {
      _showSnackBar('未检测到示例数据档案，请先导入示例数据集');
      return;
    }
    final result = await gateway.resetSampleDatasetDto(childId: targetChild);
    if (!mounted) return;
    _setShellState(() => sampleImported = false);
    _appendLog('示例数据已重置：$targetChild，移除 ${result.deletedAssets} 个素材');
    await refreshDataset();
  }

  String? _resolveSampleChildId() {
    final selected = selectedChildId;
    if (selected != null && selected.startsWith('sample-child')) {
      return selected;
    }
    for (final child in children) {
      if (child.id.startsWith('sample-child')) return child.id;
    }
    return null;
  }
}
