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
    return PageFrame(
      title: '生成 / 预览 / 导出',
      subtitle: '确认素材、模板和风格后开始生成，生成完成后可导出 PDF、PNG 长图或 JPG 长图。',
      status: GenerationReadinessBadge(
        generated: generated,
        generating: generating,
        exported: exported,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                  ExportResultPanel(
                    result: exportResult,
                    generated: generated,
                    onOpenExportFolder: onOpenExportFolder,
                    onCopyShareText: onCopyShareText,
                    onCopyLongImage: onCopyLongImage,
                  ),
                  const SizedBox(height: 16),
                  SelectedAssetsStrip(
                    count: selectedCount,
                    onViewAll: generated
                        ? () => onPreviewAllPages()
                        : () => onViewSelectedAssets(),
                  ),
                  const SizedBox(height: 16),
                  PagePreviewPanel(
                    selectedCount: selectedCount,
                    generated: generated,
                  ),
                  const SizedBox(height: 16),
                  generated
                      ? AgentLogPanel(
                          statusMessage: statusMessage,
                          logLines: logLines,
                          onViewDetails: onViewLogDetails,
                        )
                      : GenerationEntryLog(statusMessage: statusMessage),
                ],
              ),
            ),
          ),
          const SizedBox(width: 22),
          SizedBox(
            width: 360,
            child: GenerateSettingsPanel(
              generated: generated,
              generating: generating,
              exported: exported,
              templateText: templateText,
              sizeText: sizeText,
              styleText: styleText,
              exportText: exportText,
              exportTargets: exportTargets,
              onGenerate: onGenerate,
              onExport: onExport,
              onExportTargetChanged: onExportTargetChanged,
              onViewSelectedAssets: onViewSelectedAssets,
              onPreviewAllPages: onPreviewAllPages,
            ),
          ),
        ],
      ),
    );
  }

  String _firstNonEmpty(List<String> options, String fallback) {
    final trimmedFallback = fallback.trim();
    if (trimmedFallback.isNotEmpty) return trimmedFallback;
    return options.isNotEmpty ? options.first : '';
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
    super.key,
  });

  final int selectedCount;
  final String styleText;
  final String sizeText;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            WarmPicture(
              icon: Icons.article_outlined,
              assetPath: bearDocumentIconAsset,
              label: '',
              height: 142,
              width: 150,
            ),
            const Positioned(
              left: 10,
              bottom: 10,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xff2faa61),
                child: AppAssetIcon(
                  completeIconAsset,
                  size: compactInlineIconSize,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '准备生成新作品集',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                '只展示“可开始”的状态，不展示封面成品或已完成页。\n确认右侧设置后，再创建生成任务。',
                style: TextStyle(color: Color(0xff6f6258), height: 1.55),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 34,
                runSpacing: 8,
                children: [
                  _SummaryMetric(label: '已选素材', value: '$selectedCount 项'),
                  _SummaryMetric(
                    label: '预计页数',
                    value: '约 ${_estimatedPageCount(selectedCount)} 页',
                  ),
                  _SummaryMetric(label: '文案风格', value: styleText),
                  _SummaryMetric(label: '目标格式', value: sizeText),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const SizedBox(
          width: 170,
          child: Column(
            children: [
              _StatePill(
                label: '素材已准备',
                color: Color(0xffeaf7ee),
                textColor: Color(0xff168542),
              ),
              SizedBox(height: 10),
              _StatePill(
                label: '等待生成',
                color: Color(0xfffff4df),
                textColor: Color(0xffa96d12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
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

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 166,
    child: Row(
      children: [
        Text(label, style: const TextStyle(color: Color(0xff6f6258))),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}

class _StatePill extends StatelessWidget {
  const _StatePill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: textColor.withValues(alpha: 0.22)),
    ),
    child: Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: textColor),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
          ),
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
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        Expanded(
          child: _FlowStep(
            icon: Icons.check_rounded,
            iconAsset: completeIconAsset,
            title: '准备素材',
            body: '已选择 $selectedCount 张素材',
            active: true,
            complete: true,
          ),
        ),
        const _FlowConnector(active: true),
        Expanded(
          child: _FlowStep(
            icon: generated ? Icons.check_rounded : Icons.circle,
            iconAsset: generated ? completeIconAsset : addIconAsset,
            title: generated ? 'Agent 生成结构' : '创建任务',
            body: generated
                ? '已生成作品集内容'
                : generating
                ? '正在生成作品集'
                : '等待用户确认',
            active: generated || generating,
            complete: generated,
          ),
        ),
        _FlowConnector(active: generated),
        Expanded(
          child: _FlowStep(
            icon: exported ? Icons.check_rounded : Icons.article_outlined,
            iconAsset: exported ? completeIconAsset : pdfIconAsset,
            title: '预览 / 导出',
            body: generated ? '可预览并导出 $exportLabel' : '生成后解锁',
            active: generated,
            complete: exported,
          ),
        ),
      ],
    ),
  );
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.icon,
    required this.iconAsset,
    required this.title,
    required this.body,
    required this.active,
    required this.complete,
  });

  final IconData icon;
  final String iconAsset;
  final String title;
  final String body;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final background = complete
        ? const Color(0xffeaf7ee)
        : active
        ? const Color(0xfffff4df)
        : const Color(0xfff4efe7);
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: background,
          child: AppAssetIcon(iconAsset, fallbackIcon: icon, size: 30),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xff77685e)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowConnector extends StatelessWidget {
  const _FlowConnector({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 64,
    child: AppAssetIcon(
      rightArrowIconAsset,
      size: 34,
      opacity: active ? 0.9 : 0.35,
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
                '任务日志',
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

class GenerateSettingsPanel extends StatelessWidget {
  const GenerateSettingsPanel({
    required this.generated,
    required this.generating,
    required this.exported,
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
  final String templateText;
  final String sizeText;
  final String styleText;
  final String exportText;
  final List<String> exportTargets;
  final VoidCallback onGenerate;
  final VoidCallback onExport;
  final ValueChanged<String> onExportTargetChanged;
  final VoidCallback onViewSelectedAssets;
  final VoidCallback onPreviewAllPages;

  @override
  Widget build(BuildContext context) {
    final title = generated ? '导出设置' : '生成设置';
    final exportLabel = _exportDisplayName(exportText);
    final subtitle = generated ? '生成完成后可预览或导出 $exportLabel。' : '默认进入先配置生成任务。';
    final primaryLabel = generated
        ? (exported ? '$exportLabel 已导出' : _exportButtonLabel(exportText))
        : (generating ? '生成中...' : '开始生成');
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
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Color(0xff6f6258))),
            const SizedBox(height: 24),
            ExportOption(
              title: '模板',
              value: templateText,
              icon: Icons.image,
              iconAsset: imageIconAsset,
            ),
            ExportOption(
              title: '页面尺寸',
              value: sizeText,
              icon: Icons.description_outlined,
              iconAsset: a4FileIconAsset,
            ),
            ExportOption(
              title: '文案风格',
              value: styleText,
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
                    onPressed: onViewSelectedAssets,
                  ),
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
                  : '预览与导出将在生成后解锁',
              style: const TextStyle(color: Color(0xffa57a3a), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
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
    final hasLocalFile = current?.localPath.trim().isNotEmpty == true;
    final hasShare = current?.shareText.trim().isNotEmpty == true;
    final canCopyImage = current?.isLongImage == true && hasLocalFile;
    final status = current == null
        ? (generated ? '等待导出' : '生成后可导出')
        : _storageStatusLabel(current.storageStatus);
    final remoteStatus = current == null
        ? '未生成远端链接'
        : current.remoteUrl.trim().isNotEmpty
        ? '已有远端 URL'
        : hasShare
        ? '可生成签名分享文案'
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
                label: '本地路径',
                value: hasLocalFile ? current!.localPath : '尚未导出',
              ),
              _ExportFact(label: 'Supabase 同步', value: status),
              _ExportFact(label: '远端 URL', value: remoteStatus),
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
    if (!hasShare) return '导出物尚未同步到 Supabase Storage，暂不能复制分享文案。';
    if (!canCopyImage) return '当前导出不是长图，不能复制长图内容。';
    return '分享文案来自 Supabase Storage，私有 bucket 会包含链接有效期。';
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
