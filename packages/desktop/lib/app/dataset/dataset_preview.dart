part of '../desktop_shell.dart';

extension _DesktopShellDatasetPreview on _DesktopShellState {
  Future<void> _openSamplePdf() async {
    if (assets.isNotEmpty) {
      final target = '${api.baseUrl}/assets/${assets.first.id}/preview';
      _appendLog('打开示例素材预览：${assets.first.id}');
      await _safeOpenExternalTarget(target, '示例素材');
      return;
    }
    if (jobId == null || !generated) {
      _showSnackBar('请先导入示例数据并完成一次生成，才能查看示例 PDF');
      _appendLog('打开示例 PDF：缺少可用预览来源');
      return;
    }
    final previewUrl = '${api.baseUrl}/books/jobs/$jobId/preview';
    _appendLog('打开历史作品预览：$jobId');
    await _safeOpenExternalTarget(previewUrl, '示例 PDF');
  }

  Future<void> _showGenerationLogDetails() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Claude Agent 日志详情'),
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
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _previewAllPages() async {
    if (jobId == null || !generated) {
      _showSnackBar('请先完成生成，再打开预览全部页面');
      _appendLog('预览全部页面：缺少 jobId');
      return;
    }
    final previewUrl = '${api.baseUrl}/books/jobs/$jobId/preview';
    _appendLog('打开预览页面：$jobId');
    await _safeOpenExternalTarget(previewUrl, '页面预览');
  }
}
