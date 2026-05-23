// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../../../shared/models/library_models.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/content.dart';
import '../../../shared/widgets/layout.dart';
import '../../../../l10n/app_localizations.dart';
import '../child_profile_utils.dart';
import 'child_profile_shared_ui.dart';

class RecentAssetsPanel extends StatelessWidget {
  const RecentAssetsPanel({required this.assets});

  final List<AssetVm> assets;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recentAssets = assets.take(3).toList();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChildProfileSectionHeader(
            iconAsset: imageIconAsset,
            title: l10n.childProfileRecentWorksTitle,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: recentAssets.isEmpty
                ? ChildProfileEmptyPanelHint(
                    iconAsset: imageIconAsset,
                    text: AppLocalizations.of(context)!.childProfileS400,
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
                              fallbackAssetPath: childProfileAssetIconAsset(
                                recentAssets[index].type,
                              ),
                              label: recentAssets[index].title,
                              height: 120,
                              onTap: () => showAssetArtworkPreviewDialog(
                                context: context,
                                label: recentAssets[index].title,
                                path: recentAssets[index].previewPath,
                                fallbackIcon: recentAssets[index].icon,
                                fallbackAssetPath: childProfileAssetIconAsset(
                                  recentAssets[index].type,
                                ),
                              ),
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

class CollectionRecordsPanel extends StatelessWidget {
  const CollectionRecordsPanel();

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChildProfileSectionHeader(
          iconAsset: bookIconAsset,
          title: AppLocalizations.of(context)!.contentPortfolioRecordTitle,
        ),
        SizedBox(height: 18),
        Expanded(
          child: ChildProfileEmptyPanelHint(
            iconAsset: bookIconAsset,
            text: AppLocalizations.of(context)!.childProfileS733,
          ),
        ),
      ],
    ),
  );
}
