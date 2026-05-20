part of '../desktop_shell.dart';

extension _DesktopShellExportFlow on _DesktopShellState {
  Future<void> generateBook({String? creationType}) async {
    final nextCreationType = creationType ?? generationCreationType;
    final nextExportTarget = creationType == null
        ? generationExportTarget
        : _exportTargetForCreationType(nextCreationType);
    desktopTraceContext.beginAction();
    final nextTraceId = desktopTraceContext.traceId;
    final nextRequestId = desktopTraceContext.nextRequestId();
    api.setRequestContext(traceId: nextTraceId, requestId: nextRequestId);
    _setShellState(() {
      generationCreationType = nextCreationType;
      generationExportTarget = nextExportTarget;
      traceId = nextTraceId;
      requestId = nextRequestId;
    });
    unawaited(
      desktopLogger.append(
        level: DesktopLogLevel.info,
        event: 'desktop.action.generate_book',
        traceId: nextTraceId,
        requestId: nextRequestId,
        data: {
          'creationType': nextCreationType,
          'selectedCount': selectedAssets.length,
          'childId': selectedChildId,
        },
      ),
    );
    _markGenerationStarted();
    try {
      final plan = await gateway.createCreationPlanRaw(
        goal: generationTemplate.trim().isEmpty
            ? 'KidMemory storybook'
            : generationTemplate.trim(),
        creationType: nextCreationType,
        assetIds: selectedAssets.toList(),
        settings: {
          if (selectedChildId != null) 'childId': selectedChildId,
          'pageSize': generationPageSize,
          'style': generationStyle,
        },
      );
      if (!mounted) return;
      _applyCreationPlanResult(plan);
    } catch (error) {
      if (!mounted) return;
      _applyGenerationError(error);
    } finally {
      api.clearRequestContext();
    }
  }

  Future<void> confirmCreationPlan() async {
    final currentPlanId = planId?.trim() ?? '';
    if (currentPlanId.isEmpty) {
      _setShellState(() {
        creationWorkflowPhase = CreationWorkflowPhase.failed;
        statusMessage = AppLocalizations.of(context)!.creationPlanMissingStatus;
      });
      _appendLog(statusMessage);
      return;
    }
    desktopTraceContext.beginAction();
    final nextTraceId = desktopTraceContext.traceId;
    final nextRequestId = desktopTraceContext.nextRequestId();
    api.setRequestContext(traceId: nextTraceId, requestId: nextRequestId);
    _setShellState(() {
      traceId = nextTraceId;
      requestId = nextRequestId;
    });
    unawaited(
      desktopLogger.append(
        level: DesktopLogLevel.info,
        event: 'desktop.action.confirm_creation_plan',
        traceId: nextTraceId,
        requestId: nextRequestId,
        data: {'planId': currentPlanId},
      ),
    );
    _markCreationJobStarted();
    try {
      final job = await gateway.createCreationJobRaw(planId: currentPlanId);
      if (!mounted) return;
      _applyCreationJobResult(job);
      final nextJobId = jobId;
      final status = '${job['status'] ?? ''}'.trim();
      if (nextJobId != null && !_isCreationJobTerminalStatus(status)) {
        _startCreationJobPolling(nextJobId);
      }
    } catch (error) {
      if (!mounted) return;
      _applyGenerationError(error);
    } finally {
      api.clearRequestContext();
    }
  }

  Future<void> exportPdf() async {
    final l10n = AppLocalizations.of(context)!;
    desktopTraceContext.beginAction();
    final nextTraceId = desktopTraceContext.traceId;
    final nextRequestId = desktopTraceContext.nextRequestId();
    api.setRequestContext(traceId: nextTraceId, requestId: nextRequestId);
    _setShellState(() {
      traceId = nextTraceId;
      requestId = nextRequestId;
    });
    unawaited(
      desktopLogger.append(
        level: DesktopLogLevel.info,
        event: 'desktop.action.export_pdf',
        traceId: nextTraceId,
        requestId: nextRequestId,
        data: {'jobId': jobId, 'target': generationExportTarget},
      ),
    );
    if (jobId == null) {
      _setShellState(
        () => statusMessage = AppLocalizations.of(context)!.exportPageS851,
      );
      _appendLog(AppLocalizations.of(context)!.exportPageS410);
      api.clearRequestContext();
      return;
    }
    final target = _exportTargetFromLabel(generationExportTarget);
    final exportLabel = _exportLabel(target);

    _setShellState(
      () => statusMessage = AppLocalizations.of(context)!.exportPageS649,
    );
    _appendLog(AppLocalizations.of(context)!.exportPageS702);

    final defaultPaths = _defaultKidMemoryPaths();
    final targetDirectoryPath = _resolveConfiguredPath(
      currentExportDir.trim().isEmpty
          ? defaultPaths.exportDir
          : currentExportDir.trim(),
      defaultPaths.exportDir,
    );

    try {
      Directory(targetDirectoryPath).createSync(recursive: true);
    } catch (error) {
      if (!mounted) return;
      final message = l10n.exportCreateDirectoryFailedMessage(error);
      _setShellState(() => statusMessage = message);
      _appendLog(message);
      return;
    }
    final destinationPath = _buildExportTargetPath(
      targetDirectoryPath,
      _exportFileNameForJob(jobId!, target),
    );
    _setShellState(() {
      creationWorkflowPhase = CreationWorkflowPhase.exporting;
      statusMessage = l10n.exportInProgressStatus(destinationPath);
    });
    _appendLog(l10n.exportPreparingDestinationLog(destinationPath));
    try {
      final bool exportedOk;
      final String actualPath;
      final String artifactId;
      final String exportedMessage;
      if (target == _ExportTarget.pdf || target == _ExportTarget.mp4) {
        final result = await gateway.exportCreationJobRaw(
          jobId: jobId!,
          target: _artifactKindForTarget(target),
          targetPath: destinationPath,
        );
        exportedOk =
            result['artifactId']?.toString().trim().isNotEmpty ?? false;
        actualPath = result['localPath']?.toString().trim().isNotEmpty == true
            ? result['localPath'].toString()
            : destinationPath;
        artifactId = result['artifactId']?.toString() ?? '';
        exportedMessage = '';
      } else {
        final result = await gateway.exportBookDto(
          payload: ExportBookInput(
            jobId: jobId!,
            targetPath: destinationPath,
            format: target == _ExportTarget.longImageJpg ? 'jpg' : 'png',
          ),
        );
        exportedOk = result.exportedPayload.okValue;
        actualPath = result.exportedPayload.pathValue.trim().isNotEmpty
            ? result.exportedPayload.pathValue
            : destinationPath;
        artifactId = result.artifactId;
        exportedMessage = result.exportedPayload.messageValue;
      }
      if (!mounted) return;
      final syncedResult = exportedOk
          ? await _maybeSyncExportArtifact(artifactId)
          : _ExportSyncResult.localOnly();
      if (!mounted) return;
      _applyExportResultState(
        target: target,
        exportLabel: exportLabel,
        exportedOk: exportedOk,
        actualPath: actualPath,
        artifactId: artifactId,
        syncedResult: syncedResult,
        exportedMessage: exportedMessage,
      );
      _appendLog(
        exportedOk
            ? l10n.exportSucceededLog(exportLabel, actualPath)
            : l10n.exportFailedLog(exportLabel),
      );
    } catch (error) {
      if (!mounted) return;
      final message = l10n.exportExceptionMessage(exportLabel, error);
      _applyExportExceptionState(target: target, message: message);
      _appendLog(message);
    } finally {
      api.clearRequestContext();
    }
  }

  String _exportTargetForCreationType(String creationType) {
    if (creationType == 'memoir_video') {
      return AppLocalizations.of(context)!.generateExportMp4Target;
    }
    final pdfTarget = generationExportTargets.firstWhere(
      (target) => target.toLowerCase().contains('pdf'),
      orElse: () =>
          AppLocalizations.of(context)!.generateExportDefaultPdfTarget,
    );
    return pdfTarget;
  }
}
