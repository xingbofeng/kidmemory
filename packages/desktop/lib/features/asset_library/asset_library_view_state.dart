import 'package:flutter/foundation.dart';

import '../../shared/models/library_models.dart';

import 'asset_library_controller.dart';
import 'asset_library_display_helpers.dart';

class AssetLibraryViewState {
  const AssetLibraryViewState({
    required this.isDemoMode,
required this.children,
required this.selectedChildId,
required this.selectedSortMode,
required this.semanticSearching,
required this.refreshingIndex,
required this.importBusy,
required this.deleteBusy,
required this.draggingFiles,
required this.typeOptions,
required this.selectedFilterType,
required this.indexingMessage,
required this.semanticSearchActive,
required this.searchStatusMessage,
required this.semanticSearchResultCount,
required this.selectedAssets,
    required this.visibleAssets,
    required this.pageWindow,
    required this.pageSize,
    required this.typeCounts,
    required String Function(String value) displayType,
    required this.selectedChildName,
  }) : _displayType = displayType;

  final bool isDemoMode;
final List<ChildVm> children;
final String? selectedChildId;
final String selectedSortMode;
final bool semanticSearching;
final bool refreshingIndex;
final bool importBusy;
final bool deleteBusy;
final bool draggingFiles;
final List<Map<String, String>> typeOptions;
final String selectedFilterType;
final String indexingMessage;
final bool semanticSearchActive;
final String searchStatusMessage;
final int semanticSearchResultCount;
final Set<String> selectedAssets;
  final List<AssetVm> visibleAssets;
  final AssetLibraryPageWindow pageWindow;
  final int pageSize;
  final Map<String, int> typeCounts;
  final String Function(String value) _displayType;
  final String? selectedChildName;

  String displayType(String value) => _displayType(value);
}

AssetLibraryViewState buildAssetLibraryViewState({
  required List<ChildVm> children,
  required String? selectedChildId,
  required List<AssetVm> assets,
  required List<AssetVm> displayedAssets,
  required List<AssetVm> filteredAssets,
  required List<Map<String, String>> typeOptions,
required String selectedSortMode,
required bool semanticSearching,
required bool refreshingIndex,
required bool importBusy,
required bool deleteBusy,
required bool draggingFiles,
required String selectedFilterType,
required String indexingMessage,
required bool semanticSearchActive,
required String searchStatusMessage,
required int semanticSearchResultCount,
required Set<String> selectedAssets,
  required int pageIndex,
  required int pageSize,
}) {
  final visibleAssets = filteredAssets;
  return AssetLibraryViewState(
    isDemoMode: children.isEmpty && assets.isEmpty,
children: children,
selectedChildId: selectedChildId,
selectedSortMode: selectedSortMode,
semanticSearching: semanticSearching,
refreshingIndex: refreshingIndex,
importBusy: importBusy,
deleteBusy: deleteBusy,
draggingFiles: draggingFiles,
typeOptions: typeOptions,
selectedFilterType: selectedFilterType,
indexingMessage: indexingMessage,
semanticSearchActive: semanticSearchActive,
searchStatusMessage: searchStatusMessage,
semanticSearchResultCount: semanticSearchResultCount,
selectedAssets: selectedAssets,
    visibleAssets: visibleAssets,
    pageWindow: AssetLibraryController.pageWindow(
      assets: visibleAssets,
      pageIndex: pageIndex,
      pageSize: pageSize,
    ),
    pageSize: pageSize,
    typeCounts: assetLibraryTypeCounts(displayedAssets),
    displayType: (value) => assetLibraryDisplayType(typeOptions, value),
    selectedChildName: selectedAssetLibraryChildName(children, selectedChildId),
  );
}

class AssetLibraryViewActions {
  const AssetLibraryViewActions({
    required this.onSearchChanged,
    required this.onChildChanged,
    required this.onSortChanged,
    required this.onSemanticSearch,
    required this.onRefreshSearchIndexing,
    required this.onImportFiles,
    required this.onImportFolder,
    required this.onSmartPick,
    required this.onDeleteSelected,
    required this.onClearSelection,
    required this.onTypeFilterChanged,
    required this.onClearSearch,
    required this.onAssetTap,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onDragEntered,
    required this.onDragExited,
    required this.onDroppedPaths,
  });

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onChildChanged;
  final ValueChanged<String> onSortChanged;
  final Future<void> Function() onSemanticSearch;
  final Future<void> Function() onRefreshSearchIndexing;
  final Future<void> Function() onImportFiles;
  final Future<void> Function() onImportFolder;
  final Future<void> Function() onSmartPick;
  final Future<void> Function()? onDeleteSelected;
  final VoidCallback onClearSelection;
  final ValueChanged<String> onTypeFilterChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<AssetVm> onAssetTap;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final VoidCallback onDragEntered;
  final VoidCallback onDragExited;
  final ValueChanged<List<String>> onDroppedPaths;
}
