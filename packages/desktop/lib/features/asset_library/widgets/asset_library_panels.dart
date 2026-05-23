// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../../../shared/models/library_models.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/content.dart';
import '../../../shared/widgets/layout.dart';
import '../../../../l10n/app_localizations.dart';
import 'asset_library_palette.dart';
import 'asset_library_toolbar_controls.dart';

class EmptyAssetLibrary extends StatelessWidget {
  const EmptyAssetLibrary({
    required this.onImportFiles,
    required this.onImportFolder,
    super.key,
  });

  final Future<void> Function() onImportFiles;
  final Future<void> Function() onImportFolder;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      backgroundColor: AssetLibraryPalette.fieldFill,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AssetLibraryPalette.emptyIconFill,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AssetLibraryPalette.emptyIconBorder,
                  ),
                ),
                child: const AppAssetIcon(imageIconAsset, size: 42),
              ),
              const SizedBox(height: 18),
              Text(
                AppLocalizations.of(context)!.assetLibraryEmptyLibraryTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.assetLibraryImportDescriptionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AssetLibraryPalette.bodyMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AssetLibraryToolbarButton(
                    iconAsset: imageIconAsset,
                    label: AppLocalizations.of(
                      context,
                    )!.assetLibraryImportPhotoLabel,
                    onPressed: onImportFiles,
                  ),
                  const SizedBox(width: 12),
                  AssetLibraryToolbarButton(
                    iconAsset: folderIconAsset,
                    label: AppLocalizations.of(
                      context,
                    )!.assetLibraryImportFolderLabel,
                    onPressed: onImportFolder,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyAssetSearchResults extends StatelessWidget {
  const EmptyAssetSearchResults({
    required this.onClearSearch,
    required this.onSmartPick,
  });

  final VoidCallback onClearSearch;
  final Future<void> Function() onSmartPick;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      backgroundColor: AssetLibraryPalette.fieldFill,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppAssetIcon(searchIconAsset, size: 54),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.assetLibraryEmptySearchTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.assetLibrarySearchFallbackHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AssetLibraryPalette.bodyMuted,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: onClearSearch,
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.assetLibraryClearSearchActionLabel,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onSmartPick,
                    icon: const AppAssetIcon(wandIconAsset, size: 18),
                    label: Text(
                      AppLocalizations.of(context)!.assetLibrarySmartPickLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AssetLibraryGridArea extends StatelessWidget {
  const AssetLibraryGridArea({
    required this.visibleAssets,
    required this.pageAssets,
    required this.searchText,
    required this.semanticSearchActive,
    required this.selectedAssets,
    required this.displayType,
    required this.onClearSearch,
    required this.onSmartPick,
    required this.onImportFiles,
    required this.onImportFolder,
    required this.onAssetTap,
  });

  final List<AssetVm> visibleAssets;
  final List<AssetVm> pageAssets;
  final String searchText;
  final bool semanticSearchActive;
  final Set<String> selectedAssets;
  final String Function(String value) displayType;
  final VoidCallback onClearSearch;
  final Future<void> Function() onSmartPick;
  final Future<void> Function() onImportFiles;
  final Future<void> Function() onImportFolder;
  final ValueChanged<AssetVm> onAssetTap;

  @override
  Widget build(BuildContext context) {
    if (visibleAssets.isEmpty) {
      final hasQuery = searchText.trim().isNotEmpty || semanticSearchActive;
      if (hasQuery) {
        return EmptyAssetSearchResults(
          onClearSearch: onClearSearch,
          onSmartPick: onSmartPick,
        );
      }
      return EmptyAssetLibrary(
        onImportFiles: onImportFiles,
        onImportFolder: onImportFolder,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1120
            ? 4
            : width >= 760
            ? 3
            : 2;
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.72,
          ),
          itemCount: pageAssets.length,
          itemBuilder: (context, index) {
            final asset = pageAssets[index];
            return AssetCard(
              asset: SampleAssetVm(
                asset.id,
                asset.title,
                displayType(asset.type),
                asset.icon,
                asset.capturedAt,
                asset.tags,
                imagePath: asset.imagePath,
                thumbnailPath: asset.thumbnailPath,
                previewUrl: asset.previewUrl,
                matchReasons: asset.matchReasons,
              ),
              selected: selectedAssets.contains(asset.id),
              onTap: () => onAssetTap(asset),
            );
          },
        );
      },
    );
  }
}
