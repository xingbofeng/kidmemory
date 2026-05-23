import 'package:flutter/material.dart';

import '../../shared/models/library_models.dart';

import 'asset_library_controller.dart';
import 'asset_library_page.dart';

mixin AssetLibraryAssetSelectors on State<AssetLibraryPage> {
  TextEditingController get searchController;
  String? get selectedAssetId;
  String get selectedFilterType;
  String get selectedSortMode;
  int get pageIndex;
  int get pageSize;
  List<AssetVm> get semanticSearchResults;
  bool get semanticSearchActive;

  AssetVm? get selectedAsset {
    return AssetLibraryController.selectedAsset(
      currentPageAssets,
      selectedAssetId,
    );
  }

  List<AssetVm> get currentPageAssets {
    return AssetLibraryController.pageWindow(
      assets: filteredAssets,
      pageIndex: pageIndex,
      pageSize: pageSize,
    ).pageAssets;
  }

  List<AssetVm> get displayedAssets {
    return AssetLibraryController.displayedAssets(
      baseAssets: widget.assets,
      semanticSearchResults: semanticSearchResults,
      semanticSearchActive: semanticSearchActive,
    );
  }

  List<AssetVm> get selectedBasketAssets {
    return AssetLibraryController.selectedBasketAssets(
      baseAssets: widget.assets,
      semanticSearchResults: semanticSearchResults,
      selectedAssetIds: widget.selectedAssets,
    );
  }

  List<AssetVm> get filteredAssets {
    return AssetLibraryController.filteredAssets(
      assets: displayedAssets,
      query: searchController.text,
      selectedFilterType: selectedFilterType,
      sortMode: selectedSortMode,
      semanticSearchActive: semanticSearchActive,
      typeOptions: widget.typeOptions,
    );
  }
}
