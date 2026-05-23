// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../../../shared/widgets/chrome.dart';
import '../../../../l10n/app_localizations.dart';
import 'child_profile_empty_artwork.dart';

class EmptyPrivacyCard extends StatelessWidget {
  const EmptyPrivacyCard();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 780;
      return EmptyDesignCard(
        padding: compact
            ? const EdgeInsets.fromLTRB(34, 30, 34, 28)
            : const EdgeInsets.fromLTRB(44, 48, 44, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: ShieldHomeIllustration(
                width: compact ? 228 : 288,
                height: compact ? 132 : 184,
              ),
            ),
            SizedBox(height: compact ? 18 : 28),
            Text(
              AppLocalizations.of(context)!.childProfileS224,
              style: TextStyle(
                color: Color(0xff28170f),
                fontSize: 27,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -0.6,
              ),
            ),
            SizedBox(height: compact ? 12 : 16),
            Text(
              AppLocalizations.of(context)!.childProfileS499,
              style: TextStyle(
                color: Color(0xff756a60),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            SizedBox(height: compact ? 18 : 24),
            EmptyPrivacyRow(
              iconAsset: lockIconAsset,
              title: AppLocalizations.of(context)!.childProfileS602,
              text: AppLocalizations.of(context)!.childProfileS500,
              compact: true,
            ),
            SizedBox(height: compact ? 12 : 16),
            EmptyPrivacyRow(
              iconAsset: leafIconAsset,
              title: AppLocalizations.of(context)!.childProfileS785,
              text: AppLocalizations.of(context)!.childProfileS556,
              compact: true,
            ),
            SizedBox(height: compact ? 12 : 16),
            EmptyPrivacyRow(
              iconAsset: childIconAsset,
              title: AppLocalizations.of(context)!.childProfileS223,
              text: AppLocalizations.of(context)!.childProfileS342,
              compact: true,
            ),
            SizedBox(height: compact ? 16 : 20),
            const DataOwnershipBanner(compact: true),
          ],
        ),
      );
    },
  );
}

class EmptyPrivacyRow extends StatelessWidget {
  const EmptyPrivacyRow({
    required this.iconAsset,
    required this.title,
    required this.text,
    this.compact = false,
  });

  final String iconAsset;
  final String title;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: compact ? 56 : 64,
        height: compact ? 56 : 64,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xfff2f4e8),
          shape: BoxShape.circle,
        ),
        child: AppAssetIcon(iconAsset, size: compact ? 28 : 32),
      ),
      SizedBox(width: compact ? 16 : 20),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff2f2118),
                fontSize: 17,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xff8c8178),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class DataOwnershipBanner extends StatelessWidget {
  const DataOwnershipBanner({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    height: compact ? 56 : 68,
    padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 22),
    decoration: BoxDecoration(
      color: const Color(0xfffbfcf0),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xffe5e8cc), width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0a91845f),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        const AppAssetIcon(shieldIconAsset, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.childProfileS238,
            style: const TextStyle(
              color: Color(0xff58a05a),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}
