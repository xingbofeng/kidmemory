// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../../../shared/models/library_models.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/layout.dart';
import '../../../../l10n/app_localizations.dart';
import 'child_profile_stats_panels.dart';
import 'child_profile_work_panels.dart';
import 'child_profile_aside_panel.dart';
import 'child_profile_header.dart';

class ChildProfileContent extends StatelessWidget {
  const ChildProfileContent({
    required this.child,
    required this.assets,
    required this.onAddProfile,
    required this.onEditProfile,
    required this.onDeleteProfile,
  });

  final ChildVm child;
  final List<AssetVm> assets;
  final VoidCallback onAddProfile;
  final ValueChanged<ChildVm> onEditProfile;
  final ValueChanged<ChildVm> onDeleteProfile;

  static const double _actionButtonWidth = 86;
  static const double _actionButtonHeight = 34;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final childName = child.name;
    final artworkCount = assets
        .where((asset) => asset.type == 'artwork')
        .length;
    final photoCount = assets.where((asset) => asset.type == 'photo').length;
    final craftCount = assets.where((asset) => asset.type == 'craft').length;
    final profileImage = childProfileImageAsset(assets);
    Widget buildActionButtons(double maxWidth) => ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.end,
        children: [
          SizedBox(
            width: _actionButtonWidth,
            height: _actionButtonHeight,
            child: SecondaryButton(
              label: AppLocalizations.of(context)!.childProfileS554,
              icon: Icons.add_rounded,
              iconAsset: addIconAsset,
              fullWidth: true,
              height: _actionButtonHeight,
              fontSize: 13,
              iconSize: 15,
              onPressed: onAddProfile,
            ),
          ),
          SizedBox(
            width: _actionButtonWidth,
            height: _actionButtonHeight,
            child: SecondaryButton(
              label: AppLocalizations.of(context)!.childProfileS834,
              icon: Icons.edit_rounded,
              iconAsset: editIconAsset,
              fullWidth: true,
              height: _actionButtonHeight,
              fontSize: 13,
              iconSize: 15,
              onPressed: () => onEditProfile(child),
            ),
          ),
          SizedBox(
            width: _actionButtonWidth,
            height: _actionButtonHeight,
            child: DeleteChildButton(
              compact: true,
              onPressed: () => onDeleteProfile(child),
            ),
          ),
        ],
      ),
    );

    final content = Row(
      children: [
        Expanded(
          child: Column(
            children: [
              SurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: buildActionButtons(_actionButtonWidth * 3 + 20),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChildProfilePortrait(
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
                                l10n.childProfileLinkedAssets(assets.length),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                assets.isEmpty
                                    ? AppLocalizations.of(
                                        context,
                                      )!.childProfileS401
                                    : AppLocalizations.of(
                                        context,
                                      )!.childProfileS486,
                                style: TextStyle(color: Colors.brown.shade600),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  Chip(
                                    label: Text(
                                      l10n.childProfileAssetChip(assets.length),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      l10n.childProfileArtworkChip(
                                        artworkCount,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      l10n.childProfilePhotoChip(photoCount),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: GrowthStatsPanel(
                        assetCount: assets.length,
                        artworkCount: artworkCount,
                        photoCount: photoCount,
                        craftCount: craftCount,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: ChildProfileDistributionPanel(
                        artworkCount: artworkCount,
                        photoCount: photoCount,
                        craftCount: craftCount,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: RecentAssetsPanel(assets: assets)),
                    const SizedBox(width: 18),
                    const Expanded(child: CollectionRecordsPanel()),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 340,
          child: ProfileAsidePanel(child: child, assets: assets),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight >= 660) return content;
        return SingleChildScrollView(
          child: SizedBox(height: 660, child: content),
        );
      },
    );
  }
}
