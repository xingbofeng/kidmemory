import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/chrome.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/layout.dart';
import '../../../l10n/app_localizations.dart';

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

class CreationPlanPreviewVm {
  const CreationPlanPreviewVm({
    required this.summary,
    required this.skillName,
    required this.steps,
    required this.requirements,
  });

  final String summary;
  final String skillName;
  final List<CreationPlanStepVm> steps;
  final List<String> requirements;

  factory CreationPlanPreviewVm.fromJson(Map<String, dynamic> json) {
    return CreationPlanPreviewVm(
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

class CreationPlanStepVm {
  const CreationPlanStepVm({
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

  factory CreationFailureVm.fromJob(Map<String, dynamic> job) {
    final steps = _readPlanSteps(job['steps']);
    final currentStepId = '${job['currentStepId'] ?? ''}'.trim();
    CreationPlanStepVm? failedStep;
    for (final step in steps) {
      if (step.status == 'failed') {
        failedStep = step;
        break;
      }
    }
    failedStep ??= steps.cast<CreationPlanStepVm?>().firstWhere(
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

List<CreationPlanStepVm> _readPlanSteps(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final item in value)
      if (item is Map)
        CreationPlanStepVm(
          stepId: '${item['stepId'] ?? ''}'.trim(),
          label: '${item['label'] ?? item['stepId'] ?? ''}'.trim(),
          status: '${item['status'] ?? ''}'.trim(),
          detail: '${item['detail'] ?? ''}'.trim(),
        ),
  ].where((step) => step.label.isNotEmpty).toList(growable: false);
}

List<CreationPlanStepVm> readCreationPlanSteps(Object? value) {
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

class GenerateExportPage extends StatelessWidget {
  const GenerateExportPage({
    required this.selectedCount,
    required this.generated,
    required this.generating,
    required this.exported,
    required this.creationPhase,
    required this.statusMessage,
    required this.requestId,
    required this.logLines,
    required this.templateOptions,
    required this.pageSizeOptions,
    required this.styleOptions,
    required this.exportTargetOptions,
    required this.selectedTemplate,
    required this.selectedPageSize,
    required this.selectedStyle,
    required this.selectedExportTarget,
    required this.onGenerate,
    required this.onConfirmPlan,
    required this.onExport,
    required this.onExportTargetChanged,
    this.selectedCreationType = 'storybook',
    this.onGeneratePictureBook,
    this.onGenerateMemoryAlbum,
    this.onGenerateMemoryVideo,
    this.creationPlan,
    this.creationFailure,
    this.creationJobSteps = const [],
    this.exportResult,
    this.previewFailureReason = '',
    this.shareCreating = false,
    this.onOpenExportFolder,
    this.onOpenPreviewFailureFolder,
    this.onCreateShareLink,
    this.onCopyShareText,
    this.onOpenShareLink,
    this.onCopyLongImage,
    this.onViewSelectedAssets = _noop,
    this.onPreviewAllPages = _noop,
    this.onViewLogDetails = _noop,
    this.onEditCreationRequest = _noop,
    super.key,
  });

  final int selectedCount;
  final bool generated;
  final bool generating;
  final bool exported;
  final CreationWorkflowPhase creationPhase;
  final String statusMessage;
  final String requestId;
  final List<String> logLines;
  final List<String> templateOptions;
  final List<String> pageSizeOptions;
  final List<String> styleOptions;
  final List<String> exportTargetOptions;
  final String selectedTemplate;
  final String selectedPageSize;
  final String selectedStyle;
  final String selectedExportTarget;
  final String selectedCreationType;
  final VoidCallback onGenerate;
  final VoidCallback? onGeneratePictureBook;
  final VoidCallback? onGenerateMemoryAlbum;
  final VoidCallback? onGenerateMemoryVideo;
  final VoidCallback onConfirmPlan;
  final VoidCallback onExport;
  final ValueChanged<String> onExportTargetChanged;
  final bool shareCreating;
  final ExportResultVm? exportResult;
  final String previewFailureReason;
  final CreationPlanPreviewVm? creationPlan;
  final CreationFailureVm? creationFailure;
  final List<CreationPlanStepVm> creationJobSteps;
  final VoidCallback? onOpenExportFolder;
  final VoidCallback? onOpenPreviewFailureFolder;
  final VoidCallback? onCreateShareLink;
  final VoidCallback? onCopyShareText;
  final VoidCallback? onOpenShareLink;
  final VoidCallback? onCopyLongImage;
  final VoidCallback onViewSelectedAssets;
  final VoidCallback onPreviewAllPages;
  final VoidCallback onViewLogDetails;
  final VoidCallback onEditCreationRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templates = templateOptions.isNotEmpty
        ? templateOptions
        : [l10n.generationTemplateWarmChildhood];
    final pageSizes = pageSizeOptions.isNotEmpty
        ? pageSizeOptions
        : [l10n.generateExportDefaultPageSize];
    final styles = styleOptions.isNotEmpty
        ? styleOptions
        : [l10n.generateExportDefaultStyle];
    final exportTargets = exportTargetOptions.isNotEmpty
        ? exportTargetOptions
        : [l10n.generateExportDefaultPdfTarget];
    final effectiveExportTargets = selectedCreationType == 'memoir_video'
        ? [
            ...exportTargets.where((target) => !_isMp4Target(context, target)),
            l10n.generateExportMp4Target,
          ]
        : exportTargets;
    final templateText = _firstNonEmpty(templates, selectedTemplate);
    final sizeText = _firstNonEmpty(pageSizes, selectedPageSize);
    final styleText = _firstNonEmpty(styles, selectedStyle);
    final exportText = _firstNonEmpty(
      effectiveExportTargets,
      selectedExportTarget,
    );
    final exportLabel = _exportDisplayName(context, exportText);
    final generationState = exported
        ? l10n.generateExportExportedState(exportLabel)
        : (generated
              ? AppLocalizations.of(context)!.generateExportS450
              : (generating
                    ? _creationPhaseLabel(context, creationPhase)
                    : creationPhase == CreationWorkflowPhase.planReady
                    ? l10n.creationPhasePlanReady
                    : AppLocalizations.of(
                        context,
                      )!.contentPreviewWaitingForGenerationLabel));
    final showCoverFailureActions = _showCoverFailureActions(
      context,
      statusMessage,
    );
    final canGenerate =
        selectedCount > 0 &&
        !generating &&
        creationPhase != CreationWorkflowPhase.planReady;
    final mainStage = _mainStageFor(
      creationPhase,
      generated: generated,
      exported: exported,
    );
    final showPlanConfirmation =
        creationPlan != null &&
        creationPhase == CreationWorkflowPhase.planReady;
    final showGenerationProgress =
        creationJobSteps.isNotEmpty ||
        creationPhase == CreationWorkflowPhase.planning ||
        creationPhase == CreationWorkflowPhase.creatingJob ||
        creationPhase == CreationWorkflowPhase.generating ||
        creationPhase == CreationWorkflowPhase.failed ||
        generated ||
        exported;
    final showPreviewPanel =
        generated ||
        exported ||
        creationPhase == CreationWorkflowPhase.reviewing ||
        creationPhase == CreationWorkflowPhase.exporting ||
        creationPhase == CreationWorkflowPhase.published;
    final showActivityPanel =
        creationPhase != CreationWorkflowPhase.preparing ||
        generating ||
        generated ||
        exported;
    final showExportPanel =
        generated || exported || exportResult != null || shareCreating;
    final showPreviewFailurePanel =
        generated && previewFailureReason.trim().isNotEmpty;
    return PageFrame(
      title: AppLocalizations.of(context)!.assetStudioTitle,
      subtitle: AppLocalizations.of(context)!.generateExportS909,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controlPanel = GenerateSettingsPanel(
            generated: generated,
            generating: generating,
            exported: exported,
            creationPhase: creationPhase,
            selectedCount: selectedCount,
            templateText: templateText,
            creationTypeText: _creationTypeLabel(context, selectedCreationType),
            sizeText: sizeText,
            styleText: styleText,
            exportText: exportText,
            exportTargets: effectiveExportTargets,
            onGenerate: canGenerate ? onGenerate : null,
            onConfirmPlan: onConfirmPlan,
            onExport: onExport,
            onExportTargetChanged: onExportTargetChanged,
            onViewSelectedAssets: selectedCount > 0
                ? onViewSelectedAssets
                : null,
            onPreviewAllPages: onPreviewAllPages,
          );
          final mainContent = SingleChildScrollView(
            child: Column(
              children: [
                CreationStageStepper(currentStage: mainStage),
                const SizedBox(height: 16),
                SmartGenerateActions(
                  selectedCount: selectedCount,
                  generating: generating,
                  selectedCreationType: selectedCreationType,
                  onGeneratePictureBook: canGenerate
                      ? (onGeneratePictureBook ?? onGenerate)
                      : null,
                  onGenerateMemoryAlbum: canGenerate
                      ? (onGenerateMemoryAlbum ?? onGenerate)
                      : null,
                  onGenerateMemoryVideo: canGenerate
                      ? (onGenerateMemoryVideo ?? onGenerate)
                      : null,
                ),
                const SizedBox(height: 16),
                generated
                    ? GeneratedWorkSummary(
                        selectedCount: selectedCount,
                        generationState: generationState,
                        styleText: styleText,
                        sizeText: sizeText,
                        exportLabel: exportLabel,
                        exported: exported,
                      )
                    : GenerationEntrySummary(
                        selectedCount: selectedCount,
                        styleText: styleText,
                        sizeText: sizeText,
                        onViewSelectedAssets: onViewSelectedAssets,
                      ),
                const SizedBox(height: 16),
                AssetInputCard(
                  count: selectedCount,
                  onViewSelectedAssets: onViewSelectedAssets,
                ),
                if (showGenerationProgress) ...[
                  const SizedBox(height: 16),
                  GenerationFlowProgress(
                    selectedCount: selectedCount,
                    generated: generated,
                    generating: generating,
                    exported: exported,
                    creationPhase: creationPhase,
                    exportLabel: exportLabel,
                    backendSteps: creationJobSteps,
                  ),
                ],
                if (showPlanConfirmation) ...[
                  const SizedBox(height: 16),
                  CreationPlanConfirmationPanel(
                    plan: creationPlan!,
                    onConfirm: onConfirmPlan,
                    onEditRequest: onEditCreationRequest,
                  ),
                ],
                if (showPreviewPanel) ...[
                  const SizedBox(height: 16),
                  CreativePreviewPanel(
                    selectedCount: selectedCount,
                    generated: generated,
                    generating: generating,
                  ),
                ],
                if (showPreviewFailurePanel) ...[
                  const SizedBox(height: 16),
                  PreviewFailureActionPanel(
                    reason: previewFailureReason,
                    onOpenFolder: onOpenPreviewFailureFolder,
                    onViewLog: onViewLogDetails,
                  ),
                ],
                if (showCoverFailureActions) ...[
                  const SizedBox(height: 16),
                  CoverFailureActionPanel(
                    requestId: requestId,
                    onRetry: onGenerate,
                    onViewLog: onViewLogDetails,
                  ),
                ],
                const SizedBox(height: 16),
                if (!showCoverFailureActions &&
                    _shouldShowGenerationError(context, statusMessage))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GenerationErrorActionsPanel(
                      statusMessage: statusMessage,
                      requestId: requestId,
                      failure: creationFailure,
                      creationType: selectedCreationType,
                      onRetry: onGenerate,
                      onEditRequest: onEditCreationRequest,
                      onViewLogs: onViewLogDetails,
                    ),
                  ),
                if (showActivityPanel) ...[
                  ActivityTimelinePanel(
                    generated: generated,
                    generating: generating,
                    exported: exported,
                    creationPhase: creationPhase,
                    statusMessage: statusMessage,
                    requestId: requestId,
                    logLines: logLines,
                    onViewDetails: onViewLogDetails,
                  ),
                ],
                if (showExportPanel) ...[
                  const SizedBox(height: 16),
                  ExportResultPanel(
                    result: exportResult,
                    generated: generated,
                    shareCreating: shareCreating,
                    onOpenExportFolder: onOpenExportFolder,
                    onCreateShareLink: onCreateShareLink,
                    onCopyShareText: onCopyShareText,
                    onOpenShareLink: onOpenShareLink,
                    onCopyLongImage: onCopyLongImage,
                    onViewLogDetails: onViewLogDetails,
                  ),
                ],
              ],
            ),
          );
          if (constraints.maxWidth < 980) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  mainContent,
                  const SizedBox(height: 18),
                  controlPanel,
                ],
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: mainContent),
              const SizedBox(width: 22),
              SizedBox(width: 380, child: controlPanel),
            ],
          );
        },
      ),
    );
  }

  String _firstNonEmpty(List<String> options, String fallback) {
    final trimmedFallback = fallback.trim();
    if (trimmedFallback.isNotEmpty) return trimmedFallback;
    return options.isNotEmpty ? options.first : '';
  }

  bool _showCoverFailureActions(BuildContext context, String message) {
    final normalized = message.trim();
    if (normalized.isEmpty) return false;
    return normalized.contains(
          AppLocalizations.of(context)!.generateExportS419,
        ) &&
        normalized.contains(
          AppLocalizations.of(context)!.uploadStatusFailedLabel,
        );
  }
}

CreationMainStage _mainStageFor(
  CreationWorkflowPhase phase, {
  required bool generated,
  required bool exported,
}) {
  if (exported ||
      phase == CreationWorkflowPhase.exporting ||
      phase == CreationWorkflowPhase.published) {
    return CreationMainStage.share;
  }
  if (generated || phase == CreationWorkflowPhase.reviewing) {
    return CreationMainStage.preview;
  }
  return switch (phase) {
    CreationWorkflowPhase.preparing => CreationMainStage.prepare,
    CreationWorkflowPhase.planning ||
    CreationWorkflowPhase.planReady => CreationMainStage.plan,
    CreationWorkflowPhase.creatingJob ||
    CreationWorkflowPhase.environmentPreparing ||
    CreationWorkflowPhase.generating ||
    CreationWorkflowPhase.failed => CreationMainStage.generate,
    CreationWorkflowPhase.reviewing => CreationMainStage.preview,
    CreationWorkflowPhase.exporting ||
    CreationWorkflowPhase.published => CreationMainStage.share,
  };
}

class CreationStageStepper extends StatelessWidget {
  const CreationStageStepper({required this.currentStage, super.key});

  final CreationMainStage currentStage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stages = [
      _StageStepData(
        stage: CreationMainStage.prepare,
        title: l10n.creationPhasePreparing,
        iconAsset: editIconAsset,
      ),
      _StageStepData(
        stage: CreationMainStage.plan,
        title: l10n.creationPhasePlanConfirm,
        iconAsset: completeIconAsset,
      ),
      _StageStepData(
        stage: CreationMainStage.generate,
        title: l10n.creationPhaseGenerating,
        iconAsset: magicStarIconAsset,
      ),
      _StageStepData(
        stage: CreationMainStage.preview,
        title: l10n.creationPhasePreviewResult,
        iconAsset: viewIconAsset,
      ),
      _StageStepData(
        stage: CreationMainStage.share,
        title: l10n.creationPhaseExportShare,
        iconAsset: cloudUploadIconAsset,
      ),
    ];
    final currentIndex = stages.indexWhere(
      (step) => step.stage == currentStage,
    );
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.creationFlowTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < stages.length; index++)
                SizedBox(
                  width: 122,
                  child: _StageStep(
                    index: index + 1,
                    data: stages[index],
                    active: index == currentIndex,
                    complete: index < currentIndex,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StageStepData {
  const _StageStepData({
    required this.stage,
    required this.title,
    required this.iconAsset,
  });

  final CreationMainStage stage;
  final String title;
  final String iconAsset;
}

class _StageStep extends StatelessWidget {
  const _StageStep({
    required this.index,
    required this.data,
    required this.active,
    required this.complete,
  });

  final int index;
  final _StageStepData data;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final foreground = complete || active
        ? const Color(0xff168542)
        : const Color(0xff8c7c6d);
    final background = active
        ? const Color(0xffe8f4ea)
        : complete
        ? const Color(0xfff0f7ed)
        : const Color(0xfff6f0e8);
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? const Color(0xffb6dec0) : const Color(0xffeadbc9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: active || complete
                    ? const Color(0xff168542)
                    : const Color(0xffd8cbbd),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AppAssetIcon(data.iconAsset, size: 17),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

bool _shouldShowGenerationError(BuildContext context, String statusMessage) {
  final message = statusMessage.trim();
  if (message.isEmpty) {
    return false;
  }
  if (message ==
      AppLocalizations.of(context)!.contentPreviewWaitingForGenerationLabel) {
    return false;
  }
  if (message == AppLocalizations.of(context)!.generateExportS662) {
    return false;
  }
  if (message.contains(AppLocalizations.of(context)!.generateExportS731)) {
    return false;
  }
  return message.contains(
        AppLocalizations.of(context)!.uploadStatusFailedLabel,
      ) ||
      message.contains(AppLocalizations.of(context)!.generateExportS472) ||
      message.contains(AppLocalizations.of(context)!.generateExportS214) ||
      message.contains(AppLocalizations.of(context)!.generateExportS875);
}

String _creationPhaseLabel(
  BuildContext context,
  CreationWorkflowPhase creationPhase,
) {
  final l10n = AppLocalizations.of(context)!;
  return switch (creationPhase) {
    CreationWorkflowPhase.preparing => l10n.creationPhasePreparing,
    CreationWorkflowPhase.planning => l10n.creationPhasePlanning,
    CreationWorkflowPhase.planReady => l10n.creationPhasePlanReady,
    CreationWorkflowPhase.creatingJob => l10n.creationPhaseCreatingJob,
    CreationWorkflowPhase.environmentPreparing =>
      l10n.creationPhaseEnvironmentPreparing,
    CreationWorkflowPhase.generating => l10n.creationPhaseGenerating,
    CreationWorkflowPhase.reviewing => l10n.creationPhaseReviewing,
    CreationWorkflowPhase.exporting => l10n.creationPhaseExporting,
    CreationWorkflowPhase.published => l10n.creationPhasePublished,
    CreationWorkflowPhase.failed => l10n.creationPhaseFailed,
  };
}

String _creationTypeLabel(BuildContext context, String creationType) {
  return switch (creationType) {
    'memory_book' => AppLocalizations.of(context)!.generateExportS740,
    'memoir_video' => AppLocalizations.of(context)!.generateExportS727,
    _ => AppLocalizations.of(context)!.generateExportS721,
  };
}

bool _creationPhaseHasReached(
  CreationWorkflowPhase current,
  CreationWorkflowPhase target,
) {
  const order = [
    CreationWorkflowPhase.preparing,
    CreationWorkflowPhase.planning,
    CreationWorkflowPhase.planReady,
    CreationWorkflowPhase.creatingJob,
    CreationWorkflowPhase.environmentPreparing,
    CreationWorkflowPhase.generating,
    CreationWorkflowPhase.reviewing,
    CreationWorkflowPhase.exporting,
    CreationWorkflowPhase.published,
  ];
  if (current == CreationWorkflowPhase.failed) return false;
  return order.indexOf(current) >= order.indexOf(target);
}

class SmartGenerateActions extends StatelessWidget {
  const SmartGenerateActions({
    required this.selectedCount,
    required this.generating,
    required this.selectedCreationType,
    required this.onGeneratePictureBook,
    required this.onGenerateMemoryAlbum,
    required this.onGenerateMemoryVideo,
    super.key,
  });

  final int selectedCount;
  final bool generating;
  final String selectedCreationType;
  final VoidCallback? onGeneratePictureBook;
  final VoidCallback? onGenerateMemoryAlbum;
  final VoidCallback? onGenerateMemoryVideo;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.generateExportS237,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              _StatusChip(
                label: selectedCount == 0
                    ? AppLocalizations.of(context)!.generateExportS800
                    : AppLocalizations.of(
                        context,
                      )!.generateExportSelectedAssetsLabel(selectedCount),
                color: selectedCount == 0
                    ? const Color(0xff9a5a14)
                    : const Color(0xff168542),
                background: selectedCount == 0
                    ? const Color(0xfffff4d8)
                    : const Color(0xffe8f4ea),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.generateExportS883,
            style: TextStyle(color: Color(0xff6f6258)),
          ),
          const SizedBox(height: 14),
          TextField(
            enabled: !generating,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.generateExportS243,
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: AppAssetIcon(magicStarIconAsset, size: 20),
              ),
              filled: true,
              fillColor: const Color(0xfffffcf7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffe8dccb)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffe8dccb)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff3f8c55)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CreativeTypeCard(
                  title: AppLocalizations.of(context)!.generateExportS721,
                  description: AppLocalizations.of(context)!.generateExportS717,
                  iconAsset: bookIconAsset,
                  selected: selectedCreationType == 'storybook',
                  onPressed: onGeneratePictureBook,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreativeTypeCard(
                  title: AppLocalizations.of(context)!.generateExportS740,
                  description: AppLocalizations.of(context)!.generateExportS532,
                  iconAsset: timelineIconAsset,
                  selected: selectedCreationType == 'memory_book',
                  onPressed: onGenerateMemoryAlbum,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreativeTypeCard(
                  title: AppLocalizations.of(context)!.generateExportS727,
                  description: AppLocalizations.of(context)!.generateExportS738,
                  iconAsset: playIconAsset,
                  selected: selectedCreationType == 'memoir_video',
                  onPressed: onGenerateMemoryVideo,
                ),
              ),
            ],
          ),
          if (selectedCount == 0) ...[
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.generateExportS859,
              style: TextStyle(
                color: Color(0xff9a5a14),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreativeTypeCard extends StatelessWidget {
  const _CreativeTypeCard({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String iconAsset;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? const Color(0xff14773c)
        : const Color(0xff2d241c);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(minHeight: 106),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffe8f4ea) : const Color(0xfffffcf7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xffb6dec0) : const Color(0xffe8dccb),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAssetIcon(iconAsset, size: 22),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff7a6a5b),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}

int _estimatedPageCount(int selectedCount) {
  if (selectedCount <= 0) return 1;
  return selectedCount * 3 > 12 ? 12 : selectedCount * 3;
}

class GenerationReadinessBadge extends StatelessWidget {
  const GenerationReadinessBadge({
    required this.generated,
    required this.generating,
    required this.exported,
    super.key,
  });

  final bool generated;
  final bool generating;
  final bool exported;

  @override
  Widget build(BuildContext context) {
    final title = exported
        ? AppLocalizations.of(context)!.generateExportS128
        : generated
        ? AppLocalizations.of(context)!.generateExportS731
        : generating
        ? AppLocalizations.of(context)!.generateExportS718
        : AppLocalizations.of(context)!.generateExportS272;
    final subtitle = exported
        ? AppLocalizations.of(context)!.generateExportS328
        : generated
        ? AppLocalizations.of(context)!.generateExportS335
        : generating
        ? AppLocalizations.of(context)!.generateExportS651
        : AppLocalizations.of(context)!.generateExportS427;
    final color = generated || exported
        ? const Color(0xff2faa61)
        : const Color(0xffffbd54);
    final icon = generated || exported
        ? completeIconAsset
        : generating
        ? refreshIconAsset
        : addIconAsset;

    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: AppAssetIcon(icon, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xff77685e)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GenerationEntrySummary extends StatelessWidget {
  const GenerationEntrySummary({
    required this.selectedCount,
    required this.styleText,
    required this.sizeText,
    required this.onViewSelectedAssets,
    super.key,
  });

  final int selectedCount;
  final String styleText;
  final String sizeText;
  final VoidCallback onViewSelectedAssets;

  @override
  Widget build(BuildContext context) {
    final hasAssets = selectedCount > 0;
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: hasAssets
                  ? const Color(0xffe8f4ea)
                  : const Color(0xfffff4d8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasAssets
                    ? const Color(0xffb6dec0)
                    : const Color(0xffefd39a),
              ),
            ),
            child: AppAssetIcon(
              hasAssets ? completeIconAsset : dashedAddIconAsset,
              size: 34,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.generateExportS473,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _TaskFact(
                      label: AppLocalizations.of(
                        context,
                      )!.generateExportTaskGoalLabel,
                      value: AppLocalizations.of(
                        context,
                      )!.generateExportTaskGoalPictureBook,
                    ),
                    _TaskFact(
                      label: AppLocalizations.of(context)!.generateExportS708,
                      value: hasAssets
                          ? AppLocalizations.of(context)!.generateExportS813
                          : AppLocalizations.of(context)!.generateExportS819,
                      emphasis: !hasAssets,
                    ),
                    _TaskFact(
                      label: AppLocalizations.of(context)!.generateExportS460,
                      value: AppLocalizations.of(
                        context,
                      )!.contentMetricItemCount(selectedCount),
                    ),
                    _TaskFact(
                      label: AppLocalizations.of(
                        context,
                      )!.generateExportSuggestedAssetsLabel,
                      value: AppLocalizations.of(
                        context,
                      )!.generateExportSuggestedAssetsValue,
                    ),
                    _TaskFact(
                      label: AppLocalizations.of(context)!.generateExportS884,
                      value: AppLocalizations.of(context)!
                          .generateExportLongImageOption(
                            _compactOption(context, sizeText),
                          ),
                    ),
                    _TaskFact(
                      label: AppLocalizations.of(context)!.generateExportS956,
                      value: _compactOption(context, styleText),
                    ),
                  ],
                ),
                if (!hasAssets) ...[
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.generateExportS868,
                    style: TextStyle(color: Color(0xff7a6a5b), height: 1.45),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusChip(
                  label: hasAssets
                      ? AppLocalizations.of(context)!.generateExportS795
                      : AppLocalizations.of(context)!.generateExportS800,
                  color: hasAssets
                      ? const Color(0xff168542)
                      : const Color(0xff9a5a14),
                  background: hasAssets
                      ? const Color(0xffe8f4ea)
                      : const Color(0xfffff4d8),
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: hasAssets
                      ? AppLocalizations.of(context)!.generateExportS627
                      : AppLocalizations.of(context)!.generateExportS324,
                  iconAsset: gridIconAsset,
                  onPressed: onViewSelectedAssets,
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: AppLocalizations.of(context)!.generateExportS102,
                  iconAsset: magicStarIconAsset,
                  onPressed: onViewSelectedAssets,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskFact extends StatelessWidget {
  const _TaskFact({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) => Container(
    width: 180,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: emphasis ? const Color(0xfffff4d8) : const Color(0xfffffcf7),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xffe8dccb)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xff7a6a5b), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: emphasis ? const Color(0xff9a5a14) : const Color(0xff2d241c),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.24)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

String _compactOption(BuildContext context, String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return AppLocalizations.of(context)!.generateExportS957;
  }
  return normalized.split(RegExp(r'\s{2,}')).first.trim();
}

class GeneratedWorkSummary extends StatelessWidget {
  const GeneratedWorkSummary({
    required this.selectedCount,
    required this.generationState,
    required this.styleText,
    required this.sizeText,
    required this.exportLabel,
    required this.exported,
    super.key,
  });

  final int selectedCount;
  final String generationState;
  final String styleText;
  final String sizeText;
  final String exportLabel;
  final bool exported;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        WarmPicture(
          assetPath: bookIconAsset,
          label: AppLocalizations.of(context)!.generateExportS617,
          height: 180,
          width: 190,
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.generateExportS617,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.generateExportSummaryText(
                  selectedCount,
                  generationState,
                  styleText,
                  sizeText,
                  exportLabel,
                ),
              ),
            ],
          ),
        ),
        StatusStack(
          selectedCount: selectedCount,
          generated: true,
          exported: exported,
        ),
      ],
    ),
  );
}

class GenerationFlowProgress extends StatelessWidget {
  const GenerationFlowProgress({
    required this.selectedCount,
    required this.generated,
    required this.generating,
    required this.exported,
    required this.creationPhase,
    required this.exportLabel,
    this.backendSteps = const [],
    super.key,
  });

  final int selectedCount;
  final bool generated;
  final bool generating;
  final bool exported;
  final CreationWorkflowPhase creationPhase;
  final String exportLabel;
  final List<CreationPlanStepVm> backendSteps;

  @override
  Widget build(BuildContext context) {
    final hasAssets = selectedCount > 0;
    final planComplete =
        generated ||
        exported ||
        _creationPhaseHasReached(
          creationPhase,
          CreationWorkflowPhase.creatingJob,
        );
    final storyComplete =
        generated ||
        exported ||
        _creationPhaseHasReached(
          creationPhase,
          CreationWorkflowPhase.reviewing,
        );
    final steps = backendSteps.isNotEmpty
        ? [
            for (final step in backendSteps)
              _PlanStepData(
                icon: _backendStepIcon(step.status),
                title: step.label,
                body: step.detail.isNotEmpty ? step.detail : step.status,
                active: _isBackendStepActive(step.status),
                complete: _isBackendStepComplete(step.status),
              ),
          ]
        : creationPhase == CreationWorkflowPhase.planning
        ? _agentPlanningSteps(context, selectedCount)
        : _localFiveStageProgressSteps(
            context,
            selectedCount: selectedCount,
            generated: generated,
            generating: generating,
            exported: exported,
            creationPhase: creationPhase,
            exportLabel: exportLabel,
            hasAssets: hasAssets,
            planComplete: planComplete,
            storyComplete: storyComplete,
          );

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            backendSteps.isNotEmpty
                ? AppLocalizations.of(context)!.generationBackendStepsTitle
                : AppLocalizations.of(context)!.generationLocalProgressTitle,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var index = 0; index < steps.length; index++)
                SizedBox(
                  width: 176,
                  child: _FlowStep(index: index + 1, data: steps[index]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

List<_PlanStepData> _agentPlanningSteps(
  BuildContext context,
  int selectedCount,
) {
  final l10n = AppLocalizations.of(context)!;
  return [
    _PlanStepData(
      icon: imageIconAsset,
      title: l10n.creationPlanningAnalyzeAssetsTitle,
      body: l10n.creationPlanningAnalyzeAssetsBody(selectedCount),
      active: true,
      complete: false,
    ),
    _PlanStepData(
      icon: magicStarIconAsset,
      title: l10n.creationPlanningSelectSkillTitle,
      body: l10n.creationPlanningSelectSkillBody,
      active: true,
      complete: false,
    ),
    _PlanStepData(
      icon: timelineIconAsset,
      title: l10n.creationPlanningGeneratePlanTitle,
      body: l10n.creationPlanningGeneratePlanBody,
      active: true,
      complete: false,
    ),
  ];
}

List<_PlanStepData> _localFiveStageProgressSteps(
  BuildContext context, {
  required int selectedCount,
  required bool generated,
  required bool generating,
  required bool exported,
  required CreationWorkflowPhase creationPhase,
  required String exportLabel,
  required bool hasAssets,
  required bool planComplete,
  required bool storyComplete,
}) {
  final l10n = AppLocalizations.of(context)!;
  return [
    _PlanStepData(
      icon: editIconAsset,
      title: l10n.creationPhasePreparing,
      body: hasAssets
          ? l10n.generateExportSelectedAssetsShort(selectedCount)
          : l10n.generateExportS800,
      active: !hasAssets,
      complete: hasAssets,
    ),
    _PlanStepData(
      icon: completeIconAsset,
      title: l10n.creationPhasePlanConfirm,
      body: creationPhase == CreationWorkflowPhase.planReady
          ? l10n.creationPlanReadySubtitle
          : planComplete
          ? l10n.creationPhasePlanReady
          : l10n.creationPlanningStatus,
      active:
          creationPhase == CreationWorkflowPhase.planning ||
          creationPhase == CreationWorkflowPhase.planReady,
      complete: planComplete,
    ),
    _PlanStepData(
      icon: magicStarIconAsset,
      title: l10n.creationPhaseGenerating,
      body: creationPhase == CreationWorkflowPhase.environmentPreparing
          ? l10n.creationEnvironmentPreparingStatus
          : creationPhase == CreationWorkflowPhase.creatingJob
          ? l10n.creationCreatingJobStatus
          : generating
          ? l10n.generateExportS647
          : generated
          ? l10n.generateExportS547
          : l10n.generateExportS797,
      active:
          creationPhase == CreationWorkflowPhase.creatingJob ||
          creationPhase == CreationWorkflowPhase.environmentPreparing ||
          creationPhase == CreationWorkflowPhase.generating ||
          creationPhase == CreationWorkflowPhase.failed,
      complete: storyComplete,
    ),
    _PlanStepData(
      icon: viewIconAsset,
      title: l10n.creationPhasePreviewResult,
      body: generated ? l10n.generateExportS332 : l10n.generateExportS725,
      active: creationPhase == CreationWorkflowPhase.reviewing,
      complete: generated,
    ),
    _PlanStepData(
      icon: cloudUploadIconAsset,
      title: l10n.creationPhaseExportShare,
      body: exported
          ? l10n.generateExportExportedState(exportLabel)
          : l10n.generateExportS794,
      active:
          creationPhase == CreationWorkflowPhase.exporting ||
          creationPhase == CreationWorkflowPhase.published ||
          exported,
      complete: exported,
    ),
  ];
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({required this.index, required this.data});

  final int index;
  final _PlanStepData data;

  @override
  Widget build(BuildContext context) {
    final background = data.complete
        ? const Color(0xffeaf7ee)
        : data.active
        ? const Color(0xfffff4df)
        : const Color(0xfff4efe7);
    final foreground = data.complete
        ? const Color(0xff168542)
        : data.active
        ? const Color(0xff9a5a14)
        : const Color(0xff7a6a5b);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foreground.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white.withValues(alpha: 0.75),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AppAssetIcon(data.icon, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            data.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff77685e),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

String _backendStepIcon(String status) {
  return switch (status) {
    'succeeded' || 'generated' || 'exported' => completeIconAsset,
    'running' || 'in_progress' || 'pending' => refreshIconAsset,
    'failed' || 'cancelled' => stopIconAsset,
    _ => emptyTagIconAsset,
  };
}

bool _isBackendStepActive(String status) {
  return status == 'running' || status == 'in_progress' || status == 'pending';
}

bool _isBackendStepComplete(String status) {
  return status == 'succeeded' ||
      status == 'generated' ||
      status == 'exported' ||
      status == 'shared';
}

class _PlanStepData {
  const _PlanStepData({
    required this.icon,
    required this.title,
    required this.body,
    required this.active,
    required this.complete,
  });

  final String icon;
  final String title;
  final String body;
  final bool active;
  final bool complete;
}

class AssetInputCard extends StatelessWidget {
  const AssetInputCard({
    required this.count,
    required this.onViewSelectedAssets,
    super.key,
  });

  final int count;
  final VoidCallback onViewSelectedAssets;

  @override
  Widget build(BuildContext context) {
    final hasAssets = count > 0;
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAssets
                      ? AppLocalizations.of(
                          context,
                        )!.generateExportAssetInputSelectedTitle(count)
                      : AppLocalizations.of(context)!.generateExportS808,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasAssets
                      ? AppLocalizations.of(context)!.generateExportS893
                      : AppLocalizations.of(context)!.generateExportS889,
                  style: const TextStyle(
                    color: Color(0xff7a6a5b),
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 12),
                if (hasAssets)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (var index = 0; index < math.min(count, 8); index++)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xfffff4d8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xffe8dccb)),
                          ),
                          child: const AppAssetIcon(imageIconAsset, size: 20),
                        ),
                      if (count > 8)
                        Text(
                          '+${count - 8}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            direction: Axis.vertical,
            children: [
              SecondaryButton(
                label: hasAssets
                    ? AppLocalizations.of(context)!.generateExportS923
                    : AppLocalizations.of(context)!.generateExportS324,
                iconAsset: gridIconAsset,
                onPressed: onViewSelectedAssets,
              ),
              SecondaryButton(
                label: hasAssets
                    ? AppLocalizations.of(context)!.generateExportS841
                    : AppLocalizations.of(context)!.generateExportS102,
                iconAsset: magicStarIconAsset,
                onPressed: onViewSelectedAssets,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreativePreviewPanel extends StatelessWidget {
  const CreativePreviewPanel({
    required this.selectedCount,
    required this.generated,
    required this.generating,
    super.key,
  });

  final int selectedCount;
  final bool generated;
  final bool generating;

  @override
  Widget build(BuildContext context) {
    final pageCount = _estimatedPageCount(selectedCount);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  generated
                      ? AppLocalizations.of(
                          context,
                        )!.generateExportPagePreviewCount(pageCount)
                      : AppLocalizations.of(context)!.generateExportS943,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusChip(
                label: generating
                    ? AppLocalizations.of(context)!.generateExportS718
                    : generated
                    ? AppLocalizations.of(context)!.generateExportS334
                    : AppLocalizations.of(
                        context,
                      )!.contentPreviewWaitingForGenerationLabel,
                color: generating
                    ? const Color(0xff9a5a14)
                    : generated
                    ? const Color(0xff168542)
                    : const Color(0xff7a6a5b),
                background: generating
                    ? const Color(0xfffff4d8)
                    : generated
                    ? const Color(0xffe8f4ea)
                    : const Color(0xfff6f0e8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            generating
                ? AppLocalizations.of(context)!.generateExportS663
                : generated
                ? AppLocalizations.of(context)!.generateExportS420
                : AppLocalizations.of(context)!.generateExportS954,
            style: const TextStyle(color: Color(0xff7a6a5b), height: 1.45),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _PreviewTile(
                title: generated
                    ? AppLocalizations.of(context)!.generateExportS419
                    : AppLocalizations.of(context)!.generateExportS419,
                iconAsset: bookIconAsset,
                active: generated,
              ),
              const SizedBox(width: 12),
              _PreviewTile(
                title: generated
                    ? AppLocalizations.of(context)!.generateExportS790
                    : AppLocalizations.of(context)!.generateExportS548,
                iconAsset: a4FileIconAsset,
                active: generated,
              ),
              const SizedBox(width: 12),
              _PreviewTile(
                title: generated
                    ? AppLocalizations.of(context)!.generateExportS413
                    : AppLocalizations.of(context)!.generateExportS413,
                iconAsset: pdfIconAsset,
                active: generated,
              ),
            ],
          ),
          if (generating) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                minHeight: 8,
                backgroundColor: Color(0xfffff0df),
                color: Color(0xff3f8c55),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.title,
    required this.iconAsset,
    required this.active,
  });

  final String title;
  final String iconAsset;
  final bool active;

  @override
  Widget build(BuildContext context) => Expanded(
    child: AspectRatio(
      aspectRatio: 1.55,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? const Color(0xfffffcf7) : const Color(0xfff6f0e8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffe8dccb)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAssetIcon(iconAsset, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ),
  );
}

class GenerationEntryLog extends StatelessWidget {
  const GenerationEntryLog({required this.statusMessage, super.key});

  final String statusMessage;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.generateExportS108,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(
                  context,
                )!.generateExportActivityEmptyMessage(statusMessage),
                style: const TextStyle(color: Color(0xff6f6258), height: 1.45),
              ),
            ],
          ),
        ),
        SecondaryButton(
          label: AppLocalizations.of(context)!.generateExportS726,
          iconAsset: timelineIconAsset,
          onPressed: null,
        ),
      ],
    ),
  );
}

class ActivityTimelinePanel extends StatelessWidget {
  const ActivityTimelinePanel({
    required this.generated,
    required this.generating,
    required this.exported,
    required this.creationPhase,
    required this.statusMessage,
    required this.requestId,
    required this.logLines,
    required this.onViewDetails,
    super.key,
  });

  final bool generated;
  final bool generating;
  final bool exported;
  final CreationWorkflowPhase creationPhase;
  final String statusMessage;
  final String requestId;
  final List<String> logLines;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final entries = logLines.isEmpty
        ? [AppLocalizations.of(context)!.generateExportS796]
        : logLines.map((line) => _ordinaryTimelineText(context, line)).toList();
    final ordinaryStatusMessage = _ordinaryTimelineText(context, statusMessage);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.generateExportS108,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              _StatusChip(
                label: creationPhase != CreationWorkflowPhase.preparing
                    ? _creationPhaseLabel(context, creationPhase)
                    : exported
                    ? AppLocalizations.of(context)!.generateExportS442
                    : generated
                    ? AppLocalizations.of(context)!.generateExportS794
                    : generating
                    ? AppLocalizations.of(context)!.generateExportS895
                    : AppLocalizations.of(context)!.generateExportS795,
                color:
                    exported ||
                        generated ||
                        creationPhase == CreationWorkflowPhase.published ||
                        creationPhase == CreationWorkflowPhase.reviewing
                    ? const Color(0xff168542)
                    : generating ||
                          creationPhase == CreationWorkflowPhase.planning ||
                          creationPhase == CreationWorkflowPhase.creatingJob ||
                          creationPhase == CreationWorkflowPhase.exporting
                    ? const Color(0xff9a5a14)
                    : const Color(0xff7a6a5b),
                background:
                    exported ||
                        generated ||
                        creationPhase == CreationWorkflowPhase.published ||
                        creationPhase == CreationWorkflowPhase.reviewing
                    ? const Color(0xffe8f4ea)
                    : generating ||
                          creationPhase == CreationWorkflowPhase.planning ||
                          creationPhase == CreationWorkflowPhase.creatingJob ||
                          creationPhase == CreationWorkflowPhase.exporting
                    ? const Color(0xfffff4d8)
                    : const Color(0xfff6f0e8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < entries.take(5).length; index++)
            _TimelineEntry(
              text: entries[index],
              active: index == entries.length - 1 && generating,
              complete: generated || exported || index < entries.length - 1,
            ),
          if (ordinaryStatusMessage.trim().isNotEmpty && logLines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                AppLocalizations.of(
                  context,
                )!.generateExportCurrentStatusLine(ordinaryStatusMessage),
                style: const TextStyle(
                  color: Color(0xff7a6a5b),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: logLines.isEmpty
                ? AppLocalizations.of(context)!.generateExportS726
                : AppLocalizations.of(context)!.contentViewDetailsLabel,
            iconAsset: timelineIconAsset,
            onPressed: logLines.isEmpty ? null : onViewDetails,
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.text,
    required this.active,
    required this.complete,
  });

  final String text;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final color = complete
        ? const Color(0xff3f8c55)
        : active
        ? const Color(0xff9a5a14)
        : const Color(0xffc7b8a7);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(radius: 5, backgroundColor: color),
              Container(width: 1, height: 22, color: const Color(0xffe8dccb)),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xff5d5148), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class GenerationErrorActionsPanel extends StatelessWidget {
  const GenerationErrorActionsPanel({
    required this.statusMessage,
    required this.requestId,
    required this.failure,
    required this.creationType,
    required this.onRetry,
    required this.onEditRequest,
    required this.onViewLogs,
    super.key,
  });

  final String statusMessage;
  final String requestId;
  final CreationFailureVm? failure;
  final String creationType;
  final VoidCallback onRetry;
  final VoidCallback onEditRequest;
  final VoidCallback onViewLogs;

  @override
  Widget build(BuildContext context) {
    final title =
        statusMessage.contains(AppLocalizations.of(context)!.generateExportS419)
        ? AppLocalizations.of(context)!.generateExportS421
        : AppLocalizations.of(context)!.generateExportS729;
    final failureVm = failure;
    final reason = failureVm?.reason.isNotEmpty == true
        ? failureVm!.reason
        : _extractReason(context, statusMessage);
    final ordinaryReason = _ordinaryTimelineText(context, reason);
    return SurfaceCard(
      backgroundColor: const Color(0xfffff4f3),
      borderColor: const Color(0xffefc8c4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xff8f3226),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(
              context,
            )!.generateExportReasonLine(ordinaryReason),
            style: const TextStyle(color: Color(0xff6f6258), height: 1.45),
          ),
          if (failureVm?.stepLabel.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.creationFailureStepLine(failureVm!.stepLabel),
              style: const TextStyle(
                color: Color(0xff6f6258),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (failureVm?.code.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(
                context,
              )!.creationFailureCodeLine(failureVm!.code),
              style: const TextStyle(color: Color(0xff8f6a60), fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(
                label: _generationFailureRetryLabel(
                  context,
                  failureVm,
                  creationType,
                ),
                iconAsset: refreshIconAsset,
                onPressed: onRetry,
              ),
              SecondaryButton(
                label: AppLocalizations.of(
                  context,
                )!.generateExportEditRequestLabel,
                iconAsset: editIconAsset,
                onPressed: onEditRequest,
              ),
              SecondaryButton(
                label: AppLocalizations.of(context)!.generateExportS624,
                iconAsset: timelineIconAsset,
                onPressed: onViewLogs,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _extractReason(BuildContext context, String message) {
    final normalized = message.trim();
    if (normalized.isEmpty) {
      return AppLocalizations.of(context)!.generateExportS226;
    }
    final colonIndex = normalized.indexOf('：');
    if (colonIndex >= 0 && colonIndex + 1 < normalized.length) {
      return normalized.substring(colonIndex + 1).trim();
    }
    return normalized;
  }
}

String _generationFailureRetryLabel(
  BuildContext context,
  CreationFailureVm? failure,
  String creationType,
) {
  if (failure == null) {
    return AppLocalizations.of(context)!.actionRetryLabel;
  }
  final category = failure.category.toLowerCase();
  if (creationType == 'memoir_video' ||
      category.contains('hyperframes') ||
      category.contains('environment')) {
    return AppLocalizations.of(context)!.generateExportS921;
  }
  return AppLocalizations.of(context)!.creationReplanAction;
}

class CreationPlanConfirmationPanel extends StatelessWidget {
  const CreationPlanConfirmationPanel({
    required this.plan,
    required this.onConfirm,
    required this.onEditRequest,
    super.key,
  });

  final CreationPlanPreviewVm plan;
  final VoidCallback onConfirm;
  final VoidCallback onEditRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleSteps = plan.steps.take(5).toList(growable: false);
    final visibleRequirements = plan.requirements
        .take(4)
        .toList(growable: false);
    return SurfaceCard(
      backgroundColor: const Color(0xfff6fbf2),
      borderColor: const Color(0xffc8e4bf),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppAssetIcon(completeIconAsset, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.creationPlanConfirmationTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusChip(
                label: l10n.creationPhasePlanReady,
                color: const Color(0xff168542),
                background: const Color(0xffe8f4ea),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (plan.summary.isNotEmpty)
            Text(
              plan.summary,
              style: const TextStyle(color: Color(0xff4f443c), height: 1.45),
            ),
          const SizedBox(height: 12),
          _ConsoleFact(
            label: l10n.creationPlanSkillLabel,
            value: plan.skillName.isEmpty
                ? l10n.creationPlanUnknownSkill
                : plan.skillName,
          ),
          if (visibleSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.creationPlanStepsLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < visibleSteps.length; index++)
              _PlanPreviewStep(index: index + 1, step: visibleSteps[index]),
          ],
          if (visibleRequirements.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.creationPlanRequirementsLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final requirement in visibleRequirements)
                  _StatusChip(
                    label: requirement,
                    color: const Color(0xff5d5148),
                    background: const Color(0xfffffcf7),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 240,
                child: PrimaryButton(
                  label: l10n.creationConfirmPlanAction,
                  iconAsset: playIconAsset,
                  onPressed: onConfirm,
                  height: 48,
                ),
              ),
              SecondaryButton(
                label: l10n.generateExportEditRequestLabel,
                iconAsset: editIconAsset,
                onPressed: onEditRequest,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanPreviewStep extends StatelessWidget {
  const _PlanPreviewStep({required this.index, required this.step});

  final int index;
  final CreationPlanStepVm step;

  @override
  Widget build(BuildContext context) {
    final detail = step.detail.isNotEmpty ? step.detail : step.status;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xffe8f4ea),
            child: Text(
              '$index',
              style: const TextStyle(
                color: Color(0xff168542),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: const TextStyle(
                      color: Color(0xff7a6a5b),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoverFailureActionPanel extends StatelessWidget {
  const CoverFailureActionPanel({
    required this.requestId,
    required this.onRetry,
    required this.onViewLog,
    super.key,
  });

  final String requestId;
  final VoidCallback onRetry;
  final VoidCallback onViewLog;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    backgroundColor: const Color(0xfffff4f1),
    borderColor: const Color(0xffffd5cd),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.generateExportS421,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xff9b3a2b),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.generateExportS315,
          style: TextStyle(color: Color(0xff6f6258), height: 1.45),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SecondaryButton(
              label: AppLocalizations.of(context)!.actionRetryLabel,
              iconAsset: refreshIconAsset,
              onPressed: onRetry,
            ),
            SecondaryButton(
              label: AppLocalizations.of(context)!.generateExportS624,
              iconAsset: timelineIconAsset,
              onPressed: onViewLog,
            ),
          ],
        ),
      ],
    ),
  );
}

class PreviewFailureActionPanel extends StatelessWidget {
  const PreviewFailureActionPanel({
    required this.reason,
    required this.onOpenFolder,
    required this.onViewLog,
    super.key,
  });

  final String reason;
  final VoidCallback? onOpenFolder;
  final VoidCallback onViewLog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trimmedReason = reason.trim();
    return SurfaceCard(
      backgroundColor: const Color(0xfffff4f1),
      borderColor: const Color(0xffffd5cd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.generateExportPreviewFailedTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xff9b3a2b),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.generateExportPreviewFailedBody,
            style: const TextStyle(color: Color(0xff6f6258), height: 1.45),
          ),
          if (trimmedReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.generateExportPreviewFailureReason(trimmedReason),
              style: const TextStyle(
                color: Color(0xff6f6258),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(
                label: l10n.generateExportS518,
                iconAsset: folderIconAsset,
                onPressed: onOpenFolder,
              ),
              SecondaryButton(
                label: l10n.generateExportS624,
                iconAsset: timelineIconAsset,
                onPressed: onViewLog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _ordinaryTimelineText(BuildContext context, String text) {
  final l10n = AppLocalizations.of(context)!;
  var sanitized = text.trim();
  if (sanitized.isEmpty) return sanitized;

  if (RegExp('jobId\\s*:', caseSensitive: false).hasMatch(sanitized)) {
    return l10n.exportGenerationStateS736;
  }

  final localizedPortKeyword = String.fromCharCodes([0x7aef, 0x53e3]);
  if (RegExp(
    r'\bpg_ctl\b|PostgreSQL|postgres|stdout:|stderr:|PID\s*=|dist/main\.js|KIDMEMORY_SIDECAR|'
    '$localizedPortKeyword\\s*\\d+|port\\s*\\d+',
    caseSensitive: false,
  ).hasMatch(sanitized)) {
    return l10n.setupLocalServicePreparing;
  }

  sanitized = sanitized.replaceAll(
    RegExp('Request ID\\s*:\\s*\\S+', caseSensitive: false),
    '',
  );
  sanitized = sanitized.replaceAll(
    RegExp('requestId\\s*[:=]\\s*\\S+', caseSensitive: false),
    '',
  );
  sanitized = sanitized.replaceAll(
    RegExp('Supabase\\s+Storage', caseSensitive: false),
    l10n.generateExportCloudStorageLabel,
  );
  sanitized = sanitized.replaceAll(
    RegExp('Supabase', caseSensitive: false),
    l10n.generateExportCloudStorageLabel,
  );
  sanitized = sanitized.replaceAll(
    RegExp('sidecar', caseSensitive: false),
    l10n.generateExportLocalServiceLabel,
  );

  sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();
  sanitized = sanitized.replaceAll(RegExp(r'\s+，'), '，').trim();
  return sanitized.isEmpty ? l10n.generateExportS796 : sanitized;
}

class GenerateSettingsPanel extends StatelessWidget {
  const GenerateSettingsPanel({
    required this.generated,
    required this.generating,
    required this.exported,
    required this.creationPhase,
    required this.selectedCount,
    required this.templateText,
    required this.creationTypeText,
    required this.sizeText,
    required this.styleText,
    required this.exportText,
    required this.exportTargets,
    required this.onGenerate,
    required this.onConfirmPlan,
    required this.onExport,
    required this.onExportTargetChanged,
    required this.onViewSelectedAssets,
    required this.onPreviewAllPages,
    super.key,
  });

  final bool generated;
  final bool generating;
  final bool exported;
  final CreationWorkflowPhase creationPhase;
  final int selectedCount;
  final String templateText;
  final String creationTypeText;
  final String sizeText;
  final String styleText;
  final String exportText;
  final List<String> exportTargets;
  final VoidCallback? onGenerate;
  final VoidCallback onConfirmPlan;
  final VoidCallback onExport;
  final ValueChanged<String> onExportTargetChanged;
  final VoidCallback? onViewSelectedAssets;
  final VoidCallback onPreviewAllPages;

  @override
  Widget build(BuildContext context) {
    final exportLabel = _exportDisplayName(context, exportText);
    final hasAssets = selectedCount > 0;
    final planReady = creationPhase == CreationWorkflowPhase.planReady;
    final subtitle = generated
        ? AppLocalizations.of(
            context,
          )!.generateExportReadyToExportSubtitle(exportLabel)
        : planReady
        ? AppLocalizations.of(context)!.creationPlanReadySubtitle
        : AppLocalizations.of(context)!.generateExportS871;
    final primaryLabel = generated
        ? (exported
              ? AppLocalizations.of(
                  context,
                )!.generateExportExportedState(exportLabel)
              : _exportButtonLabel(context, exportText))
        : planReady
        ? AppLocalizations.of(context)!.creationConfirmPlanAction
        : (generating
              ? _creationPhaseLabel(context, creationPhase)
              : AppLocalizations.of(
                  context,
                )!.generateExportStartPlanningAction);
    final primaryAction = generating
        ? null
        : (generated ? onExport : (planReady ? onConfirmPlan : onGenerate));
    final primaryIcon = generated ? pdfIconAsset : addIconAsset;
    final previewsVideo = _isMp4Target(context, exportText);

    return SurfaceCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.generateExportS741,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Color(0xff6f6258))),
            const SizedBox(height: 18),
            _ReadinessSummary(
              selectedCount: selectedCount,
              generated: generated,
              exported: exported,
            ),
            const SizedBox(height: 20),
            _SettingRow(
              title: AppLocalizations.of(context)!.generateExportS279,
              value: creationTypeText,
              iconAsset: bookIconAsset,
            ),
            ExportOption(
              title: AppLocalizations.of(context)!.generateExportS644,
              value: _compactOption(context, templateText),
              iconAsset: imageIconAsset,
            ),
            ExportOption(
              title: AppLocalizations.of(context)!.generateExportS942,
              value: _compactOption(context, sizeText),
              iconAsset: a4FileIconAsset,
            ),
            ExportOption(
              title: AppLocalizations.of(context)!.generateExportS553,
              value: _compactOption(context, styleText),
              iconAsset: brushIconAsset,
            ),
            ExportTargetSelector(
              value: exportText,
              options: exportTargets,
              onChanged: onExportTargetChanged,
            ),
            PrimaryButton(
              label: primaryLabel,
              onPressed: primaryAction,
              iconAsset: primaryIcon,
            ),
            const SizedBox(height: 14),
            generated
                ? SecondaryButton(
                    label: generating
                        ? AppLocalizations.of(context)!.generateExportS719
                        : AppLocalizations.of(context)!.generateExportS921,
                    iconAsset: refreshIconAsset,
                    fullWidth: true,
                    height: 48,
                    onPressed: generating ? null : onGenerate,
                  )
                : SecondaryButton(
                    label: AppLocalizations.of(context)!.generateExportS623,
                    iconAsset: gridIconAsset,
                    fullWidth: true,
                    height: 48,
                    onPressed: hasAssets ? onViewSelectedAssets : null,
                  ),
            if (!generated && !hasAssets) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.generateExportS860,
                style: TextStyle(
                  color: Color(0xff9a5a14),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 14),
            if (generated) ...[
              SecondaryButton(
                label: previewsVideo
                    ? AppLocalizations.of(
                        context,
                      )!.generateExportOpenVideoPreviewAction
                    : AppLocalizations.of(context)!.generateExportS951,
                iconAsset: previewsVideo ? playIconAsset : viewIconAsset,
                fullWidth: true,
                height: 48,
                onPressed: onPreviewAllPages,
              ),
              const SizedBox(height: 22),
              Text(
                AppLocalizations.of(
                  context,
                )!.generateExportDirectoryHint(exportLabel),
                style: const TextStyle(color: Color(0xffa57a3a), fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadinessSummary extends StatelessWidget {
  const _ReadinessSummary({
    required this.selectedCount,
    required this.generated,
    required this.exported,
  });

  final int selectedCount;
  final bool generated;
  final bool exported;

  @override
  Widget build(BuildContext context) {
    final hasAssets = selectedCount > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasAssets ? const Color(0xffe8f4ea) : const Color(0xfffff4d8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasAssets ? const Color(0xffb6dec0) : const Color(0xffefd39a),
        ),
      ),
      child: Column(
        children: [
          _ConsoleFact(
            label: AppLocalizations.of(context)!.generateExportS821,
            value: hasAssets
                ? AppLocalizations.of(
                    context,
                  )!.generateExportReadinessAssetRatio(selectedCount)
                : AppLocalizations.of(context)!.generateExportS83,
          ),
          const SizedBox(height: 8),
          _ConsoleFact(
            label: AppLocalizations.of(context)!.generateExportS227,
            value: exported
                ? AppLocalizations.of(context)!.generateExportS444
                : generated
                ? AppLocalizations.of(context)!.generateExportS450
                : hasAssets
                ? AppLocalizations.of(context)!.generateExportS795
                : AppLocalizations.of(context)!.generateExportS800,
          ),
          const SizedBox(height: 8),
          _ConsoleFact(
            label: AppLocalizations.of(context)!.generateExportCloudShareLabel,
            value: AppLocalizations.of(context)!.generateExportCloudShareValue,
          ),
        ],
      ),
    );
  }
}

class _ConsoleFact extends StatelessWidget {
  const _ConsoleFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: Color(0xff7a6a5b), fontSize: 13),
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    ],
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.value,
    required this.iconAsset,
  });

  final String title;
  final String value;
  final String iconAsset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xffeadbc9)),
          ),
          child: Row(
            children: [
              AppAssetIcon(iconAsset, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ExportTargetSelector extends StatelessWidget {
  const ExportTargetSelector({
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalizedOptions = options.isEmpty
        ? [AppLocalizations.of(context)!.generateExportDefaultPdfTarget]
        : options;
    final selected = normalizedOptions.contains(value)
        ? value
        : normalizedOptions.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.generateExportS417,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(selected),
            initialValue: selected,
            isExpanded: true,
            items: normalizedOptions
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.9),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: AppAssetIcon(pdfIconAsset, size: inlineIconSize),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xffeadbc9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xff2faa61)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExportResultPanel extends StatelessWidget {
  const ExportResultPanel({
    required this.generated,
    required this.shareCreating,
    this.result,
    this.onOpenExportFolder,
    this.onCreateShareLink,
    this.onCopyShareText,
    this.onOpenShareLink,
    this.onCopyLongImage,
    this.onViewLogDetails,
    super.key,
  });

  final bool generated;
  final bool shareCreating;
  final ExportResultVm? result;
  final VoidCallback? onOpenExportFolder;
  final VoidCallback? onCreateShareLink;
  final VoidCallback? onCopyShareText;
  final VoidCallback? onOpenShareLink;
  final VoidCallback? onCopyLongImage;
  final VoidCallback? onViewLogDetails;

  @override
  Widget build(BuildContext context) {
    final current = result;
    if (!generated && current == null) {
      return SurfaceCard(
        backgroundColor: const Color(0xfff6f0e8),
        borderColor: const Color(0xffeadbc9),
        child: Row(
          children: [
            const AppAssetIcon(downloadIconAsset, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.generateExportS735,
                style: const TextStyle(
                  color: Color(0xff7a6a5b),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final hasLocalFile = current?.localPath.trim().isNotEmpty == true;
    final hasShare = current?.shareText.trim().isNotEmpty == true;
    final hasShareUrl = current?.remoteUrl.trim().isNotEmpty == true;
    final canCopyImage = current?.isLongImage == true && hasLocalFile;
    final shareFailed =
        !shareCreating &&
        hasLocalFile &&
        current?.artifactId.trim().isNotEmpty == true &&
        !hasShareUrl &&
        (current?.errorReason.trim().contains(
              AppLocalizations.of(context)!.generateExportShareFailedStatus,
            ) ??
            false);
    final exportFailed =
        !shareCreating &&
        !hasLocalFile &&
        current?.storageStatus.trim() == 'failed' &&
        (current?.errorReason.trim().isNotEmpty ?? false);
    final status = current == null
        ? (generated
              ? AppLocalizations.of(context)!.generateExportS794
              : AppLocalizations.of(context)!.generateExportS724)
        : _storageStatusLabel(context, current.storageStatus);
    final remoteStatus = current == null
        ? AppLocalizations.of(context)!.generateExportS723
        : shareCreating
        ? AppLocalizations.of(context)!.generateExportShareCreatingStatus
        : shareFailed
        ? AppLocalizations.of(context)!.generateExportShareFailedStatus
        : current.remoteUrl.trim().isNotEmpty
        ? AppLocalizations.of(context)!.generateExportShareCreatedStatus
        : hasShare
        ? AppLocalizations.of(context)!.generateExportS329
        : AppLocalizations.of(context)!.generateExportS220;
    final error = current?.errorReason.trim() ?? '';

    return SurfaceCard(
      backgroundColor: current == null
          ? const Color(0xfff6f0e8)
          : const Color(0xfff4fbf8),
      borderColor: current == null
          ? const Color(0xffeadbc9)
          : const Color(0xffcdebd6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppAssetIcon(cloudUploadIconAsset, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.generateExportS418,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                status,
                style: const TextStyle(
                  color: Color(0xff31564a),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 28,
            runSpacing: 8,
            children: [
              _ExportFact(
                label: AppLocalizations.of(context)!.generateExportS611,
                value: hasLocalFile
                    ? current!.localPath
                    : AppLocalizations.of(context)!.generateExportS428,
              ),
              _ExportFact(
                label: AppLocalizations.of(context)!.generateExportS218,
                value: status,
              ),
              _ExportFact(
                label: AppLocalizations.of(context)!.generateExportS274,
                value: remoteStatus,
              ),
              if (error.isNotEmpty)
                _ExportFact(
                  label: AppLocalizations.of(context)!.generateExportS930,
                  value: error,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(
                label: AppLocalizations.of(context)!.generateExportS518,
                iconAsset: folderIconAsset,
                onPressed: hasLocalFile ? onOpenExportFolder : null,
              ),
              SecondaryButton(
                label: hasShare
                    ? AppLocalizations.of(context)!.generateExportS357
                    : hasShareUrl
                    ? AppLocalizations.of(context)!.generateExportCopyLinkLabel
                    : shareFailed
                    ? AppLocalizations.of(
                        context,
                      )!.generateExportRetryShareLabel
                    : AppLocalizations.of(
                        context,
                      )!.generateExportCreateShareLinkLabel,
                iconAsset: linkIconAsset,
                onPressed: hasShare || hasShareUrl
                    ? onCopyShareText
                    : hasLocalFile && !shareCreating
                    ? onCreateShareLink
                    : null,
              ),
              if (hasShareUrl)
                SecondaryButton(
                  label: AppLocalizations.of(
                    context,
                  )!.generateExportOpenLinkLabel,
                  iconAsset: viewIconAsset,
                  onPressed: onOpenShareLink,
                ),
              if (shareFailed || exportFailed)
                SecondaryButton(
                  label: AppLocalizations.of(context)!.generateExportS624,
                  iconAsset: infoIconAsset,
                  onPressed: onViewLogDetails,
                ),
              SecondaryButton(
                label: AppLocalizations.of(context)!.generateExportS358,
                iconAsset: imageFileIconAsset,
                onPressed: canCopyImage ? onCopyLongImage : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _actionReason(
              context,
              hasLocalFile: hasLocalFile,
              hasShare: hasShare,
              canCopyImage: canCopyImage,
              result: current,
              shareCreating: shareCreating,
            ),
            style: const TextStyle(color: Color(0xff8c7663), fontSize: 12),
          ),
          if (shareCreating) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.generateExportShareCreatingStatus,
              style: const TextStyle(
                color: Color(0xff31564a),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (current?.shareText.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              current!.shareText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff31564a),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _actionReason(
    BuildContext context, {
    required bool hasLocalFile,
    required bool hasShare,
    required bool canCopyImage,
    required ExportResultVm? result,
    required bool shareCreating,
  }) {
    if (!hasLocalFile) return AppLocalizations.of(context)!.generateExportS411;
    if (shareCreating) {
      return AppLocalizations.of(context)!.generateExportShareCreatingStatus;
    }
    if (!hasShare && result?.remoteUrl.trim().isEmpty != false) {
      return AppLocalizations.of(context)!.generateExportShareReadyHint;
    }
    if (!canCopyImage) return AppLocalizations.of(context)!.generateExportS476;
    return AppLocalizations.of(context)!.generateExportS275;
  }
}

class _ExportFact extends StatelessWidget {
  const _ExportFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Text(
      '$label：$value',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xff5d5148),
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

String _exportButtonLabel(BuildContext context, String exportText) {
  if (_isMp4Target(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportMp4Action;
  }
  if (_isJpgTarget(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportS404;
  }
  if (_isPngTarget(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportS406;
  }
  return AppLocalizations.of(context)!.generateExportS405;
}

String _exportDisplayName(BuildContext context, String exportText) {
  if (_isMp4Target(context, exportText)) {
    return 'MP4';
  }
  if (_isJpgTarget(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportS931;
  }
  if (_isPngTarget(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportS934;
  }
  return 'PDF';
}

bool _isPngTarget(BuildContext context, String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('png') ||
      exportText.contains(AppLocalizations.of(context)!.generateExportS934);
}

bool _isJpgTarget(BuildContext context, String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('jpg') ||
      normalized.contains('jpeg') ||
      exportText.contains(AppLocalizations.of(context)!.generateExportS931);
}

bool _isMp4Target(BuildContext context, String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('mp4') ||
      exportText.contains(
        AppLocalizations.of(context)!.generateExportVideoKeyword,
      );
}

String _storageStatusLabel(BuildContext context, String status) {
  final normalized = status.trim();
  if (normalized == 'synced') {
    return AppLocalizations.of(context)!.generateExportS438;
  }
  if (normalized == 'pending' || normalized == 'running') {
    return AppLocalizations.of(context)!.generateExportS336;
  }
  if (normalized == 'retry_wait') {
    return AppLocalizations.of(context)!.generateExportS802;
  }
  if (normalized == 'failed') {
    return AppLocalizations.of(context)!.generateExportS340;
  }
  if (normalized.isEmpty ||
      normalized == 'local_only' ||
      normalized == 'ready') {
    return AppLocalizations.of(context)!.generateExportS219;
  }
  return normalized;
}
