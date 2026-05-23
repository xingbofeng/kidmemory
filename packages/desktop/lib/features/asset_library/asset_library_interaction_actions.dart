import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../shared/models/library_models.dart';

import 'asset_library_page.dart';

mixin AssetLibraryInteractionActions on State<AssetLibraryPage> {
  TextEditingController get searchController;
  String? get selectedAssetId;
  set selectedAssetId(String? value);
  String get selectedSortMode;
  set selectedSortMode(String value);
  String get selectedFilterType;
  set selectedFilterType(String value);
  int get pageIndex;
  set pageIndex(int value);
  List<AssetVm> get semanticSearchResults;
  set semanticSearchResults(List<AssetVm> value);
  bool get semanticSearchActive;
  set semanticSearchActive(bool value);
  bool get draggingFiles;
  set draggingFiles(bool value);
  String get searchStatusMessage;
  set searchStatusMessage(String value);

  void syncEditor();
  Future<void> importDroppedPathsWithMessage(List<String> paths);

  void handleSearchChanged() {
    setState(() {
      semanticSearchActive = false;
      semanticSearchResults = const [];
      searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS660;
      pageIndex = 0;
      selectedAssetId = null;
      syncEditor();
    });
  }

  void changeSortMode(String mode) {
    setState(() {
      selectedSortMode = mode;
      pageIndex = 0;
      selectedAssetId = null;
      syncEditor();
    });
  }

  void changeTypeFilter(String type) {
    setState(() {
      selectedFilterType = type;
      pageIndex = 0;
      selectedAssetId = null;
      syncEditor();
    });
  }

  void selectAsset(AssetVm asset) {
    setState(() => selectedAssetId = asset.id);
    syncEditor();
    widget.onToggle(asset.id);
  }

  void goToPreviousPage(int currentPage, int totalPages) {
    setState(() {
      pageIndex = (currentPage - 1).clamp(0, totalPages - 1).toInt();
      selectedAssetId = null;
      syncEditor();
    });
  }

  void goToNextPage(int currentPage, int totalPages) {
    setState(() {
      pageIndex = (currentPage + 1).clamp(0, totalPages - 1).toInt();
      selectedAssetId = null;
      syncEditor();
    });
  }

  void enterDrag() {
    setState(() => draggingFiles = true);
  }

  void exitDrag() {
    setState(() => draggingFiles = false);
  }

  Future<void> dropPaths(List<String> paths) async {
    setState(() => draggingFiles = false);
    await importDroppedPathsWithMessage(paths);
  }
}
