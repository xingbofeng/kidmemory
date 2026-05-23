import 'package:flutter/material.dart';

import '../../shared/models/library_models.dart';

import 'asset_library_page.dart';
import 'asset_library_search_feedback.dart';

mixin AssetLibrarySearchActions on State<AssetLibraryPage> {
  TextEditingController get searchController;
  String? get selectedAssetId;
  set selectedAssetId(String? value);
  String get selectedFilterType;
  int get pageIndex;
  set pageIndex(int value);
  List<AssetVm> get semanticSearchResults;
  set semanticSearchResults(List<AssetVm> value);
  bool get semanticSearchActive;
  set semanticSearchActive(bool value);
  bool get semanticSearching;
  set semanticSearching(bool value);
  bool get refreshingIndex;
  set refreshingIndex(bool value);
  String get searchStatusMessage;
  set searchStatusMessage(String value);
  String get indexingMessage;
  set indexingMessage(String value);

  void syncEditor();

  Future<void> runSemanticSearch() async {
    final search = widget.onSemanticSearch;
    final query = searchController.text.trim();
    final childId = widget.selectedChildId;
    if (search == null) {
      setState(
        () => searchStatusMessage = assetLibraryMissingSemanticSearchMessage(context),
      );
      return;
    }
    if (childId == null || childId.isEmpty) {
      setState(
        () => searchStatusMessage = assetLibraryMissingChildMessage(context),
      );
      return;
    }
    if (query.isEmpty) {
      setState(
        () => searchStatusMessage = assetLibraryEmptyQueryMessage(context),
      );
      return;
    }
    setState(() {
      semanticSearching = true;
      semanticSearchActive = true;
      semanticSearchResults = const [];
      selectedAssetId = null;
      pageIndex = 0;
      searchStatusMessage = assetLibrarySemanticSearchingMessage(context);
    });
    try {
      final response = await search(
        AssetSearchInput(
          childId: childId,
          query: query,
          type: selectedFilterType,
        ),
      );
      if (!mounted) return;
      setState(() {
        semanticSearching = false;
        semanticSearchResults = response.assets;
        searchStatusMessage = response.statusMessage;
        selectedAssetId = null;
        pageIndex = 0;
        syncEditor();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        semanticSearching = false;
        semanticSearchActive = false;
        semanticSearchResults = const [];
        searchStatusMessage = assetLibrarySearchFailedMessage(context, error);
      });
    }
  }

  Future<void> refreshSearchIndexingStatus() async {
    final refresh = widget.onRefreshSearchIndexing;
    if (refresh == null) return;
    setState(() => refreshingIndex = true);
    try {
      final message = await refresh();
      if (!mounted) return;
      setState(() {
        refreshingIndex = false;
        indexingMessage = message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        refreshingIndex = false;
        indexingMessage = assetLibraryIndexingRefreshFailedMessage(context);
      });
    }
  }

  void clearSemanticSearch() {
    setState(() {
      semanticSearchActive = false;
      semanticSearchResults = const [];
      selectedAssetId = null;
      pageIndex = 0;
      searchStatusMessage = assetLibraryClearedSearchMessage(context);
      syncEditor();
    });
  }
}
