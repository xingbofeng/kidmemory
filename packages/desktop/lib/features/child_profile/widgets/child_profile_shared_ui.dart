import 'package:flutter/material.dart';

import '../../../shared/widgets/chrome.dart';
import '../child_profile_utils.dart';

class ChildProfileSectionHeader extends StatelessWidget {
  const ChildProfileSectionHeader({
    super.key,
    required this.iconAsset,
    required this.title,
  });

  final String iconAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    final accent = childProfileSoftAccent(iconAsset);
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

class ChildProfileMetricTile extends StatelessWidget {
  const ChildProfileMetricTile({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(label, style: const TextStyle(color: Color(0xff8c7663))),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class ChildProfileLegendRow extends StatelessWidget {
  const ChildProfileLegendRow({
    super.key,
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
        ChildProfileLegendDot(color: childProfileSoftAccent(iconAsset)),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class ChildProfileLegendDot extends StatelessWidget {
  const ChildProfileLegendDot({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class ChildProfileEmptyPanelHint extends StatelessWidget {
  const ChildProfileEmptyPanelHint({
    super.key,
    required this.iconAsset,
    required this.text,
  });

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    final accent = childProfileSoftAccent(iconAsset);
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
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
      ),
    );
  }
}

class ChildProfileInfoRow extends StatelessWidget {
  const ChildProfileInfoRow({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  final String iconAsset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Center(
              child: AppAssetIcon(
                iconAsset,
                fallbackIcon: Icons.brightness_1_rounded,
                size: 18,
                opacity: 0.92,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xff7d7065),
                fontSize: 16,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChildProfileMilestoneRow extends StatelessWidget {
  const ChildProfileMilestoneRow({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Center(
            child: AppAssetIcon(
              completeIconAsset,
              fallbackIcon: Icons.check_circle_rounded,
              size: 18,
              opacity: 0.96,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 16, height: 1.0)),
        ),
      ],
    ),
  );
}
