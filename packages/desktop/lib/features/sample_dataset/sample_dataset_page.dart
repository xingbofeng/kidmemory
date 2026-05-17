import 'package:flutter/material.dart';

import '../../shared/widgets/chrome.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/layout.dart';

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
    required this.onBrowseSampleAssets,
    required this.onGenerateSampleBook,
    required this.importing,
    this.onBack,
    this.importFailed = false,
    super.key,
  });

  final bool imported;
  final bool importing;
  final bool importFailed;
  final VoidCallback onImport;
  final List<AssetPreviewItem> previewAssets;
  final int artworkCount;
  final int craftCount;
  final int photoCount;
  final int tagCount;
  final VoidCallback onReset;
  final VoidCallback onOpenSamplePdf;
  final VoidCallback onBrowseSampleAssets;
  final VoidCallback onGenerateSampleBook;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final assets = previewAssets;
    final displayAssets = assets.isEmpty ? _samplePreviewPlaceholders : assets;
    final samplePreviewOnly = assets.isEmpty;
    final counts = {
      "artwork": samplePreviewOnly ? _sampleArtworkCount : artworkCount,
      "craft": samplePreviewOnly ? _sampleCraftCount : craftCount,
      "photo": samplePreviewOnly ? _samplePhotoCount : photoCount,
    };
    final totalCount = samplePreviewOnly ? _sampleAssetCount : assets.length;
    final effectiveTagCount = samplePreviewOnly ? _sampleTagCount : tagCount;

    return PageFrame(
      title: '示例数据集',
      subtitle: '使用隐私安全的虚拟素材，快速体验 KidMemory 的素材库、创作台和导出流程。',
      leading: onBack == null
          ? null
          : PageBackButton(tooltip: '返回孩子档案', onPressed: onBack!),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  MetricStrip(
                    metrics: [
                      ('素材总数', '$totalCount 项'),
                      ('儿童画', '${counts['artwork']} 张'),
                      ('手工作品', '${counts['craft']} 件'),
                      ('素材许可', 'CC0'),
                      ('照片', '${counts['photo']} 张'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AssetPreviewGrid(compact: true, items: displayAssets),
                  const SizedBox(height: 28),
                  const Row(
                    children: [
                      Expanded(
                        child: SmallInfoCard(
                          iconAsset: infoIconAsset,
                          title: '数据说明',
                          text: '虚拟脱敏素材，仅用于功能演示。可随时重置为干净状态。',
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
                          text: '手动导入素材与标签后，可继续体验创作台与样例 PDF。',
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
              child: Column(
                children: [
                  SidePanel(
                    title: '导入后将包含',
                    artworkCount: counts['artwork'] ?? 0,
                    craftCount: counts['craft'] ?? 0,
                    photoCount: counts['photo'] ?? 0,
                    tagCount: effectiveTagCount,
                  ),
                  const SizedBox(height: 14),
                  _SampleActionPanel(
                    imported: imported,
                    importing: importing,
                    importFailed: importFailed,
                    onImport: onImport,
                    onBrowseSampleAssets: onBrowseSampleAssets,
                    onGenerateSampleBook: onGenerateSampleBook,
                    onOpenSamplePdf: onOpenSamplePdf,
                    onReset: onReset,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<AssetPreviewItem> _samplePreviewPlaceholders = [
  AssetPreviewItem(
    label: '阳光花园',
    icon: Icons.photo_camera_rounded,
    typeLabel: '照片',
    iconAsset: cameraIconAsset,
    path: 'asset://assets/sample_dataset/raster/阳光花园.png',
  ),
  AssetPreviewItem(
    label: '草地男孩',
    icon: Icons.photo_camera_rounded,
    typeLabel: '照片',
    iconAsset: cameraIconAsset,
    path: 'asset://assets/sample_dataset/raster/草地男孩.png',
  ),
  AssetPreviewItem(
    label: '生日蛋糕',
    icon: Icons.photo_camera_rounded,
    typeLabel: '照片',
    iconAsset: cameraIconAsset,
    path: 'asset://assets/sample_dataset/raster/生日蛋糕.png',
  ),
  AssetPreviewItem(
    label: '生日男孩',
    icon: Icons.photo_camera_rounded,
    typeLabel: '照片',
    iconAsset: cameraIconAsset,
    path: 'asset://assets/sample_dataset/raster/生日男孩.png',
  ),
  AssetPreviewItem(
    label: '海底世界',
    icon: Icons.photo_camera_rounded,
    typeLabel: '照片',
    iconAsset: cameraIconAsset,
    path: 'asset://assets/sample_dataset/raster/海底世界.png',
  ),
  AssetPreviewItem(
    label: '恐龙世界',
    icon: Icons.photo_camera_rounded,
    typeLabel: '照片',
    iconAsset: cameraIconAsset,
    path: 'asset://assets/sample_dataset/raster/恐龙世界.png',
  ),
  AssetPreviewItem(
    label: '幸福一家',
    icon: Icons.photo_camera_rounded,
    typeLabel: '照片',
    iconAsset: cameraIconAsset,
    path: 'asset://assets/sample_dataset/raster/幸福一家.png',
  ),
  AssetPreviewItem(
    label: '小熊画',
    icon: Icons.photo_camera_rounded,
    typeLabel: '照片',
    iconAsset: cameraIconAsset,
    path: 'asset://assets/sample_dataset/raster/小熊画.png',
  ),
];

const _sampleAssetCount = 17;
const _sampleArtworkCount = 6;
const _sampleCraftCount = 2;
const _samplePhotoCount = 9;
const _sampleTagCount = 31;

class _SampleActionPanel extends StatelessWidget {
  const _SampleActionPanel({
    required this.imported,
    required this.importing,
    required this.importFailed,
    required this.onImport,
    required this.onBrowseSampleAssets,
    required this.onGenerateSampleBook,
    required this.onOpenSamplePdf,
    required this.onReset,
  });

  final bool imported;
  final bool importing;
  final bool importFailed;
  final VoidCallback onImport;
  final VoidCallback onBrowseSampleAssets;
  final VoidCallback onGenerateSampleBook;
  final VoidCallback onOpenSamplePdf;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    if (importing) {
      return Column(
        children: [
          const _SampleStatusCard(
            iconAsset: uploadIconAsset,
            title: '正在导入示例数据...',
            text: '创建示例孩子档案、导入示例素材并写入标签。',
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: '导入中...',
            icon: Icons.hourglass_top_rounded,
            iconAsset: uploadIconAsset,
            onPressed: null,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '查看示例 PDF',
            icon: Icons.picture_as_pdf_rounded,
            iconAsset: pdfIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: null,
          ),
        ],
      );
    }

    if (imported) {
      return Column(
        children: [
          const _SampleStatusCard(
            iconAsset: completeIconAsset,
            title: '示例数据已导入',
            text: '你可以继续浏览示例素材，或体验生成流程。',
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '浏览示例素材',
            icon: Icons.grid_view_rounded,
            iconAsset: gridIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: onBrowseSampleAssets,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '生成示例绘本',
            icon: Icons.auto_awesome_rounded,
            iconAsset: wandIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: onGenerateSampleBook,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '查看示例 PDF',
            icon: Icons.picture_as_pdf_rounded,
            iconAsset: pdfIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: onOpenSamplePdf,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '重置数据',
            icon: Icons.refresh_rounded,
            iconAsset: refreshIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: onReset,
          ),
        ],
      );
    }

    if (importFailed) {
      return Column(
        children: [
          const _SampleStatusCard(
            iconAsset: infoIconAsset,
            title: '导入失败',
            text: '请检查本地数据库和示例素材文件。',
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: '重试导入',
            icon: Icons.refresh_rounded,
            iconAsset: refreshIconAsset,
            onPressed: onImport,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '查看示例 PDF',
            icon: Icons.picture_as_pdf_rounded,
            iconAsset: pdfIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: null,
          ),
        ],
      );
    }

    return Column(
      children: [
        const _SampleStatusCard(
          iconAsset: infoIconAsset,
          title: '状态：未导入',
          text: '点击导入后，示例素材会写入本地数据库。',
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: '导入示例数据集',
          icon: Icons.upload_rounded,
          iconAsset: uploadIconAsset,
          onPressed: onImport,
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: '查看示例 PDF',
          icon: Icons.picture_as_pdf_rounded,
          iconAsset: pdfIconAsset,
          fullWidth: true,
          height: 58,
          onPressed: null,
        ),
      ],
    );
  }
}

class _SampleStatusCard extends StatelessWidget {
  const _SampleStatusCard({
    required this.iconAsset,
    required this.title,
    required this.text,
  });

  final String iconAsset;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xfffffcf6),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xffeadfce)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAssetIcon(iconAsset, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff28170f),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xff766b61),
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
