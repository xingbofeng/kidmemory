import 'package:flutter/material.dart';

import '../../shared/widgets/layout.dart';
import '../../../l10n/app_localizations.dart';
import 'generate_export_assets.dart';
import 'generate_export_models.dart';
import 'generate_export_utils.dart';
import 'widgets/activity_and_failures.dart';
import 'widgets/compose_stage.dart';
import 'widgets/creation_stage_stepper.dart';
import 'widgets/export_result_panel.dart';
import 'widgets/generation_progress.dart';
import 'widgets/plan_confirmation.dart';
import 'widgets/preview_panels.dart';
import 'widgets/settings_panel.dart';

export 'generate_export_models.dart';
export 'widgets/generation_progress.dart' show GenerationFlowProgress;

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
    this.creationTask,
    this.creationFailure,
    this.creationTaskSteps = const [],
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
  final CreationTaskPreviewVm? creationTask;
  final CreationFailureVm? creationFailure;
  final List<CreationTaskStepVm> creationTaskSteps;
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
            ...exportTargets.where(
              (target) => !isMp4ExportTarget(context, target),
            ),
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
    final exportLabel = exportDisplayName(context, exportText);
    final generationState = exported
        ? l10n.generateExportExportedState(exportLabel)
        : (generated
              ? AppLocalizations.of(context)!.generateExportS450
              : (generating
                    ? creationPhaseLabel(context, creationPhase)
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
    final mainStage = mainStageFor(
      creationPhase,
      generated: generated,
      exported: exported,
    );
    final showPlanConfirmation =
        creationTask != null &&
        creationPhase == CreationWorkflowPhase.planReady;
    final showGenerationProgress =
        creationTaskSteps.isNotEmpty ||
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
    final compactPrepareLayout =
        creationPhase == CreationWorkflowPhase.preparing &&
        !generated &&
        !exported;
    return PageFrame(
      title: AppLocalizations.of(context)!.assetStudioTitle,
      subtitle: AppLocalizations.of(context)!.generateExportS909,
      framePadding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      contentTopSpacing: 6,
      decoration: Padding(
        padding: const EdgeInsets.only(right: 410),
        child: Transform.translate(
          offset: const Offset(0, 12),
          child: SizedBox(
            width: 210,
            height: 66,
            child: Image.asset(creationTopBearIconAsset, fit: BoxFit.contain),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controlPanel = GenerateSettingsPanel(
            generated: generated,
            generating: generating,
            exported: exported,
            creationPhase: creationPhase,
            selectedCount: selectedCount,
            templateText: templateText,
            creationTypeText: creationTypeLabel(context, selectedCreationType),
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
          final prepareMainColumn = Column(
            children: [
              CreationStageStepper(currentStage: mainStage),
              const SizedBox(height: 5),
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
              const SizedBox(height: 5),
              AssetInputCard(
                count: selectedCount,
                onViewSelectedAssets: onViewSelectedAssets,
              ),
            ],
          );
          final prepareMainColumnNarrow = Column(
            children: [
              CreationStageStepper(currentStage: mainStage),
              const SizedBox(height: 1),
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
              const SizedBox(height: 1),
              AssetInputCard(
                count: selectedCount,
                onViewSelectedAssets: onViewSelectedAssets,
              ),
            ],
          );
          final mainColumn = Column(
            children: [
              CreationStageStepper(currentStage: mainStage),
              const SizedBox(height: 1),
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
              const SizedBox(height: 1),
              AssetInputCard(
                count: selectedCount,
                onViewSelectedAssets: onViewSelectedAssets,
              ),
              if (generated) ...[
                const SizedBox(height: 16),
                GeneratedWorkSummary(
                  selectedCount: selectedCount,
                  generationState: generationState,
                  styleText: styleText,
                  sizeText: sizeText,
                  exportLabel: exportLabel,
                  exported: exported,
                ),
              ],
              if (showGenerationProgress) ...[
                const SizedBox(height: 16),
                GenerationFlowProgress(
                  selectedCount: selectedCount,
                  generated: generated,
                  generating: generating,
                  exported: exported,
                  creationPhase: creationPhase,
                  exportLabel: exportLabel,
                  backendSteps: creationTaskSteps,
                ),
              ],
              if (showPlanConfirmation) ...[
                const SizedBox(height: 16),
                CreationPlanConfirmationPanel(
                  plan: creationTask!,
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
              if (!showCoverFailureActions &&
                  shouldShowGenerationError(context, statusMessage)) ...[
                const SizedBox(height: 16),
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
              ],
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
          );
          if (constraints.maxWidth < 980) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  compactPrepareLayout ? prepareMainColumnNarrow : mainColumn,
                  const SizedBox(height: 18),
                  controlPanel,
                ],
              ),
            );
          }
          if (compactPrepareLayout) {
            return ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                scrollbars: false,
              ),
              child: SingleChildScrollView(
                primary: false,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: prepareMainColumn),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 336,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: controlPanel,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final mainContent = ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              scrollbars: false,
            ),
            child: SingleChildScrollView(primary: false, child: mainColumn),
          );
          final sidebarContent = ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              scrollbars: false,
            ),
            child: SingleChildScrollView(
              primary: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: controlPanel,
              ),
            ),
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: mainContent),
              const SizedBox(width: 14),
              SizedBox(width: 336, child: sidebarContent),
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

void _noop() {}
