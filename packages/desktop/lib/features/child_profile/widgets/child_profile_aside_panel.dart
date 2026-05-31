import 'package:flutter/material.dart';

import '../../../shared/models/library_models.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/layout.dart';
import '../../../../l10n/app_localizations.dart';
import 'child_profile_shared_ui.dart';

class ProfileAsidePanel extends StatelessWidget {
  const ProfileAsidePanel({
    super.key,
    required this.child,
    required this.assets,
  });

  final ChildVm child;
  final List<AssetVm> assets;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final l10n = AppLocalizations.of(context)!;
      final showRail = constraints.maxHeight >= 760;
      return Column(
        children: [
          Expanded(
            child: SurfaceCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChildProfileSectionHeader(
                    iconAsset: infoIconAsset,
                    title: AppLocalizations.of(context)!.childProfileS633,
                  ),
                  const SizedBox(height: 16),
                  ChildProfileInfoRow(
                    iconAsset: childIconAsset,
                    label: AppLocalizations.of(context)!.childProfileS367,
                    value: child.name,
                  ),
                  ChildProfileInfoRow(
                    iconAsset: gridIconAsset,
                    label: l10n.contentMetricTotalLabel,
                    value: l10n.childProfileAssetCountValue(assets.length),
                  ),
                  ChildProfileInfoRow(
                    iconAsset: imageIconAsset,
                    label: AppLocalizations.of(context)!.childProfileS574,
                    value: assets.isEmpty
                        ? AppLocalizations.of(context)!.childProfileS566
                        : assets.first.title,
                  ),
                  const Divider(height: 24),
                  ChildProfileSectionHeader(
                    iconAsset: bearHeadIconAsset,
                    title: AppLocalizations.of(context)!.childProfileS497,
                  ),
                  const SizedBox(height: 12),
                  ChildProfileMilestoneRow(
                    text: assets.isEmpty
                        ? AppLocalizations.of(context)!.childProfileS799
                        : AppLocalizations.of(context)!.childProfileS446,
                  ),
                  ChildProfileMilestoneRow(
                    text: l10n.childProfileTimelineAutoUpdate,
                  ),
                  ChildProfileMilestoneRow(
                    text: l10n.childProfilePortfolioSavedLocally,
                  ),
                ],
              ),
            ),
          ),
          if (showRail) ...[
            const SizedBox(height: 18),
            Expanded(
              flex: 2,
              child: ProfileArtworkRail(
                title: AppLocalizations.of(context)!.childProfileS670,
                text: AppLocalizations.of(context)!.childProfileS832,
                compact: true,
              ),
            ),
          ],
        ],
      );
    },
  );
}

class ProfileArtworkRail extends StatelessWidget {
  const ProfileArtworkRail({
    super.key,
    required this.title,
    required this.text,
    this.compact = false,
  });

  final String title;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: compact ? 94 : 112,
          height: compact ? 94 : 112,
          decoration: BoxDecoration(
            color: const Color(0xfff7f3ec),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xffeadbc9)),
          ),
          child: AppAssetIcon(userShieldIconAsset, size: compact ? 50 : 58),
        ),
        SizedBox(height: compact ? 12 : 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 15 : 16,
            fontWeight: FontWeight.w900,
          ),
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
