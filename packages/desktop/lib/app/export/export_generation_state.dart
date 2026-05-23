part of '../desktop_shell.dart';

extension _DesktopShellExportGenerationState on _DesktopShellState {
  bool _isCreationTaskTerminalStatus(String status) {
    return {
      'succeeded',
      'generated',
      'exported',
      'shared',
      'failed',
      'cancelled',
    }.contains(status);
  }

  bool _isCreationTaskSuccessfulStatus(String status) {
    return {'succeeded', 'generated', 'exported', 'shared'}.contains(status);
  }

  void _stopCreationTaskPolling() {
    _creationTaskPollingTimer?.cancel();
    _creationTaskPollingTimer = null;
  }

  void _startCreationTaskPolling(String nextTaskId) {
    _stopCreationTaskPolling();
    if (nextTaskId.trim().isEmpty) return;
    _creationTaskPollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_pollCreationTaskStatus(nextTaskId));
    });
  }

  Future<void> _pollCreationTaskStatus(String targetTaskId) async {
    if (!mounted || step != AppStep.generate || taskId != targetTaskId) {
      _stopCreationTaskPolling();
      return;
    }
    try {
      final task = await gateway.getCreationTaskRaw(taskId: targetTaskId);
      if (!mounted || taskId != targetTaskId) return;
      _applyCreationTaskResult(task, appendProgressLog: false);
    } catch (error) {
      if (!mounted || taskId != targetTaskId) return;
      _stopCreationTaskPolling();
      _applyGenerationError(error);
    }
  }

  void _markGenerationStarted() {
    _stopCreationTaskPolling();
    _setShellState(() {
      generating = true;
      generated = false;
      exported = false;
      exportResult = null;
      previewFailureReason = '';
      creationTask = null;
      creationFailure = null;
      creationTaskSteps = const [];
      generatedArtifactKind = '';
      generatedArtifactPath = '';
      taskId = null;
      creationWorkflowPhase = CreationWorkflowPhase.planning;
      statusMessage = AppLocalizations.of(context)!.creationPlanningStatus;
    });
    _appendLog(
      AppLocalizations.of(
        context,
      )!.exportGenerationStartedLog(selectedAssets.length),
    );
  }

  void _applyCreationTaskPlanResult(Map<String, dynamic> task) {
    final summary = '${task['summary'] ?? ''}'.trim();
    final nextTaskId = '${task['taskId'] ?? ''}'.trim();
    final preview = CreationTaskPreviewVm.fromJson(task);
    _setShellState(() {
      taskId = nextTaskId.isNotEmpty ? nextTaskId : null;
      creationTask = preview.hasContent ? preview : null;
      creationFailure = null;
      creationTaskSteps = const [];
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

  void _markCreationTaskGenerationStarted() {
    final isVideo = generationCreationType == 'memoir_video';
    _setShellState(() {
      generating = true;
      creationFailure = null;
      creationTaskSteps = const [];
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

  void _applyCreationTaskResult(
    Map<String, dynamic> task, {
    bool appendProgressLog = true,
  }) {
    final nextTaskId = '${task['taskId'] ?? ''}'.trim();
    final status = '${task['status'] ?? ''}'.trim();
    final steps = readCreationTaskSteps(task['steps']);
    if (status == 'failed' || status == 'cancelled') {
      _applyCreationTaskFailure(task, nextTaskId);
      return;
    }
    final isComplete = _isCreationTaskSuccessfulStatus(status);
    if (isComplete) {
      _stopCreationTaskPolling();
    }
    _setShellState(() {
      generating = !isComplete;
      generated = isComplete;
      creationFailure = null;
      creationTaskSteps = steps;
      generatedArtifactKind = isComplete
          ? _creationArtifactKind(task['artifacts'])
          : '';
      generatedArtifactPath = isComplete
          ? _creationArtifactPath(task['artifacts'])
          : '';
      previewFailureReason = '';
      creationWorkflowPhase = isComplete
          ? CreationWorkflowPhase.reviewing
          : CreationWorkflowPhase.generating;
      taskId = nextTaskId.isNotEmpty ? nextTaskId : taskId;
      statusMessage = isComplete
          ? AppLocalizations.of(context)!.exportGenerationStateS736
          : AppLocalizations.of(context)!.creationGeneratingStatus;
    });
    if (isComplete || appendProgressLog) {
      _appendLog(
        isComplete
            ? AppLocalizations.of(
                context,
              )!.exportGenerationCompletedLog(taskId ?? '')
            : AppLocalizations.of(context)!.generateExportS719,
      );
    }
  }

  void _applyCreationTaskFailure(Map<String, dynamic> task, String nextTaskId) {
    _stopCreationTaskPolling();
    final failure = CreationFailureVm.fromTask(task);
    final steps = readCreationTaskSteps(task['steps']);
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
      taskId = nextTaskId.isNotEmpty ? nextTaskId : taskId;
      creationFailure = failure.hasContent ? failure : null;
      creationTaskSteps = steps;
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
    _stopCreationTaskPolling();
    if (taskId == null &&
        !generated &&
        !exported &&
        exportResult == null) {
      return;
    }
    _setShellState(() {
      taskId = null;
      generated = false;
      generating = false;
      exported = false;
      shareCreating = false;
      exportResult = null;
      previewFailureReason = '';
      creationTask = null;
      creationFailure = null;
      creationTaskSteps = const [];
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
    _stopCreationTaskPolling();
    final message = AppLocalizations.of(
      context,
    )!.exportGenerationExceptionMessage(error);
    _setShellState(() {
      generating = false;
      generated = false;
      creationWorkflowPhase = CreationWorkflowPhase.failed;
      creationFailure = null;
      creationTaskSteps = const [];
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
