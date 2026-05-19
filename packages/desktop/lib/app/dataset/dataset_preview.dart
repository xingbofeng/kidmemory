part of '../desktop_shell.dart';

extension _DesktopShellDatasetPreview on _DesktopShellState {
  Future<void> _openSamplePdf() async {
    if (assets.isNotEmpty) {
      final target = '${api.baseUrl}/assets/${assets.first.id}/preview';
      _appendLog('打开示例素材预览：${assets.first.id}');
      await _safeOpenExternalTarget(target, AppLocalizations.of(context)!.datasetPreviewS783);
      return;
    }
    if (jobId == null || !generated) {
      _showSnackBar(AppLocalizations.of(context)!.datasetPreviewS853);
      _appendLog(AppLocalizations.of(context)!.datasetPreviewS521);
      return;
    }
    final previewUrl = '${api.baseUrl}/books/jobs/$jobId/preview';
    _appendLog('打开历史作品预览：$jobId');
    await _safeOpenExternalTarget(previewUrl, AppLocalizations.of(context)!.datasetPreviewS771);
  }

  Future<void> _showGenerationLogDetails() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.datasetPreviewS743)),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Text(
                <String>['状态：$statusMessage', ...activityLog].join('\n'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.actionCloseLabel)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _previewAllPages() async {
    if (jobId == null || !generated) {
      _showSnackBar(AppLocalizations.of(context)!.datasetPreviewS852);
      _appendLog(AppLocalizations.of(context)!.datasetPreviewS952);
      return;
    }
    final previewUrl = '${api.baseUrl}/books/jobs/$jobId/preview';
    _appendLog('打开预览页面：$jobId');
    await _safeOpenExternalTarget(previewUrl, AppLocalizations.of(context)!.generateExportS943);
  }
}
