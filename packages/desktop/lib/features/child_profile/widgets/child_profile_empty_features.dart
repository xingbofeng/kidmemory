// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../../../shared/widgets/chrome.dart';
import '../../../../l10n/app_localizations.dart';

class EmptyFeatureStrip extends StatelessWidget {
  const EmptyFeatureStrip();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 680) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 16,
          children: [
            EmptyFeaturePill(
              iconAsset: imageIconAsset,
              title: AppLocalizations.of(context)!.childProfileS842,
              text: AppLocalizations.of(context)!.childProfileS706,
            ),
            EmptyFeaturePill(
              iconAsset: timelineIconAsset,
              title: AppLocalizations.of(context)!.childProfileS495,
              text: AppLocalizations.of(context)!.childProfileS925,
            ),
            EmptyFeaturePill(
              iconAsset: starIconAsset,
              title: AppLocalizations.of(context)!.childProfileS231,
              text: AppLocalizations.of(context)!.childProfileS714,
            ),
          ],
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyFeaturePill(
            iconAsset: imageIconAsset,
            title: AppLocalizations.of(context)!.childProfileS842,
            text: AppLocalizations.of(context)!.childProfileS706,
          ),
          EmptyFeatureDivider(),
          EmptyFeaturePill(
            iconAsset: timelineIconAsset,
            title: AppLocalizations.of(context)!.childProfileS495,
            text: AppLocalizations.of(context)!.childProfileS925,
          ),
          EmptyFeatureDivider(),
          EmptyFeaturePill(
            iconAsset: starIconAsset,
            title: AppLocalizations.of(context)!.childProfileS231,
            text: AppLocalizations.of(context)!.childProfileS714,
          ),
        ],
      );
    },
  );
}

class EmptyFeaturePill extends StatelessWidget {
  const EmptyFeaturePill({
    required this.iconAsset,
    required this.title,
    required this.text,
  });

  final String iconAsset;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xfffffbef),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xffeee5d7)),
        ),
        child: AppAssetIcon(iconAsset, size: 31),
      ),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff423329),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xff9a9188),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ],
  );
}

class EmptyFeatureDivider extends StatelessWidget {
  const EmptyFeatureDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 52,
    margin: const EdgeInsets.symmetric(horizontal: 28),
    color: const Color(0xffe7dfd4),
  );
}
