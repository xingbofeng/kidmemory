// ignore_for_file: use_key_in_widget_constructors

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/layout.dart';
import '../../../../l10n/app_localizations.dart';
import 'child_profile_shared_ui.dart';

class GrowthStatsPanel extends StatelessWidget {
  const GrowthStatsPanel({
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChildProfileSectionHeader(
            iconAsset: gridIconAsset,
            title: l10n.childProfileGrowthStatsTitle,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ChildProfileMetricTile(
                  label: l10n.contentMetricTotalLabel,
                  value: '$assetCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChildProfileMetricTile(
                  label: l10n.contentCategoryDrawingLabel,
                  value: '$artworkCount',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChildProfileMetricTile(
                  label: l10n.contentAssetTypePhotoLabel,
                  value: '$photoCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChildProfileMetricTile(
                  label: l10n.contentAssetTypeCraftLabel,
                  value: '$craftCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChildProfileDistributionPanel extends StatelessWidget {
  const ChildProfileDistributionPanel({
    required this.artworkCount,
    required this.photoCount,
    required this.craftCount,
  });

  final int artworkCount;
  final int photoCount;
  final int craftCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChildProfileSectionHeader(
            iconAsset: paletteIconAsset,
            title: l10n.childProfileAssetDistributionTitle,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                ChildProfileDistributionChart(
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
                      ChildProfileLegendRow(
                        iconAsset: paletteIconAsset,
                        label: l10n.contentCategoryDrawingLabel,
                        value: artworkCount,
                      ),
                      ChildProfileLegendRow(
                        iconAsset: cameraIconAsset,
                        label: l10n.contentAssetTypePhotoLabel,
                        value: photoCount,
                      ),
                      ChildProfileLegendRow(
                        iconAsset: bearDocumentIconAsset,
                        label: l10n.contentAssetTypeCraftLabel,
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
}

class ChildProfileDistributionChart extends StatelessWidget {
  const ChildProfileDistributionChart({
    required this.artworkCount,
    required this.photoCount,
    required this.craftCount,
  });

  final int artworkCount;
  final int photoCount;
  final int craftCount;

  @override
  Widget build(BuildContext context) {
    final total = artworkCount + photoCount + craftCount;
    final values = [artworkCount, photoCount, craftCount];
    const colors = [Color(0xfff4be57), Color(0xff6e9ee3), Color(0xff70c19b)];
    return SizedBox(
      width: 116,
      height: 116,
      child: CustomPaint(
        painter: ChildProfilePieChartPainter(
          values: values,
          colors: colors,
          total: total,
        ),
      ),
    );
  }
}

class ChildProfilePieChartPainter extends CustomPainter {
  const ChildProfilePieChartPainter({
    required this.values,
    required this.colors,
    required this.total,
  });

  final List<int> values;
  final List<Color> colors;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const strokeGap = 0.03;
    var start = -math.pi / 2;
    final safeTotal = total <= 0 ? 1 : total;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / safeTotal) * math.pi * 2;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, start, sweep - strokeGap, true, paint);
      start += sweep;
    }
    final holePaint = Paint()..color = const Color(0xfffcfbf9);
    canvas.drawCircle(center, radius * 0.4, holePaint);
    final borderPaint = Paint()
      ..color = const Color(0xffe5ddd2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant ChildProfilePieChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.values != values;
  }
}
