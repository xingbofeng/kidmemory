part of 'content.dart';

class SourceRow extends StatelessWidget {
  const SourceRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconAsset,
    super.key,
  });

  final IconData? icon;
  final String? iconAsset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      children: [
        AppAssetIcon(
          iconAsset,
          fallbackIcon: icon,
          size: compactInlineIconSize,
          opacity: 0.86,
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Color(0xff7d7065))),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xff5d5148)),
          ),
        ),
      ],
    ),
  );
}

class AssetCard extends StatelessWidget {
  const AssetCard({
    required this.asset,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final SampleAssetVm asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewPath = asset.previewUrl.isNotEmpty
        ? asset.previewUrl
        : asset.thumbnailPath.isNotEmpty
        ? asset.thumbnailPath
        : asset.imagePath;
    final l10n = AppLocalizations.of(context)!;
    final typeStyle = _typeBadgeStyle(l10n, asset.type);
    final title = _displayAssetTitle(l10n, asset.title, asset.type);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        borderColor: selected
            ? const Color(0xff7bd19a)
            : const Color(0xffeadbc9),
        backgroundColor: selected ? const Color(0xfffbfffb) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AssetArtworkPreview(
                      path: previewPath,
                      fallbackIcon: asset.icon,
                      fallbackAssetPath: _assetPreviewIconAsset(
                        l10n,
                        asset.type,
                      ),
                      label: '',
                      height: double.infinity,
                      width: double.infinity,
                      fit: previewPath.isEmpty ? BoxFit.contain : BoxFit.cover,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      borderColor: const Color(0xffe9dac8),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xff3f8c55)
                            : Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: selected
                              ? const Color(0xff3f8c55)
                              : const Color(0xffd6c8b6),
                          width: 1.6,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: typeStyle.$1.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: typeStyle.$2),
                      ),
                      child: Text(
                        asset.type,
                        style: TextStyle(
                          color: typeStyle.$3,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xff241b14),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatAssetDate(l10n, asset.date),
                      style: const TextStyle(color: Color(0xff8c7663)),
                    ),
                    const SizedBox(height: 8),
                    if (asset.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: asset.tags
                            .take(3)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xfff6f1ea),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Color(0xff6a5d50),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    else
                      Text(
                        AppLocalizations.of(context)!.contentNoTagReasonHint,
                        style: TextStyle(
                          color: Color(0xffa89785),
                          fontSize: 12,
                        ),
                      ),
                    if (asset.matchReasons.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: asset.matchReasons
                            .take(2)
                            .map(
                              (reason) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffe9f8ed),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xffb9e4c5),
                                  ),
                                ),
                                child: Text(
                                  reason,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xff217946),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAssetDate(AppLocalizations l10n, String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value.isEmpty ? l10n.contentDateMissingLabel : value;
    }
    final local = parsed.toLocal();
    return l10n.assetLibraryDateYmd(local.year, local.month, local.day);
  }

  String _displayAssetTitle(AppLocalizations l10n, String value, String type) {
    final title = value.trim();
    final technicalId = RegExp(r'^(cld|asset)[-_]?\w+', caseSensitive: false);
    if (title.isNotEmpty && !technicalId.hasMatch(title)) return title;
    if (type == 'photo' || type == l10n.contentAssetTypePhotoLabel) {
      return l10n.contentUnnamedPhotoLabel;
    }
    if (type == 'craft' || type == l10n.contentAssetTypeCraftLabel) {
      return l10n.contentUnnamedCraftLabel;
    }
    return l10n.contentUnnamedDrawingLabel;
  }

  (Color, Color, Color) _typeBadgeStyle(AppLocalizations l10n, String type) {
    if (type == 'photo' || type == l10n.contentAssetTypePhotoLabel) {
      return (
        const Color(0xffedf4ff),
        const Color(0xffb9cde8),
        const Color(0xff355b8c),
      );
    }
    if (type == 'craft' || type == l10n.contentAssetTypeCraftLabel) {
      return (
        const Color(0xfffff3ea),
        const Color(0xfff4c7a1),
        const Color(0xffc96e2d),
      );
    }
    return (
      const Color(0xffedf8ee),
      const Color(0xffb8dfc1),
      const Color(0xff2b7d4a),
    );
  }
}

int _estimatedPageCount(int selectedCount) {
  return math.max(1, math.min(12, selectedCount * 3));
}

class StatusStack extends StatelessWidget {
  const StatusStack({
    required this.selectedCount,
    required this.generated,
    required this.exported,
    super.key,
  });

  final int selectedCount;
  final bool generated;
  final bool exported;

  @override
  Widget build(BuildContext context) {
    final pageCount = _estimatedPageCount(selectedCount);
    return SizedBox(
      width: 210,
      child: Column(
        children: [
          StatusPill(
            text: generated
                ? AppLocalizations.of(
                    context,
                  )!.contentGenerationCompletePages(pageCount, pageCount)
                : AppLocalizations.of(
                    context,
                  )!.contentPreviewWaitingForGenerationLabel,
            color: const Color(0xffeaf7ee),
          ),
          const SizedBox(height: 10),
          StatusPill(
            text: generated
                ? AppLocalizations.of(context)!.contentPreviewCompletedLabel
                : AppLocalizations.of(context)!.contentPreviewWaitingLabel,
            color: const Color(0xffeef6ff),
          ),
          const SizedBox(height: 10),
          StatusPill(
            text: exported
                ? AppLocalizations.of(context)!.contentExportCompletedFileLabel
                : AppLocalizations.of(
                    context,
                  )!.contentExportFormatSelectionHint,
            color: const Color(0xfffff4df),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({required this.text, required this.color, super.key});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

class StepProgress extends StatelessWidget {
  const StepProgress({
    required this.selectedCount,
    required this.generated,
    required this.exported,
    super.key,
  });

  final int selectedCount;
  final bool generated;
  final bool exported;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          AppLocalizations.of(context)!.contentFlowPrepareAssets(selectedCount),
        ),
        Text(
          generated
              ? AppLocalizations.of(context)!.contentFlowAgentGenerated
              : AppLocalizations.of(context)!.contentFlowAgentWaiting,
        ),
        Text(
          exported
              ? AppLocalizations.of(context)!.contentFlowExportCompleted
              : AppLocalizations.of(context)!.contentFlowExportWaiting,
        ),
      ],
    ),
  );
}

class SelectedAssetsStrip extends StatelessWidget {
  const SelectedAssetsStrip({required this.count, this.onViewAll, super.key});

  final int count;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        Text(
          AppLocalizations.of(context)!.contentSelectedAssetsTitle(count),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: count == 0
                  ? [
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.contentNoSelectedAssetsHint,
                        style: TextStyle(color: Color(0xff77685e)),
                      ),
                    ]
                  : [
                      for (var index = 0; index < math.min(count, 7); index++)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            width: 58,
                            child: WarmPicture(
                              icon: Icons.image_outlined,
                              assetPath: imageIconAsset,
                              label: '',
                              height: 58,
                            ),
                          ),
                        ),
                      SecondaryButton(
                        label: AppLocalizations.of(
                          context,
                        )!.contentViewAllLabel,
                        onPressed: onViewAll ?? () {},
                      ),
                    ],
            ),
          ),
        ),
      ],
    ),
  );
}

class PagePreviewPanel extends StatelessWidget {
  const PagePreviewPanel({
    required this.selectedCount,
    required this.generated,
    super.key,
  });

  final int selectedCount;
  final bool generated;

  @override
  Widget build(BuildContext context) {
    final pageCount = _estimatedPageCount(selectedCount);
    final title = generated
        ? AppLocalizations.of(context)!.contentPagePreviewCount(pageCount)
        : AppLocalizations.of(context)!.contentPreviewWaitingTitle;
    final generatedPreviews = [
      (
        bookIconAsset,
        Icons.auto_stories_outlined,
        AppLocalizations.of(context)!.contentSectionCoverLabel,
      ),
      (
        paletteIconAsset,
        Icons.palette_outlined,
        AppLocalizations.of(context)!.contentSectionStoriesLabel,
      ),
      (
        bearDocumentIconAsset,
        Icons.description_outlined,
        AppLocalizations.of(context)!.contentSectionGrowthRecordsLabel,
      ),
    ];
    return SurfaceCard(
      child: SizedBox(
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (!generated) ...[
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.contentPreviewAvailableAfterGenerationHint,
                    style: TextStyle(fontSize: 12, color: Color(0xff8c7663)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                children: [
                  if (generated) ...[
                    for (
                      var index = 0;
                      index < generatedPreviews.length;
                      index++
                    ) ...[
                      Expanded(
                        child: WarmPicture(
                          icon: generatedPreviews[index].$2,
                          assetPath: generatedPreviews[index].$1,
                          label: generatedPreviews[index].$3,
                        ),
                      ),
                      if (index != generatedPreviews.length - 1)
                        const SizedBox(width: 16),
                    ],
                  ] else ...[
                    Expanded(
                      child: PreviewPlaceholder(
                        icon: Icons.article_outlined,
                        iconAsset: bearDocumentIconAsset,
                        label: AppLocalizations.of(
                          context,
                        )!.contentCoverAppearsAfterGenerationLabel,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: PreviewPlaceholder(
                        icon: Icons.image_outlined,
                        iconAsset: imageIconAsset,
                        label: AppLocalizations.of(
                          context,
                        )!.contentStoryPagesWaitingLabel,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: PreviewPlaceholder(
                        icon: Icons.subject_rounded,
                        iconAsset: pdfIconAsset,
                        label: AppLocalizations.of(
                          context,
                        )!.contentExportBeforePreviewHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewPlaceholder extends StatelessWidget {
  const PreviewPlaceholder({
    required this.icon,
    required this.label,
    this.iconAsset,
    super.key,
  });

  final IconData? icon;
  final String? iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xfffffdf8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xffd9d0c8),
        style: BorderStyle.solid,
      ),
    ),
    child: CustomPaint(
      painter: const DashedBorderPainter(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAssetIcon(
              iconAsset,
              fallbackIcon: icon,
              size: 54,
              opacity: 0.45,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff8c7663),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffeadbc9)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    const dash = 8.0;
    const gap = 7.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AgentLogPanel extends StatelessWidget {
  const AgentLogPanel({
    required this.statusMessage,
    required this.requestId,
    required this.logLines,
    this.onViewDetails,
    super.key,
  });

  final String statusMessage;
  final String requestId;
  final List<String> logLines;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.contentTaskProgressLogTitle,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text('●  $statusMessage\n${logLines.join('\n')}'),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(AppLocalizations.of(context)!.contentTimelineSourceText),
            const SizedBox(height: 12),
            SecondaryButton(
              label: AppLocalizations.of(context)!.contentViewDetailsLabel,
              onPressed: onViewDetails ?? () {},
            ),
          ],
        ),
      ],
    ),
  );
}

class ExportOption extends StatelessWidget {
  const ExportOption({
    required this.title,
    required this.value,
    this.icon,
    this.iconAsset,
    super.key,
  });

  final String title;
  final String value;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AppAssetIcon(iconAsset, fallbackIcon: icon, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(value)),
              const AppAssetIcon(
                downArrowIconAsset,
                size: compactInlineIconSize,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _assetPreviewIconAsset(AppLocalizations l10n, String type) {
  if (type == 'photo' || type == l10n.contentAssetTypePhotoLabel) {
    return cameraIconAsset;
  }
  if (type == 'craft' || type == l10n.contentAssetTypeCraftLabel) {
    return bearDocumentIconAsset;
  }
  return paletteIconAsset;
}
