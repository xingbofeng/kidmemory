import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/chrome.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/layout.dart';

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
        : (generated ? '已生成' : (generating ? '生成中' : '等待生成'));
    final showCoverFailureActions = _showCoverFailureActions(statusMessage);
    final canGenerate = selectedCount > 0 && !generating;
    return PageFrame(
      title: '创作台',
      subtitle: '选择素材和创作方式，KidMemory 会帮你生成绘本、成长纪念册或回忆视频。',
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
        title: const Text('确认：调用免费生图'),
        content: const Text('将使用免费生图服务生成封面图。\n不会上传孩子照片，只会发送文字描述。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onContinue();
            },
            child: const Text('继续生成'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onSkipCover();
            },
            child: const Text('跳过封面'),
          ),
        ],
      ),
    );
  }

  bool _showCoverFailureActions(String message) {
    final normalized = message.trim();
    if (normalized.isEmpty) return false;
    return normalized.contains('封面') && normalized.contains('失败');
  }
}

bool _shouldShowGenerationError(String statusMessage) {
  final message = statusMessage.trim();
  if (message.isEmpty) return false;
  if (message == '等待生成') return false;
  if (message == '正在生成作品集') return false;
  if (message.contains('生成完成')) return false;
  return message.contains('失败') ||
      message.contains('异常') ||
      message.contains('不可用') ||
      message.contains('超时');
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
              const Expanded(
                child: Text(
                  '你想为孩子创作什么？',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              _StatusChip(
                label: selectedCount == 0 ? '等待选择素材' : '已选 $selectedCount 张素材',
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
          const Text(
            '输入目标或选择快捷类型，Agent 会按素材、故事、预览和导出组织创作流程。',
            style: TextStyle(color: Color(0xff6f6258)),
          ),
          const SizedBox(height: 14),
          TextField(
            enabled: !generating,
            decoration: InputDecoration(
              hintText: '例如：用春游照片做一本 8 页绘本',
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
                  title: '生成儿童绘本',
                  description: '生成 6-12 页故事绘本',
                  icon: Icons.auto_stories_outlined,
                  selected: true,
                  onPressed: onGeneratePictureBook,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreativeTypeCard(
                  title: '生成成长纪念册',
                  description: '按时间线整理成长记录',
                  icon: Icons.view_timeline_outlined,
                  selected: false,
                  onPressed: onGenerateMemoryAlbum,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreativeTypeCard(
                  title: '生成回忆录视频',
                  description: '生成带字幕和音乐的短视频',
                  icon: Icons.movie_creation_outlined,
                  selected: false,
                  onPressed: onGenerateMemoryVideo,
                ),
              ),
            ],
          ),
          if (selectedCount == 0) ...[
            const SizedBox(height: 12),
            const Text(
              '请先选择素材，之后即可开始生成。',
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
        ? 'PDF 已导出'
        : generated
        ? '生成完成'
        : generating
        ? '生成中'
        : '准备开始';
    final subtitle = exported
        ? '可在保存目录中查看'
        : generated
        ? '可预览或导出'
        : generating
        ? '正在创建作品集'
        : '尚未创建生成任务';
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
                const Text(
                  '当前任务',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    const _TaskFact(label: '目标', value: '儿童绘本'),
                    _TaskFact(
                      label: '状态',
                      value: hasAssets ? '素材已准备' : '素材未选择',
                      emphasis: !hasAssets,
                    ),
                    _TaskFact(label: '已选素材', value: '$selectedCount 项'),
                    const _TaskFact(label: '建议素材', value: '至少 6 张'),
                    _TaskFact(
                      label: '输出',
                      value: '${_compactOption(sizeText)} / 长图',
                    ),
                    _TaskFact(label: '风格', value: _compactOption(styleText)),
                  ],
                ),
                if (!hasAssets) ...[
                  const SizedBox(height: 12),
                  const Text(
                    '请选择孩子的照片、画作或手工作品。素材准备好后，Agent 会生成创作计划并开始预览。',
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
                  label: hasAssets ? '等待开始' : '等待选择素材',
                  color: hasAssets
                      ? const Color(0xff168542)
                      : const Color(0xff9a5a14),
                  background: hasAssets
                      ? const Color(0xffe8f4ea)
                      : const Color(0xfffff4d8),
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: hasAssets ? '查看素材' : '去素材库选择',
                  icon: Icons.grid_view_rounded,
                  onPressed: onViewSelectedAssets,
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: 'AI 帮我挑素材',
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
  if (normalized.isEmpty) return '默认';
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
        const WarmPicture(
          icon: Icons.auto_stories,
          assetPath: bookIconAsset,
          label: '本次作品集',
          height: 180,
          width: 190,
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '本次作品集',
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
        title: '选择素材',
        body: hasAssets ? '已选择 $selectedCount 张' : '等待选择素材',
        active: !hasAssets,
        complete: hasAssets,
      ),
      _PlanStepData(
        icon: Icons.route_outlined,
        title: '生成计划',
        body: generated || generating ? 'Agent 正在规划' : '准备大纲',
        active: hasAssets && !generated,
        complete: generated,
      ),
      _PlanStepData(
        icon: Icons.edit_note_outlined,
        title: '生成故事',
        body: generating
            ? '正在写故事'
            : generated
            ? '故事已生成'
            : '等待执行',
        active: generating,
        complete: generated,
      ),
      _PlanStepData(
        icon: Icons.grid_view_outlined,
        title: '渲染预览',
        body: generated ? '可查看预览' : '生成后展示',
        active: generated && !exported,
        complete: generated,
      ),
      _PlanStepData(
        icon: Icons.file_download_outlined,
        title: '导出作品',
        body: exported ? '$exportLabel 已导出' : '等待导出',
        active: generated && !exported,
        complete: exported,
      ),
      _PlanStepData(
        icon: Icons.ios_share_outlined,
        title: '保存 / 分享',
        body: exported ? '可打开或分享' : '导出后解锁',
        active: exported,
        complete: exported,
      ),
    ];

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agent 执行计划',
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
                  hasAssets ? '素材 · 已选择 $count 张' : '素材',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasAssets
                      ? '这些素材会进入本次创作计划。你可以返回素材库重新选择，或让 Agent 重新挑选。'
                      : '还没有选择素材。请选择孩子的照片、画作或手工作品，建议至少 6 张。',
                  style: const TextStyle(
                    color: Color(0xff7a6a5b),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
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
                label: hasAssets ? '重新选择' : '去素材库选择',
                icon: Icons.grid_view_rounded,
                onPressed: onViewSelectedAssets,
              ),
              SecondaryButton(
                label: hasAssets ? '让 Agent 重新挑选' : 'AI 帮我挑素材',
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
                  generated ? '页面预览（约 $pageCount 页）' : '页面预览',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusChip(
                label: generating
                    ? '生成中'
                    : generated
                    ? '可预览'
                    : '等待生成',
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
                ? '正在生成预览页面，完成后会展示封面、故事页和导出效果。'
                : generated
                ? '封面、故事页和成长记录已准备好，可以继续导出。'
                : '预览将在生成后出现。KidMemory 会在这里展示封面、页面和导出效果。',
            style: const TextStyle(color: Color(0xff7a6a5b), height: 1.45),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _PreviewTile(
                title: generated ? '封面' : '封面',
                icon: Icons.auto_stories_outlined,
                active: generated,
              ),
              const SizedBox(width: 12),
              _PreviewTile(
                title: generated ? '第 1 页' : '故事页',
                icon: Icons.article_outlined,
                active: generated,
              ),
              const SizedBox(width: 12),
              _PreviewTile(
                title: generated ? '导出效果' : '导出效果',
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
              const Text(
                'Agent 活动',
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
          label: '生成后查看日志',
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
        ? ['等待开始。点击“开始生成”后，这里会显示素材分析、故事生成、预览渲染和导出进度。']
        : logLines;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Agent 活动',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              _StatusChip(
                label: exported
                    ? '已完成'
                    : generated
                    ? '等待导出'
                    : generating
                    ? '进行中'
                    : '等待开始',
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
            label: logLines.isEmpty ? '生成后查看日志' : '查看详细日志',
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
    final title = statusMessage.contains('封面') ? '封面图生成失败' : '生成失败';
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
                label: '重试',
                iconAsset: refreshIconAsset,
                onPressed: onRetry,
              ),
              SecondaryButton(
                label: '跳过封面继续导出',
                iconAsset: pdfIconAsset,
                onPressed: onSkipCover,
              ),
              SecondaryButton(
                label: '查看日志',
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
    if (normalized.isEmpty) return '任务执行失败';
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
        const Text(
          '封面图生成失败',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xff9b3a2b),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '原因：免费生图服务暂时不可用。你可以重试，或跳过封面继续导出。',
          style: TextStyle(color: Color(0xff6f6258), height: 1.45),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SecondaryButton(
              label: '重试',
              iconAsset: refreshIconAsset,
              onPressed: onRetry,
            ),
            SecondaryButton(
              label: '跳过封面继续导出',
              iconAsset: pdfIconAsset,
              onPressed: onSkipAndContinue,
            ),
            SecondaryButton(
              label: '查看日志',
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
        : '调整模板、尺寸和导出方式。设置完成后即可开始创作。';
    final primaryLabel = generated
        ? (exported ? '$exportLabel 已导出' : _exportButtonLabel(exportText))
        : (generating ? '生成中...' : '开始生成绘本');
    final primaryAction = generating
        ? null
        : (generated ? onExport : onGenerate);
    final primaryIcon = generated ? pdfIconAsset : addIconAsset;

    return SurfaceCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '生成控制台',
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
            const _SettingRow(
              title: '创作类型',
              value: '儿童绘本',
              icon: Icons.auto_stories_outlined,
            ),
            ExportOption(
              title: '模板',
              value: _compactOption(templateText),
              icon: Icons.image,
              iconAsset: imageIconAsset,
            ),
            ExportOption(
              title: '页面尺寸',
              value: _compactOption(sizeText),
              icon: Icons.description_outlined,
              iconAsset: a4FileIconAsset,
            ),
            ExportOption(
              title: '文案风格',
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
                    label: generating ? '生成中...' : '重新生成',
                    icon: Icons.refresh_rounded,
                    iconAsset: refreshIconAsset,
                    fullWidth: true,
                    height: 48,
                    onPressed: generating ? null : onGenerate,
                  )
                : SecondaryButton(
                    label: '查看已选素材',
                    icon: Icons.grid_view_rounded,
                    iconAsset: gridIconAsset,
                    fullWidth: true,
                    height: 48,
                    onPressed: hasAssets ? onViewSelectedAssets : null,
                  ),
            if (!generated && !hasAssets) ...[
              const SizedBox(height: 8),
              const Text(
                '请先选择素材，开始生成才会启用。',
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
                    label: '预览全部页面',
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
                  : '生成完成后，可以导出 PDF、长图或创建分享链接。',
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
            label: '素材状态',
            value: hasAssets ? '$selectedCount / 建议 6+' : '0 / 建议 6+',
          ),
          const SizedBox(height: 8),
          _ConsoleFact(
            label: '任务状态',
            value: exported
                ? '已导出'
                : generated
                ? '已生成'
                : hasAssets
                ? '等待开始'
                : '等待选择素材',
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
      children: const [
        AppAssetIcon(lockIconAsset, size: compactInlineIconSize),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            '预览与导出将在生成后解锁',
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
          const Text('导出目标', style: TextStyle(fontWeight: FontWeight.w800)),
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
                '生成完成后，可以导出 PDF、长图或创建分享链接。',
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
        ? (generated ? '等待导出' : '生成后可导出')
        : _storageStatusLabel(current.storageStatus);
    final remoteStatus = current == null
        ? '生成后可上传分享'
        : current.remoteUrl.trim().isNotEmpty
        ? '已生成分享链接'
        : hasShare
        ? '可复制分享文案'
        : '仅本地文件';
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
              const Expanded(
                child: Text(
                  '导出结果',
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
                label: '本地文件',
                value: hasLocalFile ? current!.localPath : '尚未导出',
              ),
              _ExportFact(label: '云端分享', value: status),
              _ExportFact(label: '分享链接', value: remoteStatus),
              if (error.isNotEmpty) _ExportFact(label: '错误原因', value: error),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(
                label: '打开导出文件夹',
                iconAsset: folderIconAsset,
                onPressed: hasLocalFile ? onOpenExportFolder : null,
              ),
              SecondaryButton(
                label: '复制分享文案',
                iconAsset: linkIconAsset,
                onPressed: hasShare ? onCopyShareText : null,
              ),
              SecondaryButton(
                label: '复制长图',
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
    if (!hasLocalFile) return '导出完成后才能打开文件夹或复制长图。';
    if (!hasShare) return '导出物尚未上传分享，暂不能复制分享文案。';
    if (!canCopyImage) return '当前导出不是长图，不能复制长图内容。';
    return '分享链接已生成，可直接发送给家人查看。';
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
  if (_isJpgTarget(exportText)) return '导出 JPG 长图';
  if (_isPngTarget(exportText)) return '导出 PNG 长图';
  return '导出 PDF';
}

String _exportDisplayName(String exportText) {
  if (_isJpgTarget(exportText)) return '长图 JPG';
  if (_isPngTarget(exportText)) return '长图 PNG';
  return 'PDF';
}

bool _isPngTarget(String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('png') || exportText.contains('长图 PNG');
}

bool _isJpgTarget(String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('jpg') ||
      normalized.contains('jpeg') ||
      exportText.contains('长图 JPG');
}

String _storageStatusLabel(String status) {
  return switch (status.trim()) {
    'synced' => '已同步',
    'pending' || 'running' => '同步中',
    'retry_wait' => '等待重试',
    'failed' => '同步失败',
    'local_only' || '' || 'ready' => '仅本地',
    final value => value,
  };
}
