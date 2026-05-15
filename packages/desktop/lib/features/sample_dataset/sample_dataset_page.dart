import 'package:flutter/material.dart';

import '../../shared/widgets/chrome.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/layout.dart';
import '../../shared/widgets/status.dart';

class SampleDatasetPage extends StatelessWidget {
  const SampleDatasetPage({
    required this.imported,
    required this.onImport,
    required this.previewAssets,
    required this.artworkCount,
    required this.craftCount,
    required this.photoCount,
    required this.tagCount,
    required this.onReset,
    required this.onOpenSamplePdf,
    required this.importing,
    super.key,
  });

  final bool imported;
  final bool importing;
  final VoidCallback onImport;
  final List<AssetPreviewItem> previewAssets;
  final int artworkCount;
  final int craftCount;
  final int photoCount;
  final int tagCount;
  final VoidCallback onReset;
  final VoidCallback onOpenSamplePdf;

  @override
  Widget build(BuildContext context) {
    final assets = previewAssets;
    final counts = {
      "artwork": artworkCount,
      "craft": craftCount,
      "photo": photoCount,
    };

    return PageFrame(
      title: '示例数据集',
      subtitle: '使用隐私安全的虚拟数据，快速体验 KidMemory 的全部功能。',
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                InfoHero(
                  iconAsset: shieldIconAsset,
                  title: '使用隐私安全的虚拟数据集',
                  text: '所有示例素材均为虚构内容，仅用于功能演示与体验，不包含任何真实个人数据。',
                  trailing: const ProjectIconMark(size: 112),
                ),
                const SizedBox(height: 18),
                MetricStrip(
                  metrics: [
                    ('素材总数', '${assets.length} 项'),
                    ('儿童画', '${counts['artwork']} 张'),
                    ('手工作品', '${counts['craft']} 件'),
                    ('素材许可', 'CC0'),
                    ('照片', '${counts['photo']} 张'),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AssetPreviewGrid(compact: true, items: previewAssets),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: SmallInfoCard(
                        iconAsset: infoIconAsset,
                        title: '数据说明',
                        text: '所有素材为脱敏示例，已进行隐私脱敏处理。可随时重置恢复到干净状态。',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SmallInfoCard(
                        iconAsset: uploadIconAsset,
                        title: '导入步骤',
                        text: '确认数据，点击导入，等待完成，然后继续探索生成流程。',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SmallInfoCard(
                        iconAsset: pdfIconAsset,
                        title: '预期输出',
                        text: '自动导入素材与标签，生成示例书稿与样例 PDF。',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SidePanel(
                    title: '示例数据集内容',
                    artworkCount: counts['artwork'] ?? 0,
                    craftCount: counts['craft'] ?? 0,
                    photoCount: counts['photo'] ?? 0,
                    tagCount: tagCount,
                  ),
                  const SizedBox(height: 22),
                  const SuccessBanner(
                    title: '隐私安全 · 本地优先',
                    text: '所有数据仅存储在本地设备，不上传任何内容，隐私由你掌控。',
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: importing
                        ? '正在导入...'
                        : (imported ? '已导入示例数据集' : '导入示例数据集'),
                    icon: Icons.upload_rounded,
                    iconAsset: uploadIconAsset,
                    onPressed: importing ? null : onImport,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: '重置数据',
                    icon: Icons.refresh_rounded,
                    iconAsset: refreshIconAsset,
                    fullWidth: true,
                    height: 58,
                    onPressed: importing ? null : onReset,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: '查看示例 PDF',
                    icon: Icons.picture_as_pdf_rounded,
                    iconAsset: pdfIconAsset,
                    fullWidth: true,
                    height: 58,
                    onPressed: onOpenSamplePdf,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
