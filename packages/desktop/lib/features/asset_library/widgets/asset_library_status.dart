// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../../../shared/widgets/chrome.dart';
import '../../../../l10n/app_localizations.dart';
import 'asset_library_palette.dart';

class AssetLibraryHeaderStatus extends StatelessWidget {
  const AssetLibraryHeaderStatus({
    required this.childName,
    required this.assetCount,
    required this.indexingMessage,
  });

  final String childName;
  final int assetCount;
  final String indexingMessage;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        AssetLibrarySoftStatusChip(
          iconAsset: childIconAsset,
          text: AppLocalizations.of(
            context,
          )!.assetLibraryCurrentChildChip(childName),
        ),
        AssetLibrarySoftStatusChip(
          iconAsset: gridIconAsset,
          text: AppLocalizations.of(
            context,
          )!.assetLibraryAssetCountChip(assetCount),
        ),
        AssetLibrarySoftStatusChip(
          iconAsset: completeIconAsset,
          text: indexingMessage,
        ),
      ],
    );
  }
}

class AssetLibrarySoftStatusChip extends StatelessWidget {
  const AssetLibrarySoftStatusChip({
    required this.iconAsset,
    required this.text,
  });

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AssetLibraryPalette.fieldBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAssetIcon(iconAsset, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AssetLibraryPalette.bodyStrong,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
