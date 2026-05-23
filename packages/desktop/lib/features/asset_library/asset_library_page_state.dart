import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../shared/models/library_models.dart';
import '../../shared/widgets/layout.dart';

import 'asset_library_asset_selectors.dart';
import 'asset_library_import_actions.dart';
import 'asset_library_interaction_actions.dart';
import 'asset_library_lifecycle_actions.dart';
import 'asset_library_metadata_actions.dart';
import 'asset_library_page.dart';
import 'asset_library_search_actions.dart';
import 'asset_library_selection_actions.dart';
import 'asset_library_view_state.dart';
import 'asset_library_widgets.dart';

class AssetLibraryPageState extends State<AssetLibraryPage> with AssetLibraryAssetSelectors, AssetLibraryMetadataActions, AssetLibraryLifecycleActions, AssetLibrarySearchActions, AssetLibraryImportActions, AssetLibrarySelectionActions, AssetLibraryInteractionActions {
  @override
  final titleController = TextEditingController();
  @override
  final descriptionController = TextEditingController();
  @override
  final tagsController = TextEditingController();
  @override
  final capturedAtController = TextEditingController();
  @override
  final searchController = TextEditingController();
  @override
  String? selectedAssetId;
  @override
  String typeValue = 'artwork';
  @override
  String capturedAt = '';
  @override
  String selectedFilterType = 'all';
  @override
  String selectedSortMode = 'created_desc';
  @override
  List<AssetVm> semanticSearchResults = const [];
  @override
  bool semanticSearchActive = false;
  @override
  bool semanticSearching = false;
  @override
  bool refreshingIndex = false;
  @override
  String searchStatusMessage = '';
  @override
  String indexingMessage = '';
  @override
  bool draggingFiles = false;
  @override
  bool metadataDirty = false;
  @override
  bool syncingEditor = false;
  @override
  bool importBusy = false;
  @override
  bool deleteBusy = false;
  @override
  int pageIndex = 0;
  bool _localizedDefaultsInitialized = false;

  static const _pageSize = 6;

  @override
  int get pageSize => _pageSize;


  @override
  void initState() {
    super.initState();
    initializeTypeDefaults();
    titleController.addListener(markMetadataDirty);
    descriptionController.addListener(markMetadataDirty);
    tagsController.addListener(markMetadataDirty);
    capturedAtController.addListener(markMetadataDirty);
    syncEditor();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshSearchIndexingStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localizedDefaultsInitialized) return;
    _localizedDefaultsInitialized = true;
    searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS879;
    indexingMessage = AppLocalizations.of(context)!.assetLibraryPageS847;
  }

  @override
  void didUpdateWidget(covariant AssetLibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleWidgetUpdated(oldWidget);
  }


  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    capturedAtController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewState = buildAssetLibraryViewState(
      children: widget.children,
      selectedChildId: widget.selectedChildId,
      assets: widget.assets,
      displayedAssets: displayedAssets,
      filteredAssets: filteredAssets,
      typeOptions: widget.typeOptions,
      selectedSortMode: selectedSortMode,
      semanticSearching: semanticSearching,
      refreshingIndex: refreshingIndex,
      importBusy: importBusy,
      deleteBusy: deleteBusy,
      draggingFiles: draggingFiles,
      selectedFilterType: selectedFilterType,
      indexingMessage: indexingMessage,
      semanticSearchActive: semanticSearchActive,
      searchStatusMessage: searchStatusMessage,
      semanticSearchResultCount: semanticSearchResults.length,
      selectedAssets: widget.selectedAssets,
      pageIndex: pageIndex,
      pageSize: pageSize,
    );
    final l10n = AppLocalizations.of(context)!;
    return PageFrame(
      title: l10n.assetLibraryTitle,
      subtitle: l10n.assetLibrarySubtitle(
        viewState.selectedChildName ?? l10n.assetLibraryPageS599,
      ),
      status: AssetLibraryHeaderStatus(
        childName:
            viewState.selectedChildName ??
            AppLocalizations.of(context)!.assetLibraryPageS599,
        assetCount: widget.assets.length,
        indexingMessage: viewState.indexingMessage,
      ),
      child: AssetLibraryMainView(
        viewState: viewState,
        searchController: searchController,
        actions: AssetLibraryViewActions(
          onSearchChanged: (_) => handleSearchChanged(),
          onChildChanged: widget.onChildChanged,
          onSortChanged: changeSortMode,
          onSemanticSearch: runSemanticSearch,
          onRefreshSearchIndexing: refreshSearchIndexingStatus,
          onImportFiles: importFilesWithMessage,
          onImportFolder: importFolderWithMessage,
          onSmartPick: showSmartPickDialog,
          onDeleteSelected: deleteSelectedWithConfirmation,
          onClearSelection: clearSelectedAssets,
          onTypeFilterChanged: changeTypeFilter,
          onClearSearch: () {
            searchController.clear();
            clearSemanticSearch();
          },
          onAssetTap: selectAsset,
          onPreviousPage: () => goToPreviousPage(
            viewState.pageWindow.currentPage,
            viewState.pageWindow.totalPages,
          ),
          onNextPage: () => goToNextPage(
            viewState.pageWindow.currentPage,
            viewState.pageWindow.totalPages,
          ),
          onDragEntered: enterDrag,
          onDragExited: exitDrag,
          onDroppedPaths: dropPaths,
        ),
        onGoToGenerate: widget.onGoToGenerate,
        onOpenDirectUpload: widget.onOpenDirectUpload,
        sidecarApi: widget.sidecarApi,
        onTrustedUploadFinished: widget.onTrustedUploadFinished,
      ),
    );
  }



}
