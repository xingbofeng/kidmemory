import 'package:flutter/material.dart';

import '../../shared/models/library_models.dart';
import '../../shared/widgets/chrome.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/layout.dart';

class ChildProfilePage extends StatelessWidget {
  const ChildProfilePage({
    required this.children,
    required this.assets,
    required this.selectedChildId,
    required this.onAddProfile,
    required this.onEditProfile,
    super.key,
  });

  final List<ChildVm> children;
  final List<AssetVm> assets;
  final String? selectedChildId;
  final VoidCallback onAddProfile;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    ChildVm? child;
    for (final item in children) {
      if (item.id == selectedChildId) child = item;
    }
    child ??= children.isNotEmpty ? children.first : null;

    return PageFrame(
      title: '孩子档案',
      subtitle: '珍藏成长点滴，记录美好时光',
      decoration: const _ProfileHeaderScene(),
      child: child == null
          ? _EmptyChildProfile(onAddProfile: onAddProfile)
          : _ChildProfileContent(
              child: child,
              assets: assets,
              onEditProfile: onEditProfile,
            ),
    );
  }
}

class _EmptyChildProfile extends StatelessWidget {
  const _EmptyChildProfile({required this.onAddProfile});

  final VoidCallback onAddProfile;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: SurfaceCard(
          child: Row(
            children: [
              const WarmPicture(
                icon: Icons.child_care_rounded,
                assetPath: childIconAsset,
                label: '孩子档案',
                width: 190,
                height: 190,
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '还没有孩子档案',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff2e1d14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '先添加孩子，再开始记录素材、成长时间轴和作品集。',
                      style: TextStyle(color: Color(0xff6f6258), height: 1.6),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: 230,
                      child: PrimaryButton(
                        label: '添加孩子档案',
                        icon: Icons.add_rounded,
                        iconAsset: addIconAsset,
                        onPressed: onAddProfile,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 20),
      const SizedBox(
        width: 340,
        child: _ProfileArtworkRail(title: '从一份档案开始', text: '本地保存孩子信息和成长素材。'),
      ),
    ],
  );
}

class _ChildProfileContent extends StatelessWidget {
  const _ChildProfileContent({
    required this.child,
    required this.assets,
    required this.onEditProfile,
  });

  final ChildVm child;
  final List<AssetVm> assets;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final childName = child.name;
    final artworkCount = assets
        .where((asset) => asset.type == 'artwork')
        .length;
    final photoCount = assets.where((asset) => asset.type == 'photo').length;
    final craftCount = assets.where((asset) => asset.type == 'craft').length;
    final profileImage = _profileImageAsset(assets);

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SurfaceCard(
                  child: Row(
                    children: [
                      _ChildPortrait(
                        childName: childName,
                        imagePath: profileImage?.previewPath ?? '',
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              childName,
                              style: const TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '孩子 ID：${child.id}     已关联素材：${assets.length} 项',
                            ),
                            const SizedBox(height: 18),
                            Text(
                              assets.isEmpty
                                  ? '导入素材后，这里会按真实素材更新成长统计和最近作品。'
                                  : '当前素材库已连接到本地 sidecar，可用于生成成长作品集。',
                              style: TextStyle(color: Colors.brown.shade600),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                Chip(label: Text('素材 ${assets.length}')),
                                Chip(label: Text('绘画 $artworkCount')),
                                Chip(label: Text('照片 $photoCount')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SecondaryButton(
                        label: '编辑资料',
                        icon: Icons.edit_rounded,
                        iconAsset: editIconAsset,
                        onPressed: onEditProfile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _GrowthStatsPanel(
                        assetCount: assets.length,
                        artworkCount: artworkCount,
                        photoCount: photoCount,
                        craftCount: craftCount,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _DistributionPanel(
                        artworkCount: artworkCount,
                        photoCount: photoCount,
                        craftCount: craftCount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(child: _RecentAssetsPanel(assets: assets)),
                      const SizedBox(width: 18),
                      const Expanded(child: _CollectionRecordsPanel()),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _ActivityTimeline(assets: assets),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 340,
          child: _ProfileAsidePanel(
            childName: childName,
            childId: child.id,
            assets: assets,
          ),
        ),
      ],
    );
  }
}

class _ChildPortrait extends StatelessWidget {
  const _ChildPortrait({required this.childName, required this.imagePath});

  final String childName;
  final String imagePath;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 210,
    height: 210,
    child: imagePath.trim().isEmpty
        ? WarmPicture(
            icon: Icons.child_care_rounded,
            assetPath: childIconAsset,
            label: childName,
          )
        : AssetArtworkPreview(
            path: imagePath,
            fallbackIcon: Icons.child_care_rounded,
            fallbackAssetPath: childIconAsset,
            label: childName,
            width: 210,
            height: 210,
            fit: BoxFit.cover,
          ),
  );
}

class _ProfileHeaderScene extends StatelessWidget {
  const _ProfileHeaderScene();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 520,
    height: 112,
    child: Center(
      child: AppAssetIcon(
        bearHeadIconAsset,
        size: 78,
      ),
    ),
  );
}

AssetVm? _profileImageAsset(List<AssetVm> assets) {
  bool looksLikeChildPortrait(AssetVm asset) {
    final text = '${asset.title} ${asset.description} ${asset.tags.join(' ')}';
    return text.contains('男孩') ||
        text.contains('女孩') ||
        text.contains('孩子') ||
        text.contains('小朋友') ||
        text.contains('笑') ||
        text.toLowerCase().contains('child');
  }

  for (final asset in assets) {
    if (asset.type == 'photo' &&
        asset.previewPath.trim().isNotEmpty &&
        looksLikeChildPortrait(asset)) {
      return asset;
    }
  }
  for (final asset in assets) {
    if (asset.type == 'photo' && asset.previewPath.trim().isNotEmpty) {
      return asset;
    }
  }
  for (final asset in assets) {
    if (asset.previewPath.trim().isNotEmpty) return asset;
  }
  return null;
}

class _GrowthStatsPanel extends StatelessWidget {
  const _GrowthStatsPanel({
    required this.assetCount,
    required this.artworkCount,
    required this.photoCount,
    required this.craftCount,
  });

  final int assetCount;
  final int artworkCount;
  final int photoCount;
  final int craftCount;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(iconAsset: gridIconAsset, title: '成长统计'),
        const SizedBox(height: 18),
        Row(
          children: [
            _MetricTile(label: '素材总数', value: '$assetCount'),
            _MetricTile(label: '绘画', value: '$artworkCount'),
            _MetricTile(label: '照片', value: '$photoCount'),
            _MetricTile(label: '手工', value: '$craftCount'),
          ],
        ),
      ],
    ),
  );
}

class _DistributionPanel extends StatelessWidget {
  const _DistributionPanel({
    required this.artworkCount,
    required this.photoCount,
    required this.craftCount,
  });

  final int artworkCount;
  final int photoCount;
  final int craftCount;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(iconAsset: paletteIconAsset, title: '素材分布'),
        const SizedBox(height: 18),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              _DistributionChart(
                artworkCount: artworkCount,
                photoCount: photoCount,
                craftCount: craftCount,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendRow(
                      iconAsset: paletteIconAsset,
                      label: '绘画',
                      value: artworkCount,
                    ),
                    _LegendRow(
                      iconAsset: cameraIconAsset,
                      label: '照片',
                      value: photoCount,
                    ),
                    _LegendRow(
                      iconAsset: bearDocumentIconAsset,
                      label: '手工',
                      value: craftCount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DistributionChart extends StatelessWidget {
  const _DistributionChart({
    required this.artworkCount,
    required this.photoCount,
    required this.craftCount,
  });

  final int artworkCount;
  final int photoCount;
  final int craftCount;

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      artworkCount,
      photoCount,
      craftCount,
      1,
    ].reduce((a, b) => a > b ? a : b);
    return SizedBox(
      width: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ChartBar(
            value: artworkCount,
            maxValue: maxValue,
            color: const Color(0xffffbd54),
          ),
          const SizedBox(width: 8),
          _ChartBar(
            value: photoCount,
            maxValue: maxValue,
            color: const Color(0xff5d9be8),
          ),
          const SizedBox(width: 8),
          _ChartBar(
            value: craftCount,
            maxValue: maxValue,
            color: const Color(0xff2faa61),
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final height = 18 + 58 * (value / maxValue);
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _RecentAssetsPanel extends StatelessWidget {
  const _RecentAssetsPanel({required this.assets});

  final List<AssetVm> assets;

  @override
  Widget build(BuildContext context) {
    final recentAssets = assets.take(3).toList();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(iconAsset: imageIconAsset, title: '最近作品'),
          const SizedBox(height: 18),
          Expanded(
            child: recentAssets.isEmpty
                ? const _EmptyPanelHint(
                    iconAsset: imageIconAsset,
                    text: '导入素材后显示最近作品',
                  )
                : Row(
                    children: [
                      for (
                        var index = 0;
                        index < recentAssets.length;
                        index++
                      ) ...[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == recentAssets.length - 1 ? 0 : 8,
                            ),
                            child: AssetArtworkPreview(
                              path: recentAssets[index].previewPath,
                              fallbackIcon: recentAssets[index].icon,
                              fallbackAssetPath: _assetIconAsset(
                                recentAssets[index].type,
                              ),
                              label: recentAssets[index].title,
                              height: 120,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CollectionRecordsPanel extends StatelessWidget {
  const _CollectionRecordsPanel();

  @override
  Widget build(BuildContext context) => const SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(iconAsset: bookIconAsset, title: '作品集记录'),
        SizedBox(height: 18),
        Expanded(
          child: _EmptyPanelHint(
            iconAsset: bookIconAsset,
            text: '生成完成后会显示本地作品集记录',
          ),
        ),
      ],
    ),
  );
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline({required this.assets});

  final List<AssetVm> assets;

  @override
  Widget build(BuildContext context) {
    final timelineItems = assets.isEmpty
        ? const [
            _TimelineItem('创建档案', '今天', childIconAsset),
            _TimelineItem('导入素材', '待开始', imageIconAsset),
            _TimelineItem('生成作品', '待开始', bookIconAsset),
          ]
        : assets
              .take(5)
              .map(
                (asset) => _TimelineItem(
                  asset.title,
                  asset.capturedAt.isEmpty ? '未填写日期' : asset.capturedAt,
                  _assetIconAsset(asset.type),
                ),
              )
              .toList();

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(iconAsset: timelineIconAsset, title: '成长时间轴'),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var index = 0; index < timelineItems.length; index++) ...[
                Expanded(child: _TimelineNode(item: timelineItems[index])),
                if (index != timelineItems.length - 1)
                  Container(
                    width: 34,
                    height: 2,
                    color: const Color(0xffd7e8d9),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAsidePanel extends StatelessWidget {
  const _ProfileAsidePanel({
    required this.childName,
    required this.childId,
    required this.assets,
  });

  final String childName;
  final String childId;
  final List<AssetVm> assets;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: SurfaceCard(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(iconAsset: infoIconAsset, title: '档案信息'),
                const SizedBox(height: 18),
                _InfoRow(
                  iconAsset: childIconAsset,
                  label: '姓名',
                  value: childName,
                ),
                _InfoRow(
                  iconAsset: tagIconAsset,
                  label: '孩子 ID',
                  value: childId,
                ),
                _InfoRow(
                  iconAsset: gridIconAsset,
                  label: '素材总数',
                  value: '${assets.length} 项',
                ),
                _InfoRow(
                  iconAsset: imageIconAsset,
                  label: '最近素材',
                  value: assets.isEmpty ? '暂无' : assets.first.title,
                ),
                const Divider(height: 30),
                const _SectionHeader(
                  iconAsset: bearHeadIconAsset,
                  title: '成长里程碑',
                ),
                const SizedBox(height: 14),
                _MilestoneRow(text: assets.isEmpty ? '等待第一份素材' : '已开始积累成长素材'),
                const _MilestoneRow(text: '时间线按素材日期自动更新'),
                const _MilestoneRow(text: '作品集记录保存在本地'),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      const _ProfileArtworkRail(
        title: '每一份素材，都会进入本地成长档案',
        text: '统计和时间线来自当前孩子的素材库。',
      ),
    ],
  );
}

class _ProfileArtworkRail extends StatelessWidget {
  const _ProfileArtworkRail({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ProjectIconMark(size: 132),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xff77685e), height: 1.5),
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.iconAsset, required this.title});

  final String iconAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    final accent = _softAccent(iconAsset);
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xff8c7663))),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  final String iconAsset;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        _LegendDot(color: _softAccent(iconAsset)),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _EmptyPanelHint extends StatelessWidget {
  const _EmptyPanelHint({required this.iconAsset, required this.text});

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    final accent = _softAccent(iconAsset);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 3,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xff77685e)),
          ),
        ],
      ),
    );
  }
}

Color _softAccent(String key) {
  if (key.contains('camera') || key.contains('照片')) {
    return const Color(0xff5d9be8);
  }
  if (key.contains('palette') || key.contains('调色')) {
    return const Color(0xffffbd54);
  }
  if (key.contains('book') || key.contains('书本')) {
    return const Color(0xff6f9af8);
  }
  return const Color(0xff2faa61);
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.item});

  final _TimelineItem item;

  @override
  Widget build(BuildContext context) {
    final accent = _softAccent(item.iconAsset);
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.38)),
          ),
          child: Text(
            item.title.isEmpty ? '•' : item.title.substring(0, 1),
            style: TextStyle(color: accent, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item.date,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xff77685e), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _TimelineItem {
  const _TimelineItem(this.title, this.date, this.iconAsset);

  final String title;
  final String date;
  final String iconAsset;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  final String iconAsset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final accent = _softAccent(iconAsset);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Color(0xff7d7065))),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xff2faa61),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

String _assetIconAsset(String type) {
  return switch (type) {
    'photo' => cameraIconAsset,
    'craft' => bearDocumentIconAsset,
    _ => paletteIconAsset,
  };
}
