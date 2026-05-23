import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/content.dart';
import '../../../shared/widgets/layout.dart';
import '../generate_export_models.dart';
import '../generate_export_utils.dart';

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
  final List<CreationTaskStepVm> backendSteps;

  @override
  Widget build(BuildContext context) {
    final hasAssets = selectedCount > 0;
    final planComplete =
        generated ||
        exported ||
        creationPhaseHasReached(
          creationPhase,
          CreationWorkflowPhase.creatingJob,
        );
    final storyComplete =
        generated ||
        exported ||
        creationPhaseHasReached(creationPhase, CreationWorkflowPhase.reviewing);
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
