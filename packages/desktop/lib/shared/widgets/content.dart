import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/sample_assets.dart';
import 'chrome.dart';
import 'layout.dart';
import 'status.dart';

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
    final needsAttention = healthy == false || _setupNeedsAttention(state);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: setupBadgeSize),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  state,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Text(
              body,
              maxLines: progress == null ? 7 : 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
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
              progressLabel ?? '正在准备...',
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (secondaryActionLabel != null && onSecondaryAction != null)
                SecondaryButton(
                  label: secondaryActionLabel!,
                  onPressed: onSecondaryAction,
                  icon: Icons.folder_open_rounded,
                ),
              SecondaryButton(
                label: _primaryActionLabel(),
                onPressed: actionEnabled ? onAction : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _primaryActionLabel() {
    if (actionEnabled) return action;
    if (progress != null) return progressLabel ?? '正在处理中...';
    return action;
  }

  bool _setupNeedsAttention(String value) {
    return value.contains('需配置') ||
        value.contains('未配置') ||
        value.contains('未连接') ||
        value.contains('准备中');
  }
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
        trailing ?? const ProjectIconMark(size: 112),
      ],
    ),
  );
}

class MetricStrip extends StatelessWidget {
  const MetricStrip({required this.metrics, super.key});

  final List<(String, String)> metrics;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: metrics
          .map(
            (metric) => Expanded(
              child: Column(
                children: [
                  Text(
                    metric.$1,
                    style: const TextStyle(color: Color(0xff8c7663)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.$2,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
}

class AssetPreviewItem {
  const AssetPreviewItem({
    required this.label,
    required this.icon,
    this.iconAsset,
    this.path = '',
  });

  final String label;
  final IconData icon;
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
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 4,
    crossAxisSpacing: 14,
    mainAxisSpacing: 14,
    physics: const NeverScrollableScrollPhysics(),
    children: items
        .take(compact ? 8 : items.length)
        .map(
          (asset) => AssetArtworkPreview(
            fallbackIcon: asset.icon,
            fallbackAssetPath: asset.iconAsset,
            label: asset.label,
            path: asset.path,
            height: 150,
          ),
        )
        .toList(),
  );
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
        const SizedBox(height: 10),
        Text(text, style: const TextStyle(height: 1.5)),
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
          title: '儿童画',
          value: '$artworkCount 张',
          text: '包含当前示例孩子的儿童画素材',
        ),
        DatasetLine(
          iconAsset: bearDocumentIconAsset,
          title: '手工作品',
          value: '$craftCount 件',
          text: '包含纸板、手工和结构化素材',
        ),
        DatasetLine(
          iconAsset: cameraIconAsset,
          title: '照片',
          value: '$photoCount 张',
          text: '含拍照素材与扫描件',
        ),
        DatasetLine(
          iconAsset: tagIconAsset,
          title: '标签',
          value: '$tagCount 个',
          text: '包含主题、颜色、场景和创作类型标签',
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
    required this.icon,
    required this.label,
    this.height = 150,
    this.width,
    this.assetPath,
    this.borderRadius = const BorderRadius.all(Radius.circular(13)),
    this.borderColor = const Color(0xffead3b8),
    super.key,
  });

  final IconData icon;
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
            : Icon(icon, size: iconSize, color: const Color(0xffe89933));
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

  @override
  Widget build(BuildContext context) {
    final source = path?.trim() ?? '';
    if (source.isEmpty) {
      return WarmPicture(
        icon: fallbackIcon,
        assetPath: fallbackAssetPath,
        label: label,
        height: height,
        width: width,
        borderRadius: borderRadius,
        borderColor: borderColor,
      );
    }

    return Container(
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
    return Image.file(
      File(source),
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
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
        const MetricStrip(
          metrics: [
            ('素材总数', '1,248 个'),
            ('绘画数量', '612'),
            ('照片数量', '213'),
            ('已生成 PDF', '13'),
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
      children: const [
        Text(
          '素材分布',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 24),
        Center(child: AppAssetIcon(imageIconAsset, size: 92)),
        Text('绘画作品 49%    照片 35%    手工作品 9%'),
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
        const Text(
          '最近作品',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: titles.isEmpty
              ? const Center(child: Text('暂无最近作品'))
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
      children: const [
        Text(
          '作品集记录',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 10),
        Text('春日拾光  ·  2025-04-01  ·  24页'),
        SizedBox(height: 8),
        Text('三岁生日纪念册  ·  2024-06-20  ·  32页'),
        SizedBox(height: 8),
        Text('幼儿园生活点滴  ·  2024-01-15  ·  28页'),
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
      children: const [
        Text('😊\n出生'),
        Text('🖍️\n第一次微笑'),
        Text('🎨\n第一次画画'),
        Text('🏫\n幼儿园入学'),
        Text('🚲\n学会骑车'),
        Text('🏮\n新年画作'),
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
            '档案信息\n\n性别                 男孩\n出生地               上海市\n星座                 双子座\n血型                 A型\n创建时间             2024-06-18\n最后更新             2025-05-30\n\n成长里程碑\n第一次画画     2022-03-15\n幼儿园入学     2023-09-01\n第一次画展     2024-05-20\n学会骑自行车   2024-10-12',
            style: TextStyle(height: 2.0),
          ),
        ),
      ),
      SizedBox(height: 18),
      SuccessBanner(title: '每一幅画，都是成长的印记', text: '每一个笑容，都值得被珍藏。'),
    ],
  );
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    this.controller,
    this.onChanged,
    this.hintText = '搜索素材名称、标签或来源...',
    super.key,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: const Padding(
        padding: EdgeInsets.all(12),
        child: AppAssetIcon(searchIconAsset, size: inlineIconSize),
      ),
      hintText: hintText,
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
    this.typeOptions = const [
      {'value': 'all', 'label': '全部'},
      {'value': 'artwork', 'label': '绘画'},
      {'value': 'photo', 'label': '照片'},
      {'value': 'craft', 'label': '手工'},
    ],
    this.selectedType = 'all',
    this.onChanged,
    super.key,
  });

  final List<Map<String, String>> typeOptions;
  final String selectedType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final items = typeOptions.where(
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
    this.onPrevious,
    this.onNext,
    super.key,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final visiblePageCount = math.min(totalPages, 3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: '上一页',
          child: IconButton(
            onPressed: currentPage > 0 ? onPrevious : null,
            icon: const AppAssetIcon(leftArrowIconAsset, size: inlineIconSize),
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
          message: '下一页',
          child: IconButton(
            onPressed: currentPage < totalPages - 1 ? onNext : null,
            icon: const AppAssetIcon(rightArrowIconAsset, size: inlineIconSize),
            color: const Color(0xff5d5148),
          ),
        ),
        const SizedBox(width: 12),
        const Text('每页 6 条', style: TextStyle(color: Color(0xff5d5148))),
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
