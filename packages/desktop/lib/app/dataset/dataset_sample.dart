part of '../desktop_shell.dart';

extension _DesktopShellDatasetSample on _DesktopShellState {
  void browseSampleAssets() {
    _selectSampleChildIfAvailable();
    _setShellState(() => step = AppStep.assets);
  }

  void generateSampleBook() {
    _selectSampleChildIfAvailable();
    _setShellState(() {
      generationTemplate = AppLocalizations.of(context)!.datasetSampleS696;
      generationPageSize = AppLocalizations.of(context)!.datasetSampleS101;
      generationStyle = AppLocalizations.of(context)!.datasetSampleS697;
      step = AppStep.generate;
    });
  }

  Future<void> _confirmResetSampleDataset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.datasetSampleS764),
        content: Text(AppLocalizations.of(context)!.datasetSampleS894),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.sampleDatasetResetDataLabel),
          ),
        ],
      ),
    );
    if (confirmed == true) await resetSampleDataset();
  }

  Future<void> resetSampleDataset() async {
    final targetChild = _resolveSampleChildId();
    if (targetChild == null) {
      _showSnackBar(AppLocalizations.of(context)!.datasetSampleS595);
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
