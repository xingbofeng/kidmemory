import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/sample_assets.dart';
import 'chrome.dart';
import 'layout.dart';
import 'status.dart';
import '../../../l10n/app_localizations.dart';

part 'content_asset_generation.dart';

class SetupCard extends StatelessWidget {
  const SetupCard({
    required this.index,
    required this.title,
    required this.body,
    required this.action,
    required this.state,
    required this.onAction,
    this.actionEnabled = true,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.healthy,
    this.progress,
    this.progressLabel,
    super.key,
  });

  final String index;
  final String title;
  final String body;
  final String action;
  final String state;
  final VoidCallback onAction;
  final bool actionEnabled;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool? healthy;
  final double? progress;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final needsAttention =
        healthy == false || _setupNeedsAttention(l10n, state);
    final backgroundColor = switch ((healthy, needsAttention)) {
      (true, _) => const Color(0xffedf7ee),
      (_, true) => const Color(0xfffff1dd),
      _ => const Color(0xfff4efe7),
    };
    final borderColor = switch ((healthy, needsAttention)) {
      (true, _) => const Color(0xffbfe4c6),
      (_, true) => const Color(0xfff0cf8a),
      _ => const Color(0xffeadbc9),
    };
    final foregroundColor = switch ((healthy, needsAttention)) {
      (true, _) => const Color(0xff20954d),
      (_, true) => const Color(0xff9a5a14),
      _ => const Color(0xff77685e),
    };
    return SurfaceCard(
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SetupIconBadge(
                icon: _setupIcon(l10n),
                color: foregroundColor,
                backgroundColor: healthy == true
                    ? const Color(0xffeef8f0)
                    : const Color(0xfffff4e5),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xffe8e0d5)),
          const SizedBox(height: 18),
          Text(
            body,
            maxLines: progress == null ? 4 : 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.45),
          ),
          const Spacer(),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0).toDouble(),
                minHeight: 8,
                backgroundColor: const Color(0xfffff0df),
                color: const Color(0xff28a65a),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progressLabel ?? l10n.contentPreparingStatusLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff77685e),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              if (secondaryActionLabel != null && onSecondaryAction != null)
                Expanded(
                  child: SecondaryButton(
                    label: secondaryActionLabel!,
                    onPressed: onSecondaryAction,
                    icon: _actionIcon(l10n, secondaryActionLabel!),
                    fullWidth: true,
                    height: 52,
                  ),
                ),
              if (secondaryActionLabel != null && onSecondaryAction != null)
                const SizedBox(width: 10),
              Expanded(
                child: SecondaryButton(
                  label: _primaryActionLabel(l10n),
                  onPressed: actionEnabled ? onAction : null,
                  icon: _actionIcon(l10n, _primaryActionLabel(l10n)),
                  fullWidth: true,
                  height: 52,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _primaryActionLabel(AppLocalizations l10n) {
    if (actionEnabled) return action;
    if (progress != null) {
      return progressLabel ?? l10n.contentProcessingStatusLabel;
    }
    return action;
  }

  bool _setupNeedsAttention(AppLocalizations l10n, String value) {
    return value.contains(l10n.contentNeedsConfigurationLabel) ||
        value.contains(l10n.contentNotConfiguredLabel) ||
        value.contains(l10n.contentDisconnectedLabel) ||
        value.contains(l10n.contentWaitingLabel);
  }

  IconData _actionIcon(AppLocalizations l10n, String label) {
    if (label.contains(l10n.contentTestLabel) ||
        label.contains(l10n.contentCheckLabel)) {
      return Icons.link_rounded;
    }
    if (label.contains(l10n.contentConfigureLabel) ||
        label.contains(l10n.contentModifyLabel)) {
      return Icons.settings_outlined;
    }
    if (label.contains(l10n.contentDirectoryLabel) ||
        label.contains(l10n.contentOpenLabel)) {
      return Icons.folder_open_rounded;
    }
    if (label.contains(l10n.contentConnectLabel)) {
      return Icons.link_rounded;
    }
    return Icons.play_arrow_rounded;
  }

  IconData _setupIcon(AppLocalizations l10n) {
    if (title.contains('PostgreSQL') || title.contains('pgvector')) {
      return Icons.storage_rounded;
    }
    if (title.contains(l10n.contentModelLabel) || title.contains('OpenAI')) {
      return Icons.psychology_alt_rounded;
    }
    return healthy == true ? Icons.check_rounded : Icons.settings_outlined;
  }
}

class _SetupIconBadge extends StatelessWidget {
  const _SetupIconBadge({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => Container(
    width: 58,
    height: 58,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xffd4e6d8)),
    ),
    child: Icon(icon, size: 31, color: color),
  );
}

class InfoHero extends StatelessWidget {
  const InfoHero({
    required this.title,
    required this.text,
    this.icon,
    this.iconAsset,
    this.trailing,
    super.key,
  });

  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffe8f7ec),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xffbde5c7)),
          ),
          child: AppAssetIcon(
            iconAsset,
            fallbackIcon: icon ?? Icons.shield_outlined,
            size: 56,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(text),
            ],
          ),
        ),
        if (trailing != null) ...[trailing!],
      ],
    ),
  );
}

class MetricStrip extends StatelessWidget {
  const MetricStrip({required this.metrics, super.key});

  final List<(String, String)> metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SurfaceCard(
      child: Row(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppAssetIcon(
                        _metricIconAsset(l10n, metrics[index].$1),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          metrics[index].$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff8c7663),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metrics[index].$2,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (index != metrics.length - 1)
              Container(
                width: 1,
                height: 46,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xffeee6dc).withValues(alpha: 0.58),
              ),
          ],
        ],
      ),
    );
  }

  String _metricIconAsset(AppLocalizations l10n, String label) {
    if (label == l10n.contentMetricTotalLabel) return gridIconAsset;
    if (label == l10n.contentCategoryArtworkLabel) return paletteIconAsset;
    if (label == l10n.contentCategoryCraftLabel) return bearDocumentIconAsset;
    if (label == l10n.contentLicenseLabel) return shieldIconAsset;
    if (label == l10n.contentAssetTypePhotoLabel) return cameraIconAsset;
    return infoIconAsset;
  }
}

class AssetPreviewItem {
  const AssetPreviewItem({
    required this.label,
    required this.icon,
    required this.typeLabel,
    this.iconAsset,
    this.path = '',
  });

  final String label;
  final IconData icon;
  final String typeLabel;
  final String? iconAsset;
  final String path;
}

class AssetPreviewGrid extends StatelessWidget {
  const AssetPreviewGrid({
    required this.items,
    this.compact = false,
    super.key,
  });

  final bool compact;
  final List<AssetPreviewItem> items;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(compact ? 8 : items.length).toList();
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: compact ? 1.0 : 0.78,
        mainAxisExtent: compact ? 220 : null,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: visibleItems.length,
      itemBuilder: (context, index) =>
          _AssetPreviewTile(asset: visibleItems[index], compact: compact),
    );
  }
}

class _AssetPreviewTile extends StatelessWidget {
  const _AssetPreviewTile({required this.asset, this.compact = false});

  final AssetPreviewItem asset;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = compact
            ? (constraints.maxHeight - 48).clamp(76.0, 148.0)
            : (constraints.maxHeight - 70).clamp(96.0, 180.0);
        return SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AssetArtworkPreview(
                fallbackIcon: asset.icon,
                fallbackAssetPath: asset.iconAsset,
                label: asset.label,
                path: asset.path,
                height: imageHeight,
                width: double.infinity,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 14,
                  compact ? 6 : 8,
                  compact ? 12 : 14,
                  compact ? 6 : 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff241b14),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: compact ? 2 : 4),
                    Row(
                      children: [
                        AppAssetIcon(asset.iconAsset, size: compact ? 12 : 13),
                        SizedBox(width: compact ? 4 : 5),
                        Expanded(
                          child: Text(
                            asset.typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff8c7663),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SmallInfoCard extends StatelessWidget {
  const SmallInfoCard({
    required this.title,
    required this.text,
    this.iconAsset,
    super.key,
  });

  final String title;
  final String text;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (iconAsset != null) ...[
              AppAssetIcon(iconAsset, size: inlineIconSize),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(height: 1.38, fontSize: 13),
        ),
      ],
    ),
  );
}

class SidePanel extends StatelessWidget {
  const SidePanel({
    required this.title,
    required this.artworkCount,
    required this.craftCount,
    required this.photoCount,
    required this.tagCount,
    super.key,
  });

  final String title;
  final int artworkCount;
  final int craftCount;
  final int photoCount;
  final int tagCount;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        DatasetLine(
          iconAsset: paletteIconAsset,
          title: AppLocalizations.of(context)!.contentCategoryArtworkLabel,
          value: AppLocalizations.of(
            context,
          )!.contentMetricImageCount(artworkCount),
          text: AppLocalizations.of(context)!.contentArtworkDescriptionText,
        ),
        DatasetLine(
          iconAsset: bearDocumentIconAsset,
          title: AppLocalizations.of(context)!.contentCategoryCraftLabel,
          value: AppLocalizations.of(
            context,
          )!.contentMetricCraftCount(craftCount),
          text: AppLocalizations.of(context)!.contentCraftDescriptionText,
        ),
        DatasetLine(
          iconAsset: cameraIconAsset,
          title: AppLocalizations.of(context)!.contentAssetTypePhotoLabel,
          value: AppLocalizations.of(
            context,
          )!.contentMetricImageCount(photoCount),
          text: AppLocalizations.of(context)!.contentPhotoDescriptionText,
        ),
        DatasetLine(
          iconAsset: tagIconAsset,
          title: AppLocalizations.of(context)!.contentTagLabel,
          value: AppLocalizations.of(context)!.contentMetricTagCount(tagCount),
          text: AppLocalizations.of(context)!.contentTagInfoText,
        ),
      ],
    ),
  );
}

class DatasetLine extends StatelessWidget {
  const DatasetLine({
    required this.iconAsset,
    required this.title,
    required this.value,
    required this.text,
    super.key,
  });

  final String iconAsset;
  final String title;
  final String value;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xfffff6e6),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xfff0d4aa)),
          ),
          child: AppAssetIcon(iconAsset, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xff2f8f5b),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Text(
                text,
                style: const TextStyle(color: Color(0xff77685e), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class WarmPicture extends StatelessWidget {
  const WarmPicture({
    required this.label,
    this.icon,
    this.height = 150,
    this.width,
    this.assetPath,
    this.borderRadius = const BorderRadius.all(Radius.circular(13)),
    this.borderColor = const Color(0xffead3b8),
    super.key,
  });

  final IconData? icon;
  final String label;
  final double height;
  final double? width;
  final String? assetPath;
  final BorderRadius borderRadius;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: const Color(0xfffff0d2),
      borderRadius: borderRadius,
      border: Border.all(color: borderColor),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final shortest = math.min(constraints.maxWidth, constraints.maxHeight);
        final showLabel = label.isNotEmpty && shortest >= 70;
        final rawIcon = shortest * (showLabel ? 0.34 : 0.52);
        final iconSize = rawIcon.clamp(18.0, 72.0).toDouble();
        final child = (assetPath?.trim().isNotEmpty ?? false)
            ? AppAssetIcon(assetPath, fallbackIcon: icon, size: iconSize * 1.45)
            : AppAssetIcon(null, fallbackIcon: icon, size: iconSize);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,
            if (showLabel) ...[
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ],
        );
      },
    ),
  );
}

class AssetArtworkPreview extends StatelessWidget {
  const AssetArtworkPreview({
    required this.fallbackIcon,
    required this.label,
    this.fallbackAssetPath,
    this.path,
    this.height = 150,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(13)),
    this.borderColor = const Color(0xffead3b8),
    this.onTap,
    super.key,
  });

  final IconData fallbackIcon;
  final String label;
  final String? fallbackAssetPath;
  final String? path;
  final double height;
  final double? width;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final source = path?.trim() ?? '';
    final preview = source.isEmpty
        ? WarmPicture(
            icon: fallbackIcon,
            assetPath: fallbackAssetPath,
            label: label,
            height: height,
            width: width,
            borderRadius: borderRadius,
            borderColor: borderColor,
          )
        : Container(
            height: height,
            width: width,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xfffff0d2),
              borderRadius: borderRadius,
              border: Border.all(color: borderColor),
            ),
            child: _buildImage(source),
          );

    if (onTap == null) return preview;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: preview,
        ),
      ),
    );
  }

  Widget _buildImage(String source) {
    final lower = source.toLowerCase();
    final fallback = WarmPicture(
      icon: fallbackIcon,
      assetPath: fallbackAssetPath,
      label: label,
      height: height,
      width: width,
      borderRadius: borderRadius,
      borderColor: borderColor,
    );
    if (lower.endsWith('.svg')) {
      return SvgPicture.file(
        File(source),
        fit: fit,
        placeholderBuilder: (_) => fallback,
      );
    }
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return Image.network(
        source,
        fit: fit,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (lower.startsWith('asset://')) {
      return Image.asset(
        source.substring('asset://'.length),
        fit: fit,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return Image.file(
      File(source),
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

Future<void> showAssetArtworkPreviewDialog({
  required BuildContext context,
  required String label,
  required IconData fallbackIcon,
  String? fallbackAssetPath,
  String? path,
}) {
  final title = label.trim().isEmpty
      ? AppLocalizations.of(context)!.contentAssetPreviewFallbackTitle
      : label.trim();
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: const Color(0xfffcfbf9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff2e1d14),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: AppLocalizations.of(context)!.actionCloseLabel,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 560,
                height: 420,
                child: AssetArtworkPreview(
                  path: path,
                  fallbackIcon: fallbackIcon,
                  fallbackAssetPath: fallbackAssetPath,
                  label: label,
                  height: 420,
                  width: 560,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(20),
                  borderColor: const Color(0xffead3b8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.contentPreviewCloseHint,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class MetricPanel extends StatelessWidget {
  const MetricPanel({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        MetricStrip(
          metrics: [
            (
              AppLocalizations.of(context)!.contentMetricTotalLabel,
              AppLocalizations.of(context)!.contentCollectionTotalCountLabel,
            ),
            (AppLocalizations.of(context)!.contentDrawingCountLabel, '612'),
            (AppLocalizations.of(context)!.contentPhotoCountLabel, '213'),
            (AppLocalizations.of(context)!.contentGeneratedPdfLabel, '13'),
          ],
        ),
      ],
    ),
  );
}

class DistributionPanel extends StatelessWidget {
  const DistributionPanel({super.key});

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.contentAssetDistributionTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 24),
        Center(child: AppAssetIcon(imageIconAsset, size: 92)),
        Text(AppLocalizations.of(context)!.contentAssetDistributionSummaryText),
      ],
    ),
  );
}

class RecentWorksPanel extends StatelessWidget {
  const RecentWorksPanel({this.titles = const [], super.key});

  final List<String> titles;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.contentRecentWorksTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: titles.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.contentNoRecentWorksMessage,
                  ),
                )
              : Row(
                  children: titles
                      .take(3)
                      .map(
                        (title) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: WarmPicture(
                              icon: Icons.auto_awesome,
                              assetPath: sparklesIconAsset,
                              label: title,
                              height: 120,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    ),
  );
}

class BookRecordsPanel extends StatelessWidget {
  const BookRecordsPanel({super.key});

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.contentPortfolioRecordTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 10),
        Text(AppLocalizations.of(context)!.contentSampleBookTitleSpring),
        SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.contentSampleBookTitleBirthday),
        SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.contentSampleBookTitleDaycare),
      ],
    ),
  );
}

class TimelinePanel extends StatelessWidget {
  const TimelinePanel({super.key});

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(AppLocalizations.of(context)!.contentTimelineBirth),
        Text(AppLocalizations.of(context)!.contentTimelineFirstSmile),
        Text(AppLocalizations.of(context)!.contentTimelineFirstDrawing),
        Text(AppLocalizations.of(context)!.contentTimelineDaycare),
        Text(AppLocalizations.of(context)!.contentTimelineBicycle),
        Text(AppLocalizations.of(context)!.contentTimelineNewYearArtwork),
      ],
    ),
  );
}

class ProfileAside extends StatelessWidget {
  const ProfileAside({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: SurfaceCard(
          child: Text(
            AppLocalizations.of(context)!.contentProfileSampleDetails,
            style: TextStyle(height: 2.0),
          ),
        ),
      ),
      SizedBox(height: 18),
      SuccessBanner(
        title: AppLocalizations.of(context)!.contentBannerHeaderTitle,
        text: AppLocalizations.of(context)!.contentBannerHeaderSubtitle,
      ),
    ],
  );
}

class SearchBox extends StatelessWidget {
  const SearchBox({this.controller, this.onChanged, this.hintText, super.key});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: const Padding(
        padding: EdgeInsets.all(12),
        child: AppAssetIcon(searchIconAsset, size: inlineIconSize),
      ),
      hintText:
          hintText ?? AppLocalizations.of(context)!.contentAssetSearchHint,
      filled: true,
      fillColor: const Color(0xfffffbf5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffeadbc9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff2faa61)),
      ),
    ),
  );
}

class FilterChips extends StatelessWidget {
  const FilterChips({
    this.typeOptions,
    this.selectedType = 'all',
    this.onChanged,
    super.key,
  });

  final List<Map<String, String>>? typeOptions;
  final String selectedType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final resolvedTypeOptions =
        typeOptions ??
        [
          {
            'value': 'all',
            'label': AppLocalizations.of(context)!.contentTypeFilterAllLabel,
          },
          {
            'value': 'artwork',
            'label': AppLocalizations.of(context)!.contentCategoryDrawingLabel,
          },
          {
            'value': 'photo',
            'label': AppLocalizations.of(context)!.contentAssetTypePhotoLabel,
          },
          {
            'value': 'craft',
            'label': AppLocalizations.of(context)!.contentAssetTypeCraftLabel,
          },
        ];
    final items = resolvedTypeOptions.where(
      (option) =>
          (option['value'] ?? '').trim().isNotEmpty &&
          (option['label'] ?? '').trim().isNotEmpty,
    );
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: items
          .map(
            (item) => ChoiceChip(
              label: Text(item['label'] ?? ''),
              selected: selectedType == item['value'],
              onSelected: (_) => onChanged?.call(item['value'] ?? ''),
              selectedColor: const Color(0xff2faa61),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: selectedType == item['value']
                    ? Colors.white
                    : const Color(0xff5d5148),
              ),
              backgroundColor: const Color(0xfffffbf5),
              side: const BorderSide(color: Color(0xffeadbc9)),
            ),
          )
          .toList(),
    );
  }
}

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    this.currentPage = 0,
    this.totalPages = 1,
    this.pageSize = 6,
    this.onPrevious,
    this.onNext,
    super.key,
  });

  final int currentPage;
  final int totalPages;
  final int pageSize;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final visiblePageCount = math.min(totalPages, 3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: AppLocalizations.of(context)!.contentPagerPreviousTooltip,
          child: IconButton(
            onPressed: currentPage > 0 ? onPrevious : null,
            icon: const Icon(Icons.chevron_left_rounded),
            color: const Color(0xff5d5148),
          ),
        ),
        const SizedBox(width: 8),
        for (var i = 0; i < visiblePageCount; i++) ...[
          PageDot(label: '${i + 1}', active: i == currentPage),
          const SizedBox(width: 8),
        ],
        if (totalPages > 3) ...[
          const Text('...'),
          const SizedBox(width: 8),
          PageDot(label: '$totalPages'),
          const SizedBox(width: 8),
        ],
        Tooltip(
          message: AppLocalizations.of(context)!.contentPagerNextTooltip,
          child: IconButton(
            onPressed: currentPage < totalPages - 1 ? onNext : null,
            icon: const Icon(Icons.chevron_right_rounded),
            color: const Color(0xff5d5148),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          AppLocalizations.of(
            context,
          )!.contentPaginationStatus(currentPage + 1, totalPages, pageSize),
          style: const TextStyle(color: Color(0xff5d5148)),
        ),
      ],
    );
  }
}

class PageDot extends StatelessWidget {
  const PageDot({required this.label, this.active = false, super.key});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? const Color(0xffe6f5e8) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: active ? const Color(0xffb6dec0) : Colors.transparent,
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
        color: const Color(0xff3a3028),
      ),
    ),
  );
}
