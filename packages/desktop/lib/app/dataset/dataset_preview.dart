part of '../desktop_shell.dart';

extension _DesktopShellDatasetPreview on _DesktopShellState {
  Future<void> _openSamplePdf() async {
    if (assets.isNotEmpty) {
      final target = '${api.baseUrl}/assets/${assets.first.id}/preview';
      _appendLog(
        AppLocalizations.of(
          context,
        )!.datasetPreviewOpenSampleAssetLog(assets.first.id),
      );
      await _safeOpenExternalTarget(
        target,
        AppLocalizations.of(context)!.datasetPreviewS783,
      );
      return;
    }
    if (jobId == null || !generated) {
      _showSnackBar(AppLocalizations.of(context)!.datasetPreviewS853);
      _appendLog(AppLocalizations.of(context)!.datasetPreviewS521);
      return;
    }
    final currentJobId = jobId!;
    final previewUrl = '${api.baseUrl}/creation/jobs/$currentJobId/preview';
    _appendLog(
      AppLocalizations.of(context)!.datasetPreviewOpenHistoryLog(currentJobId),
    );
    await _safeOpenExternalTarget(
      previewUrl,
      AppLocalizations.of(context)!.datasetPreviewS771,
    );
  }

  Future<void> _showGenerationLogDetails() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.datasetPreviewS743),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Text(
                <String>[
                  AppLocalizations.of(
                    context,
                  )!.datasetPreviewLogStatusLine(statusMessage),
                  if (jobId?.trim().isNotEmpty == true) 'jobId: $jobId',
                  if (requestId.trim().isNotEmpty) 'requestId: $requestId',
                  ...activityLog,
                ].join('\n'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.actionCloseLabel),
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
    final currentJobId = jobId!;
    if (generationCreationType == 'memoir_video') {
      await _previewGeneratedVideo(currentJobId);
      return;
    }
    final previewUrl = '${api.baseUrl}/creation/jobs/$currentJobId/preview';
    _appendLog(
      AppLocalizations.of(context)!.datasetPreviewOpenPageLog(currentJobId),
    );
    try {
      await openExternalTarget(previewUrl);
      if (!mounted) return;
      _setShellState(() => previewFailureReason = '');
      _appendLog(
        AppLocalizations.of(context)!.datasetExternalOpenSucceededLog(
          AppLocalizations.of(context)!.generateExportS943,
          previewUrl,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = AppLocalizations.of(
        context,
      )!.generateExportPreviewFailedStatus(error);
      _setShellState(() {
        previewFailureReason = '$error';
        statusMessage = message;
      });
      _showSnackBar(message);
      _appendLog(message);
    }
  }

  Future<void> _previewGeneratedVideo(String currentJobId) async {
    final target = generatedArtifactPath.trim().isNotEmpty
        ? generatedArtifactPath.trim()
        : exportResult?.localPath.trim() ?? '';
    if (target.isEmpty) {
      final message =
          AppLocalizations.of(context)!.generateExportVideoPreviewUnavailable;
      _setShellState(() {
        previewFailureReason = message;
        statusMessage = message;
      });
      _showSnackBar(message);
      _appendLog(message);
      return;
    }
    _appendLog(
      AppLocalizations.of(context)!.datasetPreviewOpenPageLog(currentJobId),
    );
    try {
      await openExternalTarget(target);
      if (!mounted) return;
      _setShellState(() => previewFailureReason = '');
      _appendLog(
        AppLocalizations.of(context)!.datasetExternalOpenSucceededLog(
          AppLocalizations.of(context)!.generateExportOpenVideoPreviewAction,
          target,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = AppLocalizations.of(
        context,
      )!.generateExportPreviewFailedStatus(error);
      _setShellState(() {
        previewFailureReason = '$error';
        statusMessage = message;
      });
      _showSnackBar(message);
      _appendLog(message);
    }
  }
}
