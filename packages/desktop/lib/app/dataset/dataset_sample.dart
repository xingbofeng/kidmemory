part of '../desktop_shell.dart';

extension _DesktopShellDatasetSample on _DesktopShellState {
  void browseSampleAssets() {
    _selectSampleChildIfAvailable();
    _setShellState(() => step = AppStep.assets);
  }

  void generateSampleBook() {
    _selectSampleChildIfAvailable();
    _setShellState(() {
      generationTemplate = '温暖童趣';
      generationPageSize = 'A4 竖版  210 × 297 mm';
      generationStyle = '温暖童趣  亲切温暖，适合儿童阅读';
      step = AppStep.generate;
    });
  }

  Future<void> _confirmResetSampleDataset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确定要重置示例数据吗？'),
        content: const Text('这会删除当前示例档案和示例素材，并重新恢复到初始状态。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('重置数据'),
          ),
        ],
      ),
    );
    if (confirmed == true) await resetSampleDataset();
  }

  Future<void> resetSampleDataset() async {
    final targetChild = _resolveSampleChildId();
    if (targetChild == null) {
      _showSnackBar('未检测到示例数据档案，请先导入示例数据集');
      return;
    }
    final result = await gateway.resetSampleDatasetDto(childId: targetChild);
    if (!mounted) return;
    _setShellState(() {
      sampleImported = false;
      sampleImportFailed = false;
    });
    _appendLog('示例数据已重置：$targetChild，移除 ${result.deletedAssets} 个素材');
    await refreshDataset();
  }

  void _selectSampleChildIfAvailable() {
    final sampleChildId = _resolveSampleChildId();
    if (sampleChildId == null) return;
    selectedChildId = sampleChildId;
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
