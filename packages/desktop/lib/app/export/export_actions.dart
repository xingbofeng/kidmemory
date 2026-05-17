part of '../desktop_shell.dart';

extension _DesktopShellExportActions on _DesktopShellState {
  Future<void> _openExportFolder() async {
    final localPath = exportResult?.localPath.trim() ?? '';
    if (localPath.isEmpty) {
      _showSnackBar('请先完成导出，再打开导出文件夹');
      return;
    }
    await _safeOpenExternalTarget(_dirname(localPath), '导出文件夹');
  }

  Future<void> _copyShareText() async {
    final text = exportResult?.shareText.trim() ?? '';
    if (text.isEmpty) {
      _showSnackBar('导出物尚未同步到 Supabase Storage，暂不能复制分享文案');
      return;
    }
    await copyToClipboard(text);
    _showSnackBar('分享文案已复制');
  }

  Future<void> _copyLongImage() async {
    final result = exportResult;
    final path = result?.localPath.trim() ?? '';
    if (result == null || !result.isLongImage || path.isEmpty) {
      _showSnackBar('当前导出不是长图，不能复制长图');
      return;
    }
    await copyToClipboard(path);
    _showSnackBar('当前平台暂不支持直接复制图片内容，已复制长图本地路径');
  }
}
