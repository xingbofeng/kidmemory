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
    this.remoteUrl = '',
    this.shareText = '',
    this.errorReason = '',
  });

  final String kind;
  final String localPath;
  final String storageStatus;
  final String remoteUrl;
  final String shareText;
  final String errorReason;

  bool get isLongImage => kind == 'long_image_png' || kind == 'long_image_jpg';

  factory ExportResultVm.fromJson(Map<String, dynamic> json) {
    return ExportResultVm(
      kind: json['kind'] as String? ?? '',
      localPath: json['localPath'] as String? ?? '',
      storageStatus: json['storageStatus'] as String? ?? '',
      remoteUrl: json['remoteUrl'] as String? ?? '',
      shareText: json['shareText'] as String? ?? '',
      errorReason: json['errorReason'] as String? ?? '',
    );
  }
}

class GenerateExportPage extends StatelessWidget {
  const GenerateExportPage({
    required this.selectedCount,
    required this.generated,
    required this.generating,
    required this.exported,
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
    required this.onGenerateSkipCover,
    required this.onExport,
    required this.onExportTargetChanged,
    this.exportResult,
    this.onOpenExportFolder,
    this.onCopyShareText,
    this.onCopyLongImage,
    this.onViewSelectedAssets = _noop,
    this.onPreviewAllPages = _noop,
    this.onViewLogDetails = _noop,
    super.key,
  });

  final int selectedCount;
  final bool generated;
  final bool generating;
  final bool exported;
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
  final VoidCallback onGenerate;
  final VoidCallback onGenerateSkipCover;
  final VoidCallback onExport;
  final ValueChanged<String> onExportTargetChanged;
  final ExportResultVm? exportResult;
  final VoidCallback? onOpenExportFolder;
  final VoidCallback? onCopyShareText;
  final VoidCallback? onCopyLongImage;
  final VoidCallback onViewSelectedAssets;
  final VoidCallback onPreviewAllPages;
  final VoidCallback onViewLogDetails;

  @override
  Widget build(BuildContext context) {
    final templates = templateOptions.isNotEmpty
        ? templateOptions
        : const ['温暖童趣'];
    final pageSizes = pageSizeOptions.isNotEmpty
        ? pageSizeOptions
        : const ['A4 竖版  210 × 297 mm'];
    final styles = styleOptions.isNotEmpty
        ? styleOptions
        : const ['温暖童趣  亲切温暖，适合儿童阅读'];
    final exportTargets = exportTargetOptions.isNotEmpty
        ? exportTargetOptions
        : const ['PDF 文件  高质量 PDF（打印级别）'];
    final templateText = _firstNonEmpty(templates, selectedTemplate);
    final sizeText = _firstNonEmpty(pageSizes, selectedPageSize);
    final styleText = _firstNonEmpty(styles, selectedStyle);
    final exportText = _firstNonEmpty(exportTargets, selectedExportTarget);
    final exportLabel = _exportDisplayName(exportText);
    final generationState = exported
        ? '$exportLabel 已导出'
        : (generated ? AppLocalizations.of(context)!.generateExportS450 : (generating ? AppLocalizations.of(context)!.generateExportS718 : AppLocalizations.of(context)!.contentPreviewWaitingForGenerationLabel));
    final showCoverFailureActions = _showCoverFailureActions(statusMessage);
    final canGenerate = selectedCount > 0 && !generating;
    return PageFrame(
      title: AppLocalizations.of(context)!.assetStudioTitle,
      subtitle: AppLocalizations.of(context)!.generateExportS909,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controlPanel = GenerateSettingsPanel(
            generated: generated,
            generating: generating,
            exported: exported,
            selectedCount: selectedCount,
            templateText: templateText,
            sizeText: sizeText,
            styleText: styleText,
            exportText: exportText,
            exportTargets: exportTargets,
            onGenerate: canGenerate ? onGenerate : null,
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
                SmartGenerateActions(
                  selectedCount: selectedCount,
                  generating: generating,
                  onGeneratePictureBook: canGenerate
                      ? () => _showCoverConfirmDialog(
                          context: context,
                          onContinue: onGenerate,
                          onSkipCover: onGenerateSkipCover,
                        )
                      : null,
                  onGenerateMemoryAlbum: canGenerate
                      ? () => _showCoverConfirmDialog(
                          context: context,
                          onContinue: onGenerate,
                          onSkipCover: onGenerateSkipCover,
                        )
                      : null,
                  onGenerateMemoryVideo: canGenerate ? onGenerate : null,
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
                const SizedBox(height: 16),
                GenerationFlowProgress(
                  selectedCount: selectedCount,
                  generated: generated,
                  generating: generating,
                  exported: exported,
                  exportLabel: exportLabel,
                ),
                const SizedBox(height: 16),
                CreativePreviewPanel(
                  selectedCount: selectedCount,
                  generated: generated,
                  generating: generating,
                ),
                if (showCoverFailureActions) ...[
                  const SizedBox(height: 16),
                  CoverFailureActionPanel(
                    requestId: requestId,
                    onRetry: onGenerate,
                    onSkipAndContinue: onGenerateSkipCover,
                    onViewLog: onViewLogDetails,
                  ),
                ],
                const SizedBox(height: 16),
                if (!showCoverFailureActions &&
                    _shouldShowGenerationError(statusMessage))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GenerationErrorActionsPanel(
                      statusMessage: statusMessage,
                      requestId: requestId,
                      onRetry: onGenerate,
                      onSkipCover: onGenerateSkipCover,
                      onViewLogs: onViewLogDetails,
                    ),
                  ),
                ActivityTimelinePanel(
                  generated: generated,
                  generating: generating,
                  exported: exported,
                  statusMessage: statusMessage,
                  requestId: requestId,
                  logLines: logLines,
                  onViewDetails: onViewLogDetails,
                ),
                const SizedBox(height: 16),
                ExportResultPanel(
                  result: exportResult,
                  generated: generated,
                  onOpenExportFolder: onOpenExportFolder,
                  onCopyShareText: onCopyShareText,
                  onCopyLongImage: onCopyLongImage,
                ),
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

  void _showCoverConfirmDialog({
    required BuildContext context,
    required VoidCallback onContinue,
    required VoidCallback onSkipCover,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.generateExportS769)),
        content: const Text('将使用免费生图服务生成封面图。\n不会上传孩子照片，只会发送文字描述。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onContinue();
            },
            child: Text(AppLocalizations.of(context)!.generateExportS833)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onSkipCover();
            },
            child: Text(AppLocalizations.of(context)!.generateExportS876)),
          ),
        ],
      ),
    );
  }

  bool _showCoverFailureActions(String message) {
    final normalized = message.trim();
    if (normalized.isEmpty) return false;
    return normalized.contains(AppLocalizations.of(context)!.generateExportS419) && normalized.contains(AppLocalizations.of(context)!.uploadStatusFailedLabel);
  }
}

bool _shouldShowGenerationError(String statusMessage) {
  final message = statusMessage.trim();
  if (message.isEmpty) return false;
  if (message == AppLocalizations.of(context)!.contentPreviewWaitingForGenerationLabel) return false;
  if (message == AppLocalizations.of(context)!.generateExportS662) return false;
  if (message.contains(AppLocalizations.of(context)!.generateExportS731)) return false;
  return message.contains(AppLocalizations.of(context)!.uploadStatusFailedLabel) ||
      message.contains(AppLocalizations.of(context)!.generateExportS472) ||
      message.contains(AppLocalizations.of(context)!.generateExportS214) ||
      message.contains(AppLocalizations.of(context)!.generateExportS875);
}

class SmartGenerateActions extends StatelessWidget {
  const SmartGenerateActions({
    required this.selectedCount,
    required this.generating,
    required this.onGeneratePictureBook,
    required this.onGenerateMemoryAlbum,
    required this.onGenerateMemoryVideo,
    super.key,
  });

  final int selectedCount;
  final bool generating;
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
                label: selectedCount == 0 ? AppLocalizations.of(context)!.generateExportS800 : '已选 $selectedCount 张素材',
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
              prefixIcon: const Icon(
                Icons.auto_awesome_outlined,
                color: Color(0xff3f8c55),
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
                  icon: Icons.auto_stories_outlined,
                  selected: true,
                  onPressed: onGeneratePictureBook,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreativeTypeCard(
                  title: AppLocalizations.of(context)!.generateExportS740,
                  description: AppLocalizations.of(context)!.generateExportS532,
                  icon: Icons.view_timeline_outlined,
                  selected: false,
                  onPressed: onGenerateMemoryAlbum,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreativeTypeCard(
                  title: AppLocalizations.of(context)!.generateExportS727,
                  description: AppLocalizations.of(context)!.generateExportS738,
                  icon: Icons.movie_creation_outlined,
                  selected: false,
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
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
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
            Icon(icon, size: 22, color: foreground),
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
            child: Icon(
              hasAssets
                  ? Icons.task_alt_rounded
                  : Icons.add_photo_alternate_outlined,
              color: hasAssets
                  ? const Color(0xff168542)
                  : const Color(0xff9a5a14),
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
                    const _TaskFact(label: '目标', value: '儿童绘本'),
                    _TaskFact(
                      label: AppLocalizations.of(context)!.generateExportS708,
                      value: hasAssets ? AppLocalizations.of(context)!.generateExportS813 : AppLocalizations.of(context)!.generateExportS819,
                      emphasis: !hasAssets,
                    ),
                    _TaskFact(label: AppLocalizations.of(context)!.generateExportS460, value: '$selectedCount 项'),
                    const _TaskFact(label: '建议素材', value: '至少 6 张'),
                    _TaskFact(
                      label: AppLocalizations.of(context)!.generateExportS884,
                      value: '${_compactOption(sizeText)} / 长图',
                    ),
                    _TaskFact(label: AppLocalizations.of(context)!.generateExportS956, value: _compactOption(styleText)),
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
                  label: hasAssets ? AppLocalizations.of(context)!.generateExportS795 : AppLocalizations.of(context)!.generateExportS800,
                  color: hasAssets
                      ? const Color(0xff168542)
                      : const Color(0xff9a5a14),
                  background: hasAssets
                      ? const Color(0xffe8f4ea)
                      : const Color(0xfffff4d8),
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: hasAssets ? AppLocalizations.of(context)!.generateExportS627 : AppLocalizations.of(context)!.generateExportS324,
                  icon: Icons.grid_view_rounded,
                  onPressed: onViewSelectedAssets,
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: AppLocalizations.of(context)!.generateExportS102,
                  icon: Icons.auto_awesome_outlined,
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

String _compactOption(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return AppLocalizations.of(context)!.generateExportS957;
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
          icon: Icons.auto_stories,
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
                '素材数量          $selectedCount 项\n生成状态          $generationState\n文案风格          $styleText\n页面尺寸          $sizeText\n导出目标          $exportLabel',
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
    required this.exportLabel,
    super.key,
  });

  final int selectedCount;
  final bool generated;
  final bool generating;
  final bool exported;
  final String exportLabel;

  @override
  Widget build(BuildContext context) {
    final hasAssets = selectedCount > 0;
    final steps = [
      _PlanStepData(
        icon: Icons.photo_library_outlined,
        title: AppLocalizations.of(context)!.generateExportS907,
        body: hasAssets ? '已选择 $selectedCount 张' : AppLocalizations.of(context)!.generateExportS800,
        active: !hasAssets,
        complete: hasAssets,
      ),
      _PlanStepData(
        icon: Icons.route_outlined,
        title: AppLocalizations.of(context)!.generateExportS747,
        body: generated || generating ? AppLocalizations.of(context)!.generateExportS107 : AppLocalizations.of(context)!.generateExportS270,
        active: hasAssets && !generated,
        complete: generated,
      ),
      _PlanStepData(
        icon: Icons.edit_note_outlined,
        title: AppLocalizations.of(context)!.generateExportS742,
        body: generating
            ? AppLocalizations.of(context)!.generateExportS647
            : generated
            ? AppLocalizations.of(context)!.generateExportS547
            : AppLocalizations.of(context)!.generateExportS797,
        active: generating,
        complete: generated,
      ),
      _PlanStepData(
        icon: Icons.grid_view_outlined,
        title: AppLocalizations.of(context)!.generateExportS698,
        body: generated ? AppLocalizations.of(context)!.generateExportS332 : AppLocalizations.of(context)!.generateExportS725,
        active: generated && !exported,
        complete: generated,
      ),
      _PlanStepData(
        icon: Icons.file_download_outlined,
        title: AppLocalizations.of(context)!.generateExportS407,
        body: exported ? '$exportLabel 已导出' : AppLocalizations.of(context)!.generateExportS794,
        active: generated && !exported,
        complete: exported,
      ),
      _PlanStepData(
        icon: Icons.ios_share_outlined,
        title: AppLocalizations.of(context)!.generateExportS245,
        body: exported ? AppLocalizations.of(context)!.generateExportS331 : AppLocalizations.of(context)!.generateExportS409,
        active: exported,
        complete: exported,
      ),
    ];

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.generateExportS105,
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
              Icon(data.icon, size: 20, color: foreground),
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

class _PlanStepData {
  const _PlanStepData({
    required this.icon,
    required this.title,
    required this.body,
    required this.active,
    required this.complete,
  });

  final IconData icon;
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
                  hasAssets ? '素材 · 已选择 $count 张' : AppLocalizations.of(context)!.generateExportS808,
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
                          child: const Icon(
                            Icons.image_outlined,
                            size: 20,
                            color: Color(0xff7a6a5b),
                          ),
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
                label: hasAssets ? AppLocalizations.of(context)!.generateExportS923 : AppLocalizations.of(context)!.generateExportS324,
                icon: Icons.grid_view_rounded,
                onPressed: onViewSelectedAssets,
              ),
              SecondaryButton(
                label: hasAssets ? AppLocalizations.of(context)!.generateExportS841 : AppLocalizations.of(context)!.generateExportS102,
                icon: Icons.auto_awesome_outlined,
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
                  generated ? '页面预览（约 $pageCount 页）' : AppLocalizations.of(context)!.generateExportS943,
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
                    : AppLocalizations.of(context)!.contentPreviewWaitingForGenerationLabel,
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
                title: generated ? AppLocalizations.of(context)!.generateExportS419 : AppLocalizations.of(context)!.generateExportS419,
                icon: Icons.auto_stories_outlined,
                active: generated,
              ),
              const SizedBox(width: 12),
              _PreviewTile(
                title: generated ? AppLocalizations.of(context)!.generateExportS790 : AppLocalizations.of(context)!.generateExportS548,
                icon: Icons.article_outlined,
                active: generated,
              ),
              const SizedBox(width: 12),
              _PreviewTile(
                title: generated ? AppLocalizations.of(context)!.generateExportS413 : AppLocalizations.of(context)!.generateExportS413,
                icon: Icons.picture_as_pdf_outlined,
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
    required this.icon,
    required this.active,
  });

  final String title;
  final IconData icon;
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
            Icon(
              icon,
              size: 28,
              color: active ? const Color(0xff3f8c55) : const Color(0xff9b8c7c),
            ),
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
                '点击“开始生成”后，这里会记录 Agent 分析素材、构建书稿、渲染预览与导出状态。\n当前状态：$statusMessage',
                style: const TextStyle(color: Color(0xff6f6258), height: 1.45),
              ),
            ],
          ),
        ),
        SecondaryButton(
          label: AppLocalizations.of(context)!.generateExportS726,
          icon: Icons.list_alt_rounded,
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
    required this.statusMessage,
    required this.requestId,
    required this.logLines,
    required this.onViewDetails,
    super.key,
  });

  final bool generated;
  final bool generating;
  final bool exported;
  final String statusMessage;
  final String requestId;
  final List<String> logLines;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final entries = logLines.isEmpty
        ? [AppLocalizations.of(context)!.generateExportS796]
        : logLines;
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
                label: exported
                    ? AppLocalizations.of(context)!.generateExportS442
                    : generated
                    ? AppLocalizations.of(context)!.generateExportS794
                    : generating
                    ? AppLocalizations.of(context)!.generateExportS895
                    : AppLocalizations.of(context)!.generateExportS795,
                color: exported || generated
                    ? const Color(0xff168542)
                    : generating
                    ? const Color(0xff9a5a14)
                    : const Color(0xff7a6a5b),
                background: exported || generated
                    ? const Color(0xffe8f4ea)
                    : generating
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
          if (statusMessage.trim().isNotEmpty && logLines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '当前状态：$statusMessage',
                style: const TextStyle(
                  color: Color(0xff7a6a5b),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (requestId.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Request ID: $requestId',
              style: const TextStyle(
                color: Color(0xff8c7663),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SecondaryButton(
            label: logLines.isEmpty ? AppLocalizations.of(context)!.generateExportS726 : AppLocalizations.of(context)!.contentViewDetailsLabel,
            icon: Icons.list_alt_rounded,
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
    required this.onRetry,
    required this.onSkipCover,
    required this.onViewLogs,
    super.key,
  });

  final String statusMessage;
  final String requestId;
  final VoidCallback onRetry;
  final VoidCallback onSkipCover;
  final VoidCallback onViewLogs;

  @override
  Widget build(BuildContext context) {
    final title = statusMessage.contains(AppLocalizations.of(context)!.generateExportS419) ? AppLocalizations.of(context)!.generateExportS421 : AppLocalizations.of(context)!.generateExportS729;
    final reason = _extractReason(statusMessage);
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
            '原因：$reason',
            style: const TextStyle(color: Color(0xff6f6258), height: 1.45),
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
                label: AppLocalizations.of(context)!.generateExportS877,
                iconAsset: pdfIconAsset,
                onPressed: onSkipCover,
              ),
              SecondaryButton(
                label: AppLocalizations.of(context)!.generateExportS624,
                iconAsset: timelineIconAsset,
                onPressed: onViewLogs,
              ),
            ],
          ),
          if (requestId.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Request ID: $requestId',
              style: const TextStyle(
                color: Color(0xff8c7663),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _extractReason(String message) {
    final normalized = message.trim();
    if (normalized.isEmpty) return AppLocalizations.of(context)!.generateExportS226;
    final colonIndex = normalized.indexOf('：');
    if (colonIndex >= 0 && colonIndex + 1 < normalized.length) {
      return normalized.substring(colonIndex + 1).trim();
    }
    return normalized;
  }
}

class CoverFailureActionPanel extends StatelessWidget {
  const CoverFailureActionPanel({
    required this.requestId,
    required this.onRetry,
    required this.onSkipAndContinue,
    required this.onViewLog,
    super.key,
  });

  final String requestId;
  final VoidCallback onRetry;
  final VoidCallback onSkipAndContinue;
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
              label: AppLocalizations.of(context)!.generateExportS877,
              iconAsset: pdfIconAsset,
              onPressed: onSkipAndContinue,
            ),
            SecondaryButton(
              label: AppLocalizations.of(context)!.generateExportS624,
              iconAsset: timelineIconAsset,
              onPressed: onViewLog,
            ),
          ],
        ),
        if (requestId.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Request ID: $requestId',
            style: const TextStyle(
              color: Color(0xff8c7663),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    ),
  );
}

class GenerateSettingsPanel extends StatelessWidget {
  const GenerateSettingsPanel({
    required this.generated,
    required this.generating,
    required this.exported,
    required this.selectedCount,
    required this.templateText,
    required this.sizeText,
    required this.styleText,
    required this.exportText,
    required this.exportTargets,
    required this.onGenerate,
    required this.onExport,
    required this.onExportTargetChanged,
    required this.onViewSelectedAssets,
    required this.onPreviewAllPages,
    super.key,
  });

  final bool generated;
  final bool generating;
  final bool exported;
  final int selectedCount;
  final String templateText;
  final String sizeText;
  final String styleText;
  final String exportText;
  final List<String> exportTargets;
  final VoidCallback? onGenerate;
  final VoidCallback onExport;
  final ValueChanged<String> onExportTargetChanged;
  final VoidCallback? onViewSelectedAssets;
  final VoidCallback onPreviewAllPages;

  @override
  Widget build(BuildContext context) {
    final exportLabel = _exportDisplayName(exportText);
    final hasAssets = selectedCount > 0;
    final subtitle = generated
        ? '生成完成后可预览或导出 $exportLabel。'
        : AppLocalizations.of(context)!.generateExportS871;
    final primaryLabel = generated
        ? (exported ? '$exportLabel 已导出' : _exportButtonLabel(exportText))
        : (generating ? AppLocalizations.of(context)!.generateExportS719 : AppLocalizations.of(context)!.generateExportS470);
    final primaryAction = generating
        ? null
        : (generated ? onExport : onGenerate);
    final primaryIcon = generated ? pdfIconAsset : addIconAsset;

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
              value: AppLocalizations.of(context)!.generateExportS255,
              icon: Icons.auto_stories_outlined,
            ),
            ExportOption(
              title: AppLocalizations.of(context)!.generateExportS644,
              value: _compactOption(templateText),
              icon: Icons.image,
              iconAsset: imageIconAsset,
            ),
            ExportOption(
              title: AppLocalizations.of(context)!.generateExportS942,
              value: _compactOption(sizeText),
              icon: Icons.description_outlined,
              iconAsset: a4FileIconAsset,
            ),
            ExportOption(
              title: AppLocalizations.of(context)!.generateExportS553,
              value: _compactOption(styleText),
              icon: Icons.style,
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
              icon: generated
                  ? Icons.picture_as_pdf_rounded
                  : Icons.add_rounded,
              iconAsset: primaryIcon,
            ),
            const SizedBox(height: 14),
            generated
                ? SecondaryButton(
                    label: generating ? AppLocalizations.of(context)!.generateExportS719 : AppLocalizations.of(context)!.generateExportS921,
                    icon: Icons.refresh_rounded,
                    iconAsset: refreshIconAsset,
                    fullWidth: true,
                    height: 48,
                    onPressed: generating ? null : onGenerate,
                  )
                : SecondaryButton(
                    label: AppLocalizations.of(context)!.generateExportS623,
                    icon: Icons.grid_view_rounded,
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
            generated
                ? SecondaryButton(
                    label: AppLocalizations.of(context)!.generateExportS951,
                    icon: Icons.visibility_outlined,
                    iconAsset: viewIconAsset,
                    fullWidth: true,
                    height: 48,
                    onPressed: onPreviewAllPages,
                  )
                : const _LockedPreviewNotice(),
            const SizedBox(height: 22),
            Text(
              generated
                  ? '导出将写入当前导出目录，完成后可在“打开导出文件夹”中查看 $exportLabel 文件'
                  : AppLocalizations.of(context)!.generateExportS735,
              style: const TextStyle(color: Color(0xffa57a3a), fontSize: 13),
            ),
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
            value: hasAssets ? '$selectedCount / 建议 6+' : AppLocalizations.of(context)!.generateExportS83,
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
          const _ConsoleFact(label: '云端分享', value: '生成后可上传'),
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
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

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
              Icon(icon, size: 22, color: const Color(0xff3f8c55)),
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

class _LockedPreviewNotice extends StatelessWidget {
  const _LockedPreviewNotice();

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    backgroundColor: const Color(0xfff6f0e8),
    child: Row(
      children: [
        AppAssetIcon(lockIconAsset, size: compactInlineIconSize),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.generateExportS949,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff8c7663),
              fontWeight: FontWeight.w800,
            ),
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
        ? const ['PDF 文件  高质量 PDF（打印级别）']
        : options;
    final selected = normalizedOptions.contains(value)
        ? value
        : normalizedOptions.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.generateExportS417), style: TextStyle(fontWeight: FontWeight.w800)),
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
    this.result,
    this.onOpenExportFolder,
    this.onCopyShareText,
    this.onCopyLongImage,
    super.key,
  });

  final bool generated;
  final ExportResultVm? result;
  final VoidCallback? onOpenExportFolder;
  final VoidCallback? onCopyShareText;
  final VoidCallback? onCopyLongImage;

  @override
  Widget build(BuildContext context) {
    final current = result;
    if (!generated && current == null) {
      return SurfaceCard(
        backgroundColor: const Color(0xfff6f0e8),
        borderColor: const Color(0xffeadbc9),
        child: const Row(
          children: [
            Icon(Icons.file_download_outlined, color: Color(0xff7a6a5b)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.generateExportS735,
                style: TextStyle(
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
    final canCopyImage = current?.isLongImage == true && hasLocalFile;
    final status = current == null
        ? (generated ? AppLocalizations.of(context)!.generateExportS794 : AppLocalizations.of(context)!.generateExportS724)
        : _storageStatusLabel(current.storageStatus);
    final remoteStatus = current == null
        ? AppLocalizations.of(context)!.generateExportS723
        : current.remoteUrl.trim().isNotEmpty
        ? AppLocalizations.of(context)!.generateExportS452
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
                value: hasLocalFile ? current!.localPath : AppLocalizations.of(context)!.generateExportS428,
              ),
              _ExportFact(label: AppLocalizations.of(context)!.generateExportS218, value: status),
              _ExportFact(label: AppLocalizations.of(context)!.generateExportS274, value: remoteStatus),
              if (error.isNotEmpty) _ExportFact(label: AppLocalizations.of(context)!.generateExportS930, value: error),
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
                label: AppLocalizations.of(context)!.generateExportS357,
                iconAsset: linkIconAsset,
                onPressed: hasShare ? onCopyShareText : null,
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
              hasLocalFile: hasLocalFile,
              hasShare: hasShare,
              canCopyImage: canCopyImage,
              result: current,
            ),
            style: const TextStyle(color: Color(0xff8c7663), fontSize: 12),
          ),
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

  String _actionReason({
    required bool hasLocalFile,
    required bool hasShare,
    required bool canCopyImage,
    required ExportResultVm? result,
  }) {
    if (!hasLocalFile) return AppLocalizations.of(context)!.generateExportS411;
    if (!hasShare) return AppLocalizations.of(context)!.generateExportS415;
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

String _exportButtonLabel(String exportText) {
  if (_isJpgTarget(exportText)) return AppLocalizations.of(context)!.generateExportS404;
  if (_isPngTarget(exportText)) return AppLocalizations.of(context)!.generateExportS406;
  return AppLocalizations.of(context)!.generateExportS405;
}

String _exportDisplayName(String exportText) {
  if (_isJpgTarget(exportText)) return AppLocalizations.of(context)!.generateExportS931;
  if (_isPngTarget(exportText)) return AppLocalizations.of(context)!.generateExportS934;
  return 'PDF';
}

bool _isPngTarget(String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('png') || exportText.contains(AppLocalizations.of(context)!.generateExportS934);
}

bool _isJpgTarget(String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('jpg') ||
      normalized.contains('jpeg') ||
      exportText.contains(AppLocalizations.of(context)!.generateExportS931);
}

String _storageStatusLabel(String status) {
  final normalized = status.trim();
  if (normalized == 'synced') return AppLocalizations.of(context)!.generateExportS438;
  if (normalized == 'pending' || normalized == 'running') {
    return AppLocalizations.of(context)!.generateExportS336;
  }
  if (normalized == 'retry_wait') return AppLocalizations.of(context)!.generateExportS802;
  if (normalized == 'failed') return AppLocalizations.of(context)!.generateExportS340;
  if (normalized.isEmpty || normalized == 'local_only' || normalized == 'ready') {
    return AppLocalizations.of(context)!.generateExportS219;
  }
  return normalized;
}
