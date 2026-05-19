part of '../desktop_shell.dart';

extension _DesktopShellExportActions on _DesktopShellState {
  Future<void> _openExportFolder() async {
    final localPath = exportResult?.localPath.trim() ?? '';
    if (localPath.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.exportActionsS850);
      return;
    }
    await _safeOpenExternalTarget(_dirname(localPath), AppLocalizations.of(context)!.exportActionsS414);
  }

  Future<void> _copyShareText() async {
    final text = exportResult?.shareText.trim() ?? '';
    if (text.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.exportActionsS416);
      return;
    }
    await copyToClipboard(text);
    _showSnackBar(AppLocalizations.of(context)!.exportActionsS273);
  }

  Future<void> _copyLongImage() async {
    final result = exportResult;
    final path = result?.localPath.trim() ?? '';
    if (result == null || !result.isLongImage || path.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.exportActionsS475);
      return;
    }
    await copyToClipboard(path);
    _showSnackBar(AppLocalizations.of(context)!.exportActionsS479);
  }
}
