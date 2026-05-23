// ignore_for_file: use_key_in_widget_constructors

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../../../core/sidecar/sidecar_api.dart';
import '../../../shared/widgets/content.dart';
import '../../../../l10n/app_localizations.dart';
import '../asset_library_controller.dart';
import '../asset_library_view_state.dart';
import 'asset_library_panels.dart';
import 'asset_library_filter_status.dart';
import 'asset_library_selection.dart';
import 'asset_library_toolbar.dart';
import 'asset_library_toolbar_controls.dart';

class AssetLibraryMainView extends StatelessWidget {
  const AssetLibraryMainView({
    required this.viewState,
    required this.searchController,
    required this.actions,
    this.onGoToGenerate,
    this.onOpenDirectUpload,
    this.sidecarApi,
    this.onTrustedUploadFinished,
  });

  final AssetLibraryViewState viewState;
  final TextEditingController searchController;
  final AssetLibraryViewActions actions;
  final VoidCallback? onGoToGenerate;
  final VoidCallback? onOpenDirectUpload;
  final SidecarApi? sidecarApi;
  final Future<void> Function()? onTrustedUploadFinished;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return LayoutBuilder(
          builder: (context, paneConstraints) {
            final compactHeight = paneConstraints.maxHeight < 560;
            final gridSection = DropTarget(
              onDragEntered: (_) => actions.onDragEntered(),
              onDragExited: (_) => actions.onDragExited(),
              onDragDone: (detail) {
                actions.onDroppedPaths(
                  detail.files.map((file) => file.path).toList(),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  color: viewState.draggingFiles
                      ? const Color(0xfff2fbf4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: viewState.draggingFiles
                        ? const Color(0xff3f8c55)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: AssetLibraryGridArea(
                  visibleAssets: viewState.visibleAssets,
                  pageAssets: viewState.pageWindow.pageAssets,
                  searchText: searchController.text,
                  semanticSearchActive: viewState.semanticSearchActive,
                  selectedAssets: viewState.selectedAssets,
                  displayType: viewState.displayType,
                  onClearSearch: actions.onClearSearch,
                  onSmartPick: actions.onSmartPick,
                  onImportFiles: actions.onImportFiles,
                  onImportFolder: actions.onImportFolder,
                  onAssetTap: actions.onAssetTap,
                ),
              ),
            );

            final content = Column(
              children: [
                AssetLibraryToolbar(
                  isDemoMode: viewState.isDemoMode,
                  showImportActions: !viewState.isDemoMode,
                  children: viewState.children,
                  selectedChildId: viewState.selectedChildId,
                  searchController: searchController,
                  onSearchChanged: actions.onSearchChanged,
                  onChildChanged: actions.onChildChanged,
                  selectedSortMode: viewState.selectedSortMode,
                  onSortChanged: actions.onSortChanged,
                  semanticSearching: viewState.semanticSearching,
                  refreshingIndex: viewState.refreshingIndex,
                  onSemanticSearch: actions.onSemanticSearch,
                  onRefreshSearchIndexing: actions.onRefreshSearchIndexing,
                  onImportFiles: actions.onImportFiles,
                  onImportFolder: actions.onImportFolder,
                  onSmartPick: actions.onSmartPick,
                  importBusy: viewState.importBusy,
                  onOpenDirectUpload: onOpenDirectUpload,
                  sidecarApi: sidecarApi,
                  onTrustedUploadFinished: onTrustedUploadFinished,
                ),
                if (!viewState.isDemoMode &&
                    viewState.selectedAssets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  AssetLibraryBatchActionBar(
                    selectedCount: viewState.selectedAssets.length,
                    onDeleteSelected: viewState.deleteBusy
                        ? null
                        : actions.onDeleteSelected,
                    onGoToGenerate: onGoToGenerate,
                    onClearSelection: actions.onClearSelection,
                    deleteBusy: viewState.deleteBusy,
                  ),
                ],
                const SizedBox(height: 14),
                AssetLibraryStatusBar(
                  typeOptions: AssetLibraryController.sanitizeTypeOptions(
                    viewState.typeOptions,
                  ),
                  selectedType: viewState.selectedFilterType,
                  counts: viewState.typeCounts,
                  indexingMessage: viewState.indexingMessage,
                  onChanged: actions.onTypeFilterChanged,
                ),
                if (viewState.semanticSearchActive ||
                    viewState.searchStatusMessage.contains(
                      AppLocalizations.of(context)!.uploadStatusFailedLabel,
                    )) ...[
                  const SizedBox(height: 10),
                  AssetLibrarySearchStatusStrip(
                    text: viewState.semanticSearchActive
                        ? AppLocalizations.of(
                            context,
                          )!.assetLibrarySearchResultsStatus(
                            viewState.searchStatusMessage,
                            viewState.semanticSearchResultCount,
                          )
                        : viewState.searchStatusMessage,
                    active: viewState.semanticSearchActive,
                    onClear: viewState.semanticSearchActive
                        ? actions.onClearSearch
                        : null,
                  ),
                ],
                const SizedBox(height: 16),
                compactHeight
                    ? SizedBox(height: 360, child: gridSection)
                    : Expanded(child: gridSection),
                const SizedBox(height: 14),
                if (viewState.visibleAssets.isNotEmpty)
                  PaginationBar(
                    currentPage: viewState.pageWindow.currentPage,
                    totalPages: viewState.pageWindow.totalPages,
                    pageSize: viewState.pageSize,
                    onPrevious: actions.onPreviousPage,
                    onNext: actions.onNextPage,
                  ),
              ],
            );

            if (!compactHeight) return content;
            return SingleChildScrollView(child: content);
          },
        );
      },
    );
  }
}
