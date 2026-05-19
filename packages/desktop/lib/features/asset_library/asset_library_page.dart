import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/chrome.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/layout.dart';
import '../../shared/widgets/status.dart';
import '../../shared/models/library_models.dart';
import '../web_companion/direct_upload/direct_upload_entry.dart';
import '../web_companion/trusted_upload/trusted_upload_entry.dart';
import '../../core/sidecar/sidecar_api.dart';
import '../../../l10n/app_localizations.dart';

part 'asset_library_widgets.dart';
part 'asset_library_state.dart';

List<Map<String, String>> _assetSortOptions(BuildContext context) => [
  {'value': 'created_desc', 'label': AppLocalizations.of(context)!.assetLibraryPageS285},
  {'value': 'created_asc', 'label': AppLocalizations.of(context)!.assetLibraryPageS286},
  {'value': 'type', 'label': AppLocalizations.of(context)!.assetLibraryPageS786},
  {'value': 'title', 'label': AppLocalizations.of(context)!.assetLibraryPageS631},
];

class AssetImportReport {
  const AssetImportReport({
    required this.imported,
    required this.duplicates,
    required this.failed,
    required this.skipped,
    this.message = '',
    this.title = '',
  });

  final int imported;
  final int duplicates;
  final int failed;
  final int skipped;
  final String message;
  final String title;
}

class AssetMetadataUpdate {
  const AssetMetadataUpdate({
    required this.title,
    required this.description,
    required this.tags,
    required this.capturedAt,
    required this.type,
  });

  final String title;
  final String description;
  final List<String> tags;
  final String? capturedAt;
  final String type;

  Map<String, dynamic> toPayload() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'capturedAt': capturedAt,
      'type': type,
    };
  }
}

class AssetLibraryPage extends StatefulWidget {
  const AssetLibraryPage({
    required this.children,
    required this.selectedChildId,
    required this.assets,
    required this.typeOptions,
    required this.selectedAssets,
    required this.onChildChanged,
    required this.onToggle,
    this.onReplaceSelectedAssets,
    required this.onUpdateAsset,
    required this.onDeleteAsset,
    required this.onDeleteSelected,
    required this.onImportFiles,
    required this.onImportFolder,
    this.onImportDroppedPaths,
    this.onSemanticSearch,
    this.onRefreshSearchIndexing,
    this.onGoToGenerate,
    this.onSyncAsset,
    this.onOpenDirectUpload,
    this.sidecarApi,
    this.onTrustedUploadFinished,
    super.key,
  });

  final List<ChildVm> children;
  final String? selectedChildId;
  final List<AssetVm> assets;
  final List<Map<String, String>> typeOptions;
  final Set<String> selectedAssets;
  final ValueChanged<String> onChildChanged;
  final ValueChanged<String> onToggle;
  final ValueChanged<Set<String>>? onReplaceSelectedAssets;
  final Future<bool> Function(String id, AssetMetadataUpdate payload)
  onUpdateAsset;
  final Future<bool> Function(String id) onDeleteAsset;
  final Future<int> Function() onDeleteSelected;
  final Future<AssetImportReport> Function() onImportFiles;
  final Future<AssetImportReport> Function() onImportFolder;
  final Future<AssetImportReport> Function(List<String> paths)?
  onImportDroppedPaths;
  final Future<AssetSearchResult> Function(AssetSearchInput request)?
  onSemanticSearch;
  final Future<String> Function()? onRefreshSearchIndexing;
  final VoidCallback? onGoToGenerate;
  final Future<bool> Function(String assetId)? onSyncAsset;

  /// Optional Web Companion Direct Upload entry. When provided, the
  /// asset library toolbar surfaces a dedicated 「扫码上传 · Direct」
  /// button next to the existing import actions. Leaving this `null` keeps
  /// the toolbar identical to the standard import-only behavior.
  final VoidCallback? onOpenDirectUpload;

  /// Optional SidecarApi for Trusted Upload. When provided, enables the
  /// trusted upload entry button in the toolbar.
  final SidecarApi? sidecarApi;
  final Future<void> Function()? onTrustedUploadFinished;

  @override
  State<AssetLibraryPage> createState() => _AssetLibraryPageState();
}

class _AssetLibraryPageState extends State<AssetLibraryPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final tagsController = TextEditingController();
  final capturedAtController = TextEditingController();
  final searchController = TextEditingController();
  String? selectedAssetId;
  String typeValue = 'artwork';
  String capturedAt = '';
  String selectedFilterType = 'all';
  String selectedSortMode = 'created_desc';
  List<AssetVm> semanticSearchResults = const [];
  bool semanticSearchActive = false;
  bool semanticSearching = false;
  bool refreshingIndex = false;
  String searchStatusMessage = '';
  String indexingMessage = '';
  bool draggingFiles = false;
  bool metadataDirty = false;
  bool savingMetadata = false;
  bool syncingEditor = false;
  bool importBusy = false;
  bool deleteBusy = false;
  bool inspectorCollapsed = false;
  int pageIndex = 0;
  bool _localizedDefaultsInitialized = false;

  static const _pageSize = 6;

  AssetVm? get selectedAsset {
    return _AssetLibraryController.selectedAsset(
      currentPageAssets,
      selectedAssetId,
    );
  }

  List<AssetVm> get currentPageAssets {
    return _AssetLibraryController.pageWindow(
      assets: filteredAssets,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    ).pageAssets;
  }

  List<AssetVm> get displayedAssets {
    return _AssetLibraryController.displayedAssets(
      baseAssets: widget.assets,
      semanticSearchResults: semanticSearchResults,
      semanticSearchActive: semanticSearchActive,
    );
  }

  List<AssetVm> get selectedBasketAssets {
    return _AssetLibraryController.selectedBasketAssets(
      baseAssets: widget.assets,
      semanticSearchResults: semanticSearchResults,
      selectedAssetIds: widget.selectedAssets,
    );
  }

  List<AssetVm> get filteredAssets {
    return _AssetLibraryController.filteredAssets(
      assets: displayedAssets,
      query: searchController.text,
      selectedFilterType: selectedFilterType,
      sortMode: selectedSortMode,
      semanticSearchActive: semanticSearchActive,
      typeOptions: widget.typeOptions,
    );
  }

  @override
  void initState() {
    super.initState();
    typeValue = _containsType(widget.typeOptions, typeValue)
        ? typeValue
        : _defaultTypeFromOptions(widget.typeOptions);
    selectedFilterType = _containsType(widget.typeOptions, selectedFilterType)
        ? selectedFilterType
        : _defaultTypeFromOptions(widget.typeOptions);
    titleController.addListener(_markMetadataDirty);
    descriptionController.addListener(_markMetadataDirty);
    tagsController.addListener(_markMetadataDirty);
    capturedAtController.addListener(_markMetadataDirty);
    _syncEditor();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSearchIndexingStatus();
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
    if (oldWidget.typeOptions != widget.typeOptions) {
      final defaultType = _defaultTypeFromOptions(widget.typeOptions);
      if (!_containsType(widget.typeOptions, typeValue)) {
        typeValue = defaultType;
      }
      if (!_containsType(widget.typeOptions, selectedFilterType)) {
        selectedFilterType = defaultType;
      }
      _syncEditor();
    }
    if (oldWidget.selectedChildId != widget.selectedChildId) {
      semanticSearchActive = false;
      semanticSearchResults = const [];
      searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS433;
      _refreshSearchIndexingStatus();
    }
    if (oldWidget.assets != widget.assets) _syncEditor();
  }

  void _syncEditor() {
    syncingEditor = true;
    metadataDirty = false;
    final asset = selectedAsset;
    titleController.text = asset?.title ?? '';
    descriptionController.text = asset?.description ?? '';
    tagsController.text = asset?.tags.join(', ') ?? '';
    final assetType =
        asset?.type ?? _defaultTypeFromOptions(widget.typeOptions);
    typeValue = _containsType(widget.typeOptions, assetType)
        ? assetType
        : _defaultTypeFromOptions(widget.typeOptions);
    capturedAt = asset?.capturedAt ?? '';
    capturedAtController.text = capturedAt;
    syncingEditor = false;
  }

  void _markMetadataDirty() {
    if (syncingEditor) return;
    if (selectedAsset == null || metadataDirty) return;
    setState(() => metadataDirty = true);
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
    final isDemoMode = widget.children.isEmpty && widget.assets.isEmpty;
    final visibleAssets = filteredAssets;
    final pageWindow = _AssetLibraryController.pageWindow(
      assets: visibleAssets,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
    final selectedChildName = _selectedChildName();
    final totalPages = pageWindow.totalPages;
    final currentPage = pageWindow.currentPage;
    final pageAssets = pageWindow.pageAssets;
    return PageFrame(
      title: AppLocalizations.of(context)!.assetLibraryTitle,
      subtitle:
          '管理${selectedChildName ?? '孩子'}的照片、绘画和手工作品。选择素材后可以生成绘本、回忆视频或成长纪念册。',
      status: _LibraryHeaderStatus(
        childName: selectedChildName ?? AppLocalizations.of(context)!.assetLibraryPageS599,
        assetCount: widget.assets.length,
        indexingMessage: indexingMessage,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mainPane = LayoutBuilder(
            builder: (context, paneConstraints) {
              final compactHeight = paneConstraints.maxHeight < 560;
              final gridSection = DropTarget(
                onDragEntered: (_) => setState(() => draggingFiles = true),
                onDragExited: (_) => setState(() => draggingFiles = false),
                onDragDone: (detail) async {
                  setState(() => draggingFiles = false);
                  await _importDroppedPathsWithMessage(
                    detail.files.map((file) => file.path).toList(),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: draggingFiles
                        ? const Color(0xfff2fbf4)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: draggingFiles
                          ? const Color(0xff3f8c55)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: _buildAssetGridArea(visibleAssets, pageAssets),
                ),
              );

              final content = Column(
                children: [
                  _LibraryToolbar(
                    isDemoMode: isDemoMode,
                    showImportActions: !isDemoMode,
                    children: widget.children,
                    selectedChildId: widget.selectedChildId,
                    searchController: searchController,
                    onSearchChanged: (_) => setState(() {
                      semanticSearchActive = false;
                      semanticSearchResults = const [];
                      searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS660;
                      pageIndex = 0;
                      selectedAssetId = null;
                      _syncEditor();
                    }),
                    onChildChanged: widget.onChildChanged,
                    selectedSortMode: selectedSortMode,
                    onSortChanged: (mode) => setState(() {
                      selectedSortMode = mode;
                      pageIndex = 0;
                      selectedAssetId = null;
                      _syncEditor();
                    }),
                    semanticSearching: semanticSearching,
                    refreshingIndex: refreshingIndex,
                    onSemanticSearch: _runSemanticSearch,
                    onRefreshSearchIndexing: _refreshSearchIndexingStatus,
                    onImportFiles: _importFilesWithMessage,
                    onImportFolder: _importFolderWithMessage,
                    onSmartPick: _showSmartPickDialog,
                    importBusy: importBusy,
                    onOpenDirectUpload: widget.onOpenDirectUpload,
                    sidecarApi: widget.sidecarApi,
                    onTrustedUploadFinished: widget.onTrustedUploadFinished,
                  ),
                  if (!isDemoMode && widget.selectedAssets.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _BatchActionBar(
                      selectedCount: widget.selectedAssets.length,
                      onDeleteSelected: deleteBusy
                          ? null
                          : _deleteSelectedWithConfirmation,
                      onGoToGenerate: widget.onGoToGenerate,
                      onClearSelection: _clearSelectedAssets,
                      deleteBusy: deleteBusy,
                    ),
                  ],
                  const SizedBox(height: 14),
                  _AssetStatusBar(
                    typeOptions: _sanitizeTypeOptions(widget.typeOptions),
                    selectedType: selectedFilterType,
                    counts: _typeCounts(displayedAssets),
                    indexingMessage: indexingMessage,
                    onChanged: (type) => setState(() {
                      selectedFilterType = type;
                      pageIndex = 0;
                      selectedAssetId = null;
                      _syncEditor();
                    }),
                  ),
                  if (semanticSearchActive ||
                      searchStatusMessage.contains(AppLocalizations.of(context)!.uploadStatusFailedLabel)) ...[
                    const SizedBox(height: 10),
                    _SearchStatusStrip(
                      text: semanticSearchActive
                          ? '$searchStatusMessage · 结果 ${semanticSearchResults.length} 项'
                          : searchStatusMessage,
                      active: semanticSearchActive,
                      onClear: semanticSearchActive
                          ? _clearSemanticSearch
                          : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  compactHeight
                      ? SizedBox(height: 360, child: gridSection)
                      : Expanded(child: gridSection),
                  const SizedBox(height: 14),
                  if (visibleAssets.isNotEmpty)
                    PaginationBar(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      pageSize: _pageSize,
                      onPrevious: () => setState(() {
                        pageIndex = (currentPage - 1)
                            .clamp(0, totalPages - 1)
                            .toInt();
                        selectedAssetId = null;
                        _syncEditor();
                      }),
                      onNext: () => setState(() {
                        pageIndex = (currentPage + 1)
                            .clamp(0, totalPages - 1)
                            .toInt();
                        selectedAssetId = null;
                        _syncEditor();
                      }),
                    ),
                ],
              );

              if (!compactHeight) return content;
              return SingleChildScrollView(child: content);
            },
          );

          return mainPane;
        },
      ),
    );
  }

  String? _selectedChildName() {
    final id = widget.selectedChildId;
    if (id == null) {
      return widget.children.isEmpty ? null : widget.children.first.name;
    }
    for (final child in widget.children) {
      if (child.id == id) return child.name;
    }
    return widget.children.isEmpty ? null : widget.children.first.name;
  }

  Map<String, int> _typeCounts(List<AssetVm> assets) {
    final counts = <String, int>{'all': assets.length};
    for (final asset in assets) {
      counts[asset.type] = (counts[asset.type] ?? 0) + 1;
    }
    return counts;
  }

  Widget _buildAssetGridArea(
    List<AssetVm> visibleAssets,
    List<AssetVm> pageAssets,
  ) {
    if (visibleAssets.isEmpty) {
      final hasQuery =
          searchController.text.trim().isNotEmpty || semanticSearchActive;
      if (hasQuery) {
        return _EmptySearchResults(
          onClearSearch: () {
            searchController.clear();
            _clearSemanticSearch();
          },
          onSmartPick: _showSmartPickDialog,
        );
      }
      return EmptyAssetLibrary(
        onImportFiles: _importFilesWithMessage,
        onImportFolder: _importFolderWithMessage,
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
                _displayType(asset.type),
                asset.icon,
                asset.capturedAt,
                asset.tags,
                imagePath: asset.imagePath,
                thumbnailPath: asset.thumbnailPath,
                previewUrl: asset.previewUrl,
                matchReasons: asset.matchReasons,
              ),
              selected: widget.selectedAssets.contains(asset.id),
              onTap: () {
                setState(() => selectedAssetId = asset.id);
                _syncEditor();
                widget.onToggle(asset.id);
              },
            );
          },
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildInspector(AssetVm? detailAsset) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: detailAsset == null
          ? _InspectorEmptyState(onSmartPick: _showSmartPickDialog)
          : (!semanticSearchActive && widget.assets.isEmpty
                ? _buildDemoDetail(detailAsset)
                : _buildEditableDetail(detailAsset)),
    );
  }

  void _clearSelectedAssets() {
    final replace = widget.onReplaceSelectedAssets;
    if (replace != null) {
      replace(<String>{});
      return;
    }
    for (final id in widget.selectedAssets.toList()) {
      widget.onToggle(id);
    }
  }

  String _displayType(String value) {
    return _AssetLibraryController.displayType(widget.typeOptions, value);
  }

  bool _containsType(List<Map<String, String>> options, String value) {
    return _AssetLibraryController.containsType(options, value);
  }

  String _defaultTypeFromOptions(List<Map<String, String>> options) {
    return _AssetLibraryController.defaultTypeFromOptions(options);
  }

  List<Map<String, String>> _sanitizeTypeOptions(
    List<Map<String, String>> options,
  ) {
    return _AssetLibraryController.sanitizeTypeOptions(options);
  }

  Future<void> _runSemanticSearch() async {
    final search = widget.onSemanticSearch;
    final query = searchController.text.trim();
    final childId = widget.selectedChildId;
    if (search == null) {
      setState(() => searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS483);
      return;
    }
    if (childId == null || childId.isEmpty) {
      setState(() => searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS858);
      return;
    }
    if (query.isEmpty) {
      setState(() => searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS867);
      return;
    }
    setState(() {
      semanticSearching = true;
      semanticSearchActive = true;
      semanticSearchResults = const [];
      selectedAssetId = null;
      pageIndex = 0;
      searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS665;
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
        _syncEditor();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        semanticSearching = false;
        semanticSearchActive = false;
        semanticSearchResults = const [];
        searchStatusMessage = '搜索失败：$error';
      });
    }
  }

  Future<void> _refreshSearchIndexingStatus() async {
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
        indexingMessage = AppLocalizations.of(context)!.assetLibraryPageS825;
      });
    }
  }

  void _clearSemanticSearch() {
    setState(() {
      semanticSearchActive = false;
      semanticSearchResults = const [];
      selectedAssetId = null;
      pageIndex = 0;
      searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS440;
      _syncEditor();
    });
  }

  Future<void> _showSmartPickDialog() async {
    if (displayedAssets.isEmpty) {
      AppToast.show(
        context,
        title: AppLocalizations.of(context)!.assetLibraryPageS572,
        message: AppLocalizations.of(context)!.assetLibraryPageS481,
        tone: AppToastTone.info,
      );
      return;
    }

    var target = 'picture_book';
    var seed = DateTime.now().millisecondsSinceEpoch;
    List<AssetVm> suggested = _buildSmartSuggestion(
      assets: displayedAssets,
      target: target,
      seed: seed,
    );

    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.assetLibrarySmartPickLabel)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.assetLibraryPageS869)),
                  const SizedBox(height: 8),
                  RadioGroup<String>(
                    groupValue: target,
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        target = value;
                        seed = DateTime.now().millisecondsSinceEpoch;
                        suggested = _buildSmartSuggestion(
                          assets: displayedAssets,
                          target: target,
                          seed: seed,
                        );
                      });
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'picture_book',
                          title: Text(AppLocalizations.of(context)!.assetLibraryPageS902),
                          dense: true,
                        ),
                        RadioListTile<String>(
                          value: 'memory_album',
                          title: Text(AppLocalizations.of(context)!.assetLibraryPageS901),
                          dense: true,
                        ),
                        RadioListTile<String>(
                          value: 'memory_video',
                          title: Text(AppLocalizations.of(context)!.assetLibraryPageS900),
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('智能助手已为你挑选 ${suggested.length} 张素材'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop('manual'),
                  child: Text(AppLocalizations.of(context)!.assetLibraryPageS503)),
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      seed = DateTime.now().millisecondsSinceEpoch;
                      suggested = _buildSmartSuggestion(
                        assets: displayedAssets,
                        target: target,
                        seed: seed,
                      );
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.assetLibraryPageS919)),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop('confirm'),
                  child: Text(AppLocalizations.of(context)!.assetLibraryPageS765)),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'confirm') {
      final next = suggested.map((asset) => asset.id).toSet();
      final replace = widget.onReplaceSelectedAssets;
      if (replace != null) {
        replace(next);
      } else {
        for (final id in widget.selectedAssets.toList()) {
          if (!next.contains(id)) {
            widget.onToggle(id);
          }
        }
        for (final id in next) {
          if (!widget.selectedAssets.contains(id)) {
            widget.onToggle(id);
          }
        }
      }
      setState(() {
        selectedAssetId = next.isEmpty ? null : next.first;
      });
      _syncEditor();
      AppToast.show(
        context,
        title: AppLocalizations.of(context)!.assetLibraryPageS564,
        message: '已选 ${next.length} 张素材，可继续手动微调。',
        tone: AppToastTone.success,
      );
      return;
    }

    if (action == 'manual') {
      AppToast.show(
        context,
        title: AppLocalizations.of(context)!.assetLibraryPageS430,
        message: AppLocalizations.of(context)!.assetLibraryPageS235,
        tone: AppToastTone.info,
      );
    }
  }

  List<AssetVm> _buildSmartSuggestion({
    required List<AssetVm> assets,
    required String target,
    required int seed,
  }) {
    final sorted = [...assets];

    switch (target) {
      case 'memory_video':
        sorted.sort((a, b) {
          final scoreA = _smartAssetScore(a, preferPhoto: true);
          final scoreB = _smartAssetScore(b, preferPhoto: true);
          return scoreB.compareTo(scoreA);
        });
        break;
      case 'memory_album':
        sorted.sort((a, b) {
          final scoreA = _smartAssetScore(a, preferCraft: true);
          final scoreB = _smartAssetScore(b, preferCraft: true);
          return scoreB.compareTo(scoreA);
        });
        break;
      case 'picture_book':
      default:
        sorted.sort((a, b) {
          final scoreA = _smartAssetScore(a, preferArtwork: true);
          final scoreB = _smartAssetScore(b, preferArtwork: true);
          return scoreB.compareTo(scoreA);
        });
        break;
    }

    if (sorted.length > 1) {
      final shift = seed % sorted.length;
      final rotated = [...sorted.skip(shift), ...sorted.take(shift)];
      return rotated.take(12).toList();
    }
    return sorted.take(12).toList();
  }

  int _smartAssetScore(
    AssetVm asset, {
    bool preferArtwork = false,
    bool preferPhoto = false,
    bool preferCraft = false,
  }) {
    var score = 0;
    if (preferArtwork && asset.type == 'artwork') score += 4;
    if (preferPhoto && asset.type == 'photo') score += 4;
    if (preferCraft && asset.type == 'craft') score += 4;
    if (asset.tags.isNotEmpty) score += 2;
    if (asset.description.trim().isNotEmpty) score += 1;
    if (asset.capturedAt.trim().isNotEmpty) score += 1;
    return score;
  }

  Future<void> _importFilesWithMessage() async {
    await _runImportWithMessage(widget.onImportFiles);
  }

  Future<void> _importFolderWithMessage() async {
    await _runImportWithMessage(widget.onImportFolder);
  }

  Future<void> _runImportWithMessage(
    Future<AssetImportReport> Function() action,
  ) async {
    setState(() => importBusy = true);
    try {
      final report = await action();
      if (!mounted) return;
      _showImportToast(report);
    } catch (error) {
      if (!mounted) return;
      _showImportToast(
        AssetImportReport(
          imported: 0,
          duplicates: 0,
          skipped: 0,
          failed: 1,
          message: '导入失败：$error',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => importBusy = false);
      }
    }
  }

  Future<void> _importDroppedPathsWithMessage(List<String> paths) async {
    if (paths.isEmpty) return;
    final report =
        await (widget.onImportDroppedPaths?.call(paths) ??
            Future.value(
              AssetImportReport(
                imported: 0,
                duplicates: 0,
                failed: paths.length,
                skipped: 0,
                message: AppLocalizations.of(context)!.assetLibraryPageS531,
              ),
            ));
    if (!mounted) return;
    _showImportToast(report);
  }

  void _showImportToast(AssetImportReport report) {
    final imported = report.imported;
    final duplicates = report.duplicates;
    final failed = report.failed;
    final skipped = report.skipped;
    final message = report.message.isNotEmpty
        ? report.message
        : '成功 $imported · 重复 $duplicates · 跳过 $skipped · 失败 $failed';
    final title =
        (report.title.isNotEmpty ? report.title : null) ??
        (report.failed > 0
            ? (report.imported > 0 ? AppLocalizations.of(context)!.assetLibraryPageS403 : AppLocalizations.of(context)!.sampleDatasetImportFailedTitle)
            : report.imported > 0
            ? AppLocalizations.of(context)!.assetLibraryPageS392
            : AppLocalizations.of(context)!.assetLibraryPageS581);
    final tone = report.failed > 0
        ? AppToastTone.error
        : report.imported > 0
        ? AppToastTone.success
        : AppToastTone.info;
    AppToast.show(context, title: title, message: message, tone: tone);
  }

  Future<void> _deleteSelectedWithConfirmation() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.assetLibraryPageS767)),
            content: Text('将删除已选 ${widget.selectedAssets.length} 项素材，是否继续？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(AppLocalizations.of(context)!.actionCancel)),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(AppLocalizations.of(context)!.assetLibraryPageS296)),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    setState(() => deleteBusy = true);
    try {
      final deletedCount = await widget.onDeleteSelected();
      if (!mounted) return;
      AppToast.show(
        context,
        message: '已删除 $deletedCount 项素材',
        tone: AppToastTone.success,
      );
    } finally {
      if (mounted) {
        setState(() => deleteBusy = false);
      }
    }
  }

  Widget _buildDemoDetail(AssetVm detailAsset) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetArtworkPreview(
            path: detailAsset.previewPath,
            fallbackIcon: detailAsset.icon,
            label: detailAsset.title,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  detailAsset.title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Chip(label: Text(_displayType(detailAsset.type))),
            ],
          ),
          const SizedBox(height: 12),
          Text(detailAsset.description),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context)!.contentTagLabel), style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detailAsset.tags
                .map((tag) => Chip(label: Text(tag)))
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context)!.assetLibraryPageS619), style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SourceRow(
            icon: Icons.calendar_month,
            iconAsset: timeIconAsset,
            label: AppLocalizations.of(context)!.assetLibraryPageS284,
            value: detailAsset.capturedAt,
          ),
          SourceRow(
            icon: Icons.person_outline,
            iconAsset: userIconAsset,
            label: AppLocalizations.of(context)!.assetLibraryPageS289,
            value: AppLocalizations.of(context)!.assetLibraryPageS782,
          ),
          SourceRow(
            icon: Icons.devices_other,
            iconAsset: bearHeadIconAsset,
            label: AppLocalizations.of(context)!.assetLibraryPageS620,
            value: AppLocalizations.of(context)!.assetLibraryPageS268,
          ),
          SourceRow(
            icon: Icons.folder_outlined,
            iconAsset: folderIconAsset,
            label: AppLocalizations.of(context)!.assetLibraryPageS368,
            value: AppLocalizations.of(context)!.assetLibraryPageS784,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: widget.selectedAssets.contains(detailAsset.id)
                ? AppLocalizations.of(context)!.assetLibraryPageS225
                : AppLocalizations.of(context)!.assetLibraryPageS308,
            iconAsset: widget.selectedAssets.contains(detailAsset.id)
                ? deleteIconAsset
                : addIconAsset,
            onPressed: () => widget.onToggle(detailAsset.id),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppLocalizations.of(context)!.assetLibraryPageS221,
              style: TextStyle(color: Color(0xff6f8d72), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableDetail(AssetVm detailAsset) {
    final displayTitle = _displayAssetTitle(detailAsset);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: AssetArtworkPreview(
                    path: detailAsset.previewPath,
                    fallbackIcon: detailAsset.icon,
                    fallbackAssetPath: _assetIconAsset(detailAsset.type),
                    label: '',
                    height: double.infinity,
                    width: double.infinity,
                    fit: detailAsset.previewPath.isEmpty
                        ? BoxFit.contain
                        : BoxFit.cover,
                    borderRadius: BorderRadius.circular(16),
                    borderColor: const Color(0xffe8dccb),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff2d241c),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _TypePill(
                      label: _displayType(detailAsset.type),
                      type: detailAsset.type,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _formatChineseDate(detailAsset.capturedAt),
                  style: const TextStyle(
                    color: _AssetLibraryPalette.bodyMuted,
                    fontSize: 13,
                  ),
                ),
                if (metadataDirty) ...[
                  const SizedBox(height: 10),
                  _SoftStatusChip(
                    icon: Icons.edit_outlined,
                    text: AppLocalizations.of(context)!.assetLibraryPageS575,
                  ),
                ],
                const SizedBox(height: 18),
                TextField(
                  controller: titleController,
                  decoration: _fieldDecoration(AppLocalizations.of(context)!.assetLibraryPageS630, hint: AppLocalizations.of(context)!.assetLibraryPageS242),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: typeValue,
                  items: _sanitizeTypeOptions(widget.typeOptions)
                      .where((option) => option['value'] != 'all')
                      .map(
                        (option) => DropdownMenuItem(
                          value: option['value'],
                          child: Text(option['label'] ?? option['value'] ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    typeValue =
                        value ?? _defaultTypeFromOptions(widget.typeOptions);
                    metadataDirty = true;
                  }),
                  decoration: _fieldDecoration(AppLocalizations.of(context)!.assetLibraryPageS806),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capturedAtController,
                  onChanged: (value) => capturedAt = value,
                  decoration: _fieldDecoration(
                    AppLocalizations.of(context)!.assetLibraryPageS558,
                    hint: AppLocalizations.of(context)!.assetLibraryPageS95,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  decoration: _fieldDecoration(AppLocalizations.of(context)!.contentTagLabel, hint: AppLocalizations.of(context)!.assetLibraryPageS498),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: _fieldDecoration(AppLocalizations.of(context)!.assetLibraryPageS535, hint: AppLocalizations.of(context)!.assetLibraryPageS843),
                ),
                const SizedBox(height: 18),
                Text(AppLocalizations.of(context)!.generateExportS708), style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                SourceRow(
                  icon: Icons.cloud_done_outlined,
                  iconAsset: cloudUploadIconAsset,
                  label: AppLocalizations.of(context)!.assetLibraryPageS614,
                  value: _storageStatusLabel(detailAsset.storageStatus),
                ),
                SourceRow(
                  icon: Icons.manage_search_rounded,
                  label: AppLocalizations.of(context)!.assetLibraryPageS824,
                  value: indexingMessage,
                ),
                if (widget.onSyncAsset != null) ...[
                  const SizedBox(height: 4),
                  _AssetStorageAction(
                    status: detailAsset.storageStatus,
                    onPressed: () => _syncAsset(detailAsset.id),
                  ),
                ],
                const SizedBox(height: 12),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: Text(
                    AppLocalizations.of(context)!.assetLibraryPageS528,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  children: [
                    SourceRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'Asset ID',
                      value: detailAsset.id,
                    ),
                    SourceRow(
                      icon: Icons.image_outlined,
                      iconAsset: imageFileIconAsset,
                      label: AppLocalizations.of(context)!.assetLibraryPageS316,
                      value: detailAsset.originalFilename.isEmpty
                          ? AppLocalizations.of(context)!.assetLibraryPageS615
                          : detailAsset.originalFilename,
                    ),
                    SourceRow(
                      icon: Icons.folder_outlined,
                      iconAsset: folderIconAsset,
                      label: AppLocalizations.of(context)!.assetLibraryPageS616,
                      value: detailAsset.imagePath.isEmpty
                          ? AppLocalizations.of(context)!.assetLibraryPageS597
                          : detailAsset.imagePath,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SelectionBasket(
                  selectedAssets: selectedBasketAssets,
                  selectedCount: widget.selectedAssets.length,
                  onGoToGenerate: widget.onGoToGenerate,
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xfffffcf7),
            border: Border(top: BorderSide(color: Color(0xffe8dccb))),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: savingMetadata ? AppLocalizations.of(context)!.assetLibraryPageS246 : AppLocalizations.of(context)!.assetLibraryPageS247,
                      iconAsset: completeIconAsset,
                      height: 46,
                      onPressed: savingMetadata
                          ? null
                          : () => _saveMetadata(detailAsset),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SecondaryButton(
                      label: AppLocalizations.of(context)!.assetLibraryPageS546,
                      height: 46,
                      onPressed: metadataDirty
                          ? () => setState(_syncEditor)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: AppLocalizations.of(context)!.assetLibraryPageS516,
                      icon: Icons.open_in_new_rounded,
                      height: 42,
                      onPressed: detailAsset.imagePath.isEmpty
                          ? null
                          : () => _openOriginalFile(detailAsset),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SecondaryButton(
                      label: AppLocalizations.of(context)!.assetLibraryPageS304,
                      iconAsset: deleteIconAsset,
                      height: 42,
                      onPressed: () => _confirmDeleteAsset(detailAsset),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: widget.selectedAssets.contains(detailAsset.id)
                    ? AppLocalizations.of(context)!.assetLibraryPageS225
                    : AppLocalizations.of(context)!.assetLibraryPageS308,
                iconAsset: widget.selectedAssets.contains(detailAsset.id)
                    ? deleteIconAsset
                    : addIconAsset,
                height: 42,
                onPressed: () => widget.onToggle(detailAsset.id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    const borderColor = Color(0xffeadbc9);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xfffffbf5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff2faa61), width: 1.4),
      ),
    );
  }

  String _displayAssetTitle(AssetVm asset) {
    final title = asset.title.trim();
    final technicalId = RegExp(r'^(cld|asset)[-_]?\w+', caseSensitive: false);
    if (title.isNotEmpty && !technicalId.hasMatch(title)) return title;
    return switch (asset.type) {
      'photo' => AppLocalizations.of(context)!.contentUnnamedPhotoLabel,
      'craft' => AppLocalizations.of(context)!.contentUnnamedCraftLabel,
      _ => AppLocalizations.of(context)!.contentUnnamedDrawingLabel,
    };
  }

  String _formatChineseDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.trim().isEmpty ? AppLocalizations.of(context)!.contentDateMissingLabel : value;
    final local = parsed.toLocal();
    return '${local.year}年${local.month}月${local.day}日';
  }

  Future<void> _saveMetadata(AssetVm detailAsset) async {
    setState(() => savingMetadata = true);
    final ok = await widget.onUpdateAsset(
      detailAsset.id,
      AssetMetadataUpdate(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        tags: tagsController.text
            .split(',')
            .map((v) => v.trim())
            .where((v) => v.isNotEmpty)
            .toList(),
        capturedAt: capturedAtController.text.trim().isEmpty
            ? null
            : capturedAtController.text.trim(),
        type: typeValue,
      ),
    );
    if (!mounted) return;
    setState(() {
      savingMetadata = false;
      if (ok) metadataDirty = false;
    });
    AppToast.show(
      context,
      message: ok ? AppLocalizations.of(context)!.assetLibraryPageS249 : AppLocalizations.of(context)!.assetLibraryPageS248,
      tone: ok ? AppToastTone.success : AppToastTone.error,
    );
  }

  Future<void> _confirmDeleteAsset(AssetVm detailAsset) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.assetLibraryPageS766)),
            content: Text(AppLocalizations.of(context)!.assetLibraryPageS298)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(AppLocalizations.of(context)!.actionCancel)),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(AppLocalizations.of(context)!.assetLibraryPageS296)),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    final ok = await widget.onDeleteAsset(detailAsset.id);
    if (!mounted) return;
    AppToast.show(
      context,
      message: ok ? AppLocalizations.of(context)!.assetLibraryPageS434 : AppLocalizations.of(context)!.assetLibraryPageS299,
      tone: ok ? AppToastTone.success : AppToastTone.error,
    );
  }

  Future<void> _openOriginalFile(AssetVm detailAsset) async {
    final path = detailAsset.imagePath.trim();
    if (path.isEmpty) return;
    try {
      await Process.start('open', [path]);
      if (!mounted) return;
      AppToast.show(context, message: AppLocalizations.of(context)!.assetLibraryPageS447, tone: AppToastTone.success);
    } catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: '打开原图失败：$error',
        tone: AppToastTone.error,
      );
    }
  }

  Future<void> _syncAsset(String assetId) async {
    final sync = widget.onSyncAsset;
    if (sync == null) return;
    final ok = await sync(assetId);
    if (!mounted) return;
    AppToast.show(
      context,
      message: ok ? AppLocalizations.of(context)!.assetLibraryPageS437 : AppLocalizations.of(context)!.assetLibraryPageS338,
      tone: ok ? AppToastTone.success : AppToastTone.error,
    );
  }
}
