// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../../../shared/widgets/chrome.dart';
import '../../../../l10n/app_localizations.dart';
import 'asset_library_palette.dart';

class AssetLibraryBatchActionBar extends StatelessWidget {
  const AssetLibraryBatchActionBar({
    required this.selectedCount,
    required this.onDeleteSelected,
    required this.onClearSelection,
    required this.deleteBusy,
    this.onGoToGenerate,
  });

  final int selectedCount;
  final Future<void> Function()? onDeleteSelected;
  final VoidCallback onClearSelection;
  final bool deleteBusy;
  final VoidCallback? onGoToGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AssetLibraryPalette.successTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AssetLibraryPalette.successStrongBorder),
      ),
      child: Row(
        children: [
          const AppAssetIcon(completeIconAsset, size: 24),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(
              context,
            )!.assetLibrarySelectedAssetsCount(selectedCount),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AssetLibraryPalette.successText,
            ),
          ),
          const Spacer(),
          AssetLibraryBatchTextButton(
            label: AppLocalizations.of(
              context,
            )!.assetLibraryBatchGeneratePictureBookLabel,
            onPressed: onGoToGenerate,
          ),
          AssetLibraryBatchTextButton(
            label: AppLocalizations.of(
              context,
            )!.assetLibraryBatchGenerateVideoLabel,
            onPressed: onGoToGenerate,
          ),
          AssetLibraryBatchTextButton(
            label: AppLocalizations.of(
              context,
            )!.assetLibraryBatchGenerateAlbumLabel,
            onPressed: onGoToGenerate,
          ),
          TextButton(
            onPressed: onClearSelection,
            child: Text(
              AppLocalizations.of(context)!.assetLibraryClearSelectionLabel,
            ),
          ),
          TextButton.icon(
            onPressed: onDeleteSelected,
            icon: const AppAssetIcon(deleteIconAsset, size: 18),
            label: Text(
              deleteBusy
                  ? AppLocalizations.of(context)!.assetLibraryBatchDeletingLabel
                  : AppLocalizations.of(
                      context,
                    )!.assetLibraryBatchDeleteButtonLabel,
            ),
            style: TextButton.styleFrom(
              foregroundColor: AssetLibraryPalette.dangerText,
            ),
          ),
        ],
      ),
    );
  }
}

class AssetLibraryBatchTextButton extends StatelessWidget {
  const AssetLibraryBatchTextButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AssetLibraryPalette.successAction,
      ),
      child: Text(label),
    );
  }
}
