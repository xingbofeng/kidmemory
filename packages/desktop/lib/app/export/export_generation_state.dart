part of '../desktop_shell.dart';

extension _DesktopShellExportGenerationState on _DesktopShellState {
  bool _isCreationJobTerminalStatus(String status) {
    return {
      'succeeded',
      'generated',
      'exported',
      'shared',
      'failed',
      'cancelled',
    }.contains(status);
  }

  bool _isCreationJobSuccessfulStatus(String status) {
    return {'succeeded', 'generated', 'exported', 'shared'}.contains(status);
  }

  void _stopCreationJobPolling() {
    _creationJobPollingTimer?.cancel();
    _creationJobPollingTimer = null;
  }

  void _startCreationJobPolling(String nextJobId) {
    _stopCreationJobPolling();
    if (nextJobId.trim().isEmpty) return;
    _creationJobPollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_pollCreationJobStatus(nextJobId));
    });
  }

  Future<void> _pollCreationJobStatus(String targetJobId) async {
    if (!mounted || step != AppStep.generate || jobId != targetJobId) {
      _stopCreationJobPolling();
      return;
    }
    try {
      final job = await gateway.getCreationJobRaw(jobId: targetJobId);
      if (!mounted || jobId != targetJobId) return;
      _applyCreationJobResult(job, appendProgressLog: false);
    } catch (error) {
      if (!mounted || jobId != targetJobId) return;
      _stopCreationJobPolling();
      _applyGenerationError(error);
    }
  }

  void _markGenerationStarted() {
    _stopCreationJobPolling();
    _setShellState(() {
      generating = true;
      generated = false;
      exported = false;
      exportResult = null;
      previewFailureReason = '';
      planId = null;
      creationPlan = null;
      creationFailure = null;
      creationJobSteps = const [];
      generatedArtifactKind = '';
      generatedArtifactPath = '';
      jobId = null;
      creationWorkflowPhase = CreationWorkflowPhase.planning;
      statusMessage = AppLocalizations.of(context)!.creationPlanningStatus;
    });
    _appendLog(
      AppLocalizations.of(
        context,
      )!.exportGenerationStartedLog(selectedAssets.length),
    );
  }

  void _applyCreationPlanResult(Map<String, dynamic> plan) {
    final summary = '${plan['summary'] ?? ''}'.trim();
    final nextPlanId = '${plan['planId'] ?? ''}'.trim();
    final preview = CreationPlanPreviewVm.fromJson(plan);
    _setShellState(() {
      planId = nextPlanId.isNotEmpty ? nextPlanId : null;
      creationPlan = preview.hasContent ? preview : null;
      creationFailure = null;
      creationJobSteps = const [];
      generatedArtifactKind = '';
      generatedArtifactPath = '';
      previewFailureReason = '';
      generating = false;
      creationWorkflowPhase = CreationWorkflowPhase.planReady;
      statusMessage = AppLocalizations.of(context)!.creationPlanReadyStatus;
    });
    if (summary.isNotEmpty) {
      _appendLog(summary);
    }
    _appendLog(statusMessage);
  }

  void _markCreationJobStarted() {
    final isVideo = generationCreationType == 'memoir_video';
    _setShellState(() {
      generating = true;
      creationFailure = null;
      creationJobSteps = const [];
      generatedArtifactKind = '';
      generatedArtifactPath = '';
      previewFailureReason = '';
      creationWorkflowPhase = isVideo
          ? CreationWorkflowPhase.environmentPreparing
          : CreationWorkflowPhase.creatingJob;
      statusMessage = isVideo
          ? AppLocalizations.of(context)!.creationEnvironmentPreparingStatus
          : AppLocalizations.of(context)!.creationCreatingJobStatus;
    });
    _appendLog(statusMessage);
  }

  void _applyCreationJobResult(
    Map<String, dynamic> job, {
    bool appendProgressLog = true,
  }) {
    final nextJobId = '${job['jobId'] ?? ''}'.trim();
    final status = '${job['status'] ?? ''}'.trim();
    final steps = readCreationPlanSteps(job['steps']);
    if (status == 'failed' || status == 'cancelled') {
      _applyCreationJobFailure(job, nextJobId);
      return;
    }
    final isComplete = _isCreationJobSuccessfulStatus(status);
    if (isComplete) {
      _stopCreationJobPolling();
    }
    _setShellState(() {
      generating = !isComplete;
      generated = isComplete;
      creationFailure = null;
      creationJobSteps = steps;
      generatedArtifactKind = isComplete
          ? _creationArtifactKind(job['artifacts'])
          : '';
      generatedArtifactPath = isComplete
          ? _creationArtifactPath(job['artifacts'])
          : '';
      previewFailureReason = '';
      creationWorkflowPhase = isComplete
          ? CreationWorkflowPhase.reviewing
          : CreationWorkflowPhase.generating;
      jobId = nextJobId.isNotEmpty ? nextJobId : null;
      statusMessage = isComplete
          ? AppLocalizations.of(context)!.exportGenerationStateS736
          : AppLocalizations.of(context)!.creationGeneratingStatus;
    });
    if (isComplete || appendProgressLog) {
      _appendLog(
        isComplete
            ? AppLocalizations.of(
                context,
              )!.exportGenerationCompletedLog(jobId ?? '')
            : AppLocalizations.of(context)!.generateExportS719,
      );
    }
  }

  void _applyCreationJobFailure(Map<String, dynamic> job, String nextJobId) {
    _stopCreationJobPolling();
    final failure = CreationFailureVm.fromJob(job);
    final steps = readCreationPlanSteps(job['steps']);
    final reason = failure.reason.isNotEmpty
        ? failure.reason
        : AppLocalizations.of(context)!.generateExportS226;
    final message = failure.stepLabel.isNotEmpty
        ? AppLocalizations.of(
            context,
          )!.creationGenerationFailedWithStep(failure.stepLabel, reason)
        : AppLocalizations.of(
            context,
          )!.exportGenerationExceptionMessage(reason);
    _setShellState(() {
      generating = false;
      generated = false;
      creationWorkflowPhase = CreationWorkflowPhase.failed;
      jobId = nextJobId.isNotEmpty ? nextJobId : null;
      creationFailure = failure.hasContent ? failure : null;
      creationJobSteps = steps;
      generatedArtifactKind = '';
      generatedArtifactPath = '';
      previewFailureReason = '';
      statusMessage = message;
    });
    _appendLog(message);
    if (failure.code.isNotEmpty) {
      _appendLog(
        AppLocalizations.of(context)!.creationFailureCodeLine(failure.code),
      );
    }
  }

  void _invalidateCreationPlanForInputChange() {
    _stopCreationJobPolling();
    if (planId == null &&
        jobId == null &&
        !generated &&
        !exported &&
        exportResult == null) {
      return;
    }
    _setShellState(() {
      planId = null;
      jobId = null;
      generated = false;
      generating = false;
      exported = false;
      shareCreating = false;
      exportResult = null;
      previewFailureReason = '';
      creationPlan = null;
      creationFailure = null;
      creationJobSteps = const [];
      generatedArtifactKind = '';
      generatedArtifactPath = '';
      creationWorkflowPhase = CreationWorkflowPhase.preparing;
      statusMessage = AppLocalizations.of(
        context,
      )!.creationPlanInvalidatedStatus;
    });
    _appendLog(AppLocalizations.of(context)!.creationPlanInvalidatedStatus);
  }

  void _applyGenerationError(Object error) {
    _stopCreationJobPolling();
    final message = AppLocalizations.of(
      context,
    )!.exportGenerationExceptionMessage(error);
    _setShellState(() {
      generating = false;
      generated = false;
      creationWorkflowPhase = CreationWorkflowPhase.failed;
      creationFailure = null;
      creationJobSteps = const [];
      generatedArtifactKind = '';
      generatedArtifactPath = '';
      previewFailureReason = '';
      statusMessage = message;
    });
    _appendLog(message);
  }

  String _creationArtifactKind(Object? artifacts) {
    final artifact = _firstCreationArtifact(artifacts);
    return '${artifact?['kind'] ?? ''}'.trim();
  }

  String _creationArtifactPath(Object? artifacts) {
    final artifact = _firstCreationArtifact(artifacts);
    return '${artifact?['localPath'] ?? ''}'.trim();
  }

  Map<dynamic, dynamic>? _firstCreationArtifact(Object? artifacts) {
    if (artifacts is! Iterable) return null;
    for (final item in artifacts) {
      if (item is Map) return item;
    }
    return null;
  }
}
