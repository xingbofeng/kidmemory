class ExportResultVm {
  const ExportResultVm({
    required this.kind,
    required this.localPath,
    required this.storageStatus,
    this.artifactId = '',
    this.remoteUrl = '',
    this.shareText = '',
    this.errorReason = '',
  });

  final String kind;
  final String localPath;
  final String storageStatus;
  final String artifactId;
  final String remoteUrl;
  final String shareText;
  final String errorReason;

  bool get isLongImage => kind == 'long_image_png' || kind == 'long_image_jpg';

  factory ExportResultVm.fromJson(Map<String, dynamic> json) {
    return ExportResultVm(
      kind: json['kind'] as String? ?? '',
      localPath: json['localPath'] as String? ?? '',
      storageStatus: json['storageStatus'] as String? ?? '',
      artifactId: json['artifactId'] as String? ?? '',
      remoteUrl: json['remoteUrl'] as String? ?? '',
      shareText: json['shareText'] as String? ?? '',
      errorReason: json['errorReason'] as String? ?? '',
    );
  }

  ExportResultVm copyWith({
    String? storageStatus,
    String? remoteUrl,
    String? shareText,
    String? errorReason,
  }) {
    return ExportResultVm(
      kind: kind,
      localPath: localPath,
      storageStatus: storageStatus ?? this.storageStatus,
      artifactId: artifactId,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      shareText: shareText ?? this.shareText,
      errorReason: errorReason ?? this.errorReason,
    );
  }
}

enum CreationWorkflowPhase {
  preparing,
  planning,
  planReady,
  creatingJob,
  environmentPreparing,
  generating,
  reviewing,
  exporting,
  published,
  failed,
}

enum CreationMainStage { prepare, plan, generate, preview, share }

class CreationTaskPreviewVm {
  const CreationTaskPreviewVm({
    required this.summary,
    required this.skillName,
    required this.steps,
    required this.requirements,
  });

  final String summary;
  final String skillName;
  final List<CreationTaskStepVm> steps;
  final List<String> requirements;

  factory CreationTaskPreviewVm.fromJson(Map<String, dynamic> json) {
    return CreationTaskPreviewVm(
      summary: '${json['summary'] ?? ''}'.trim(),
      skillName: '${json['skillName'] ?? ''}'.trim(),
      steps: _readPlanSteps(json['steps']),
      requirements: _readCreationRequirementList(json),
    );
  }

  bool get hasContent =>
      summary.isNotEmpty ||
      skillName.isNotEmpty ||
      steps.isNotEmpty ||
      requirements.isNotEmpty;
}

class CreationTaskStepVm {
  const CreationTaskStepVm({
    required this.stepId,
    required this.label,
    required this.status,
    required this.detail,
  });

  final String stepId;
  final String label;
  final String status;
  final String detail;
}

class CreationFailureVm {
  const CreationFailureVm({
    required this.stepLabel,
    required this.reason,
    required this.code,
    required this.category,
    required this.detail,
  });

  final String stepLabel;
  final String reason;
  final String code;
  final String category;
  final String detail;

  factory CreationFailureVm.fromTask(Map<String, dynamic> job) {
    final steps = _readPlanSteps(job['steps']);
    final currentStepId = '${job['currentStepId'] ?? ''}'.trim();
    CreationTaskStepVm? failedStep;
    for (final step in steps) {
      if (step.status == 'failed') {
        failedStep = step;
        break;
      }
    }
    failedStep ??= steps.cast<CreationTaskStepVm?>().firstWhere(
      (step) => step?.stepId == currentStepId,
      orElse: () => null,
    );
    final error = job['error'];
    final errorMap = error is Map ? error : const <String, dynamic>{};
    return CreationFailureVm(
      stepLabel: failedStep?.label ?? currentStepId,
      reason: '${errorMap['message'] ?? failedStep?.detail ?? ''}'.trim(),
      code: '${errorMap['code'] ?? ''}'.trim(),
      category: '${errorMap['category'] ?? ''}'.trim(),
      detail: failedStep?.detail ?? '',
    );
  }

  bool get hasContent =>
      stepLabel.isNotEmpty ||
      reason.isNotEmpty ||
      code.isNotEmpty ||
      category.isNotEmpty ||
      detail.isNotEmpty;
}

List<CreationTaskStepVm> _readPlanSteps(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final item in value)
      if (item is Map)
        CreationTaskStepVm(
          stepId: '${item['stepId'] ?? ''}'.trim(),
          label: '${item['label'] ?? item['stepId'] ?? ''}'.trim(),
          status: '${item['status'] ?? ''}'.trim(),
          detail: '${item['detail'] ?? ''}'.trim(),
        ),
  ].where((step) => step.label.isNotEmpty).toList(growable: false);
}

List<CreationTaskStepVm> readCreationTaskSteps(Object? value) {
  return _readPlanSteps(value);
}

List<String> _readStringList(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final item in value)
      if ('$item'.trim().isNotEmpty) '$item'.trim(),
  ];
}

List<String> _readCreationRequirementList(Map<String, dynamic> json) {
  final items = _readStringList(json['requirementItems']);
  if (items.isNotEmpty) return items;

  final requirements = json['requirements'];
  if (requirements is Iterable) return _readStringList(requirements);
  return const [];
}
