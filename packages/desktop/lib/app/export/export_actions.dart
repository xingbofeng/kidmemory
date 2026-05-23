part of '../desktop_shell.dart';

extension _DesktopShellExportActions on _DesktopShellState {
  Future<void> _openExportFolder() async {
    final localPath = exportResult?.localPath.trim() ?? '';
    if (localPath.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.exportActionsS850);
      return;
    }
    await _safeOpenExternalTarget(
      _dirname(localPath),
      AppLocalizations.of(context)!.exportActionsS414,
    );
  }

  Future<void> _openPreviewFailureFolder() async {
    final localPath = exportResult?.localPath.trim() ?? '';
    final directory = localPath.isNotEmpty
        ? _dirname(localPath)
        : currentExportDir;
    await _openDirectory(directory);
  }

  Future<void> _copyShareText() async {
    final text = exportResult?.shareText.trim().isNotEmpty == true
        ? exportResult!.shareText.trim()
        : exportResult?.remoteUrl.trim() ?? '';
    if (text.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.exportActionsS416);
      return;
    }
    await copyToClipboard(text);
    if (!mounted) return;
    _showSnackBar(AppLocalizations.of(context)!.exportActionsS273);
  }

  Future<void> _openShareLink() async {
    final url = exportResult?.remoteUrl.trim() ?? '';
    if (url.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.generateExportShareNotReady);
      return;
    }
    await _safeOpenExternalTarget(
      url,
      AppLocalizations.of(context)!.generateExportOpenLinkLabel,
    );
  }

  Future<void> _confirmAndCreateShareLink() async {
    final current = exportResult;
    final currentTaskId = taskId?.trim() ?? '';
    final artifactId = current?.artifactId.trim() ?? '';
    if (current == null ||
        current.localPath.trim().isEmpty ||
        currentTaskId.isEmpty ||
        artifactId.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.generateExportShareNotReady);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.generateExportCreateShareDialogTitle,
        ),
        content: Text(
          AppLocalizations.of(context)!.generateExportCreateShareDialogBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppLocalizations.of(context)!.generateExportCreateShareLinkLabel,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _setShellState(() {
      shareCreating = true;
      statusMessage = AppLocalizations.of(
        context,
      )!.generateExportShareCreatingStatus;
    });
    _appendLog(AppLocalizations.of(context)!.generateExportShareCreatingStatus);
    try {
      final share = await gateway.shareCreationTaskRaw(
        taskId: currentTaskId,
        artifactId: artifactId,
      );
      if (!mounted) return;
      _applyShareResultState(share);
    } catch (error) {
      if (!mounted) return;
      _applyShareExceptionState(error);
    }
  }

  Future<void> _copyLongImage() async {
    final result = exportResult;
    final path = result?.localPath.trim() ?? '';
    if (result == null || !result.isLongImage || path.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.exportActionsS475);
      return;
    }
    await copyToClipboard(path);
    if (!mounted) return;
    _showSnackBar(AppLocalizations.of(context)!.exportActionsS479);
  }
}
