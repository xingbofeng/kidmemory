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

part 'asset_library_widgets.dart';
part 'asset_library_state.dart';

const _assetSortOptions = [
  {'value': 'created_desc', 'label': '创建时间（最新）'},
  {'value': 'created_asc', 'label': '创建时间（最早）'},
  {'value': 'type', 'label': '种类（绘画/照片/手工）'},
  {'value': 'title', 'label': '标题（A-Z）'},
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
  final Future<bool> Function(String id, AssetMetadataUpdate payload)
  onUpdateAsset;
  final Future<bool> Function(String id) onDeleteAsset;
  final Future<int> Function() onDeleteSelected;
  final Future<AssetImportReport> Function() onImportFiles;
  final Future<AssetImportReport> Function() onImportFolder;
  final Future<AssetImportReport> Function(List<String> paths)?
  onImportDroppedPaths;
  final Future<AssetSearchResponse> Function(AssetSearchRequest request)?
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
  String searchStatusMessage = '输入关键词可本地筛选，也可以使用语义搜索';
  String indexingMessage = '语义索引待加载';
  bool draggingFiles = false;
  int pageIndex = 0;

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
    _syncEditor();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSearchIndexingStatus();
    });
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
      searchStatusMessage = '已切换孩子档案，可重新搜索';
      _refreshSearchIndexingStatus();
    }
    if (oldWidget.assets != widget.assets) _syncEditor();
  }

  void _syncEditor() {
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
    final detailAsset = selectedAsset;
    final isDemoMode = widget.children.isEmpty && widget.assets.isEmpty;
    final visibleAssets = filteredAssets;
    final pageWindow = _AssetLibraryController.pageWindow(
      assets: visibleAssets,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
    final totalPages = pageWindow.totalPages;
    final currentPage = pageWindow.currentPage;
    final pageAssets = pageWindow.pageAssets;
    return PageFrame(
      title: '素材库 ✨',
      subtitle: '导入、搜索、筛选并选择本次作品集素材。',
      decoration: const GardenMark(),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
                    searchStatusMessage = '正在本地筛选素材';
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
                  onOpenDirectUpload: widget.onOpenDirectUpload,
                  sidecarApi: widget.sidecarApi,
                  onTrustedUploadFinished: widget.onTrustedUploadFinished,
                ),
                if (!isDemoMode && widget.selectedAssets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _BatchActionBar(
                    selectedCount: widget.selectedAssets.length,
                    onDeleteSelected: _deleteSelectedWithConfirmation,
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilterChips(
                        typeOptions: _sanitizeTypeOptions(widget.typeOptions),
                        selectedType: selectedFilterType,
                        onChanged: (type) => setState(() {
                          selectedFilterType = type;
                          pageIndex = 0;
                          selectedAssetId = null;
                          _syncEditor();
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _IndexingStatusPill(text: indexingMessage),
                  ],
                ),
                const SizedBox(height: 10),
                _SearchStatusStrip(
                  text: semanticSearchActive
                      ? '$searchStatusMessage · 结果 ${semanticSearchResults.length} 项'
                      : searchStatusMessage,
                  active: semanticSearchActive,
                  onClear: semanticSearchActive ? _clearSemanticSearch : null,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: DropTarget(
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: draggingFiles
                              ? const Color(0xff2faa61)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: visibleAssets.isEmpty
                          ? EmptyAssetLibrary(
                              onImportFiles: _importFilesWithMessage,
                              onImportFolder: _importFolderWithMessage,
                            )
                          : GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: semanticSearchActive
                                  ? 0.58
                                  : 0.66,
                              children: pageAssets
                                  .map(
                                    (asset) => AssetCard(
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
                                      selected: widget.selectedAssets.contains(
                                        asset.id,
                                      ),
                                      onTap: () {
                                        setState(
                                          () => selectedAssetId = asset.id,
                                        );
                                        _syncEditor();
                                        widget.onToggle(asset.id);
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (visibleAssets.isNotEmpty)
                  PaginationBar(
                    currentPage: currentPage,
                    totalPages: totalPages,
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
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 360,
            child: SurfaceCard(
              child: detailAsset == null
                  ? const Center(child: Text('暂无素材'))
                  : (!semanticSearchActive && widget.assets.isEmpty
                        ? _buildDemoDetail(detailAsset)
                        : _buildEditableDetail(detailAsset)),
            ),
          ),
        ],
      ),
    );
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
      setState(() => searchStatusMessage = '当前环境暂未启用语义搜索');
      return;
    }
    if (childId == null || childId.isEmpty) {
      setState(() => searchStatusMessage = '请先选择孩子档案再搜索');
      return;
    }
    if (query.isEmpty) {
      setState(() => searchStatusMessage = '请输入标题、标签或自然语言描述');
      return;
    }
    setState(() {
      semanticSearching = true;
      semanticSearchActive = true;
      semanticSearchResults = const [];
      selectedAssetId = null;
      pageIndex = 0;
      searchStatusMessage = '正在语义搜索...';
    });
    try {
      final response = await search(
        AssetSearchRequest(
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
        indexingMessage = '索引状态不可用';
      });
    }
  }

  void _clearSemanticSearch() {
    setState(() {
      semanticSearchActive = false;
      semanticSearchResults = const [];
      selectedAssetId = null;
      pageIndex = 0;
      searchStatusMessage = '已回到素材库浏览';
      _syncEditor();
    });
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
                message: '拖入的路径暂时无法导入',
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
            ? (report.imported > 0 ? '导入部分完成' : '导入失败')
            : report.imported > 0
            ? '导入完成'
            : '未导入素材');
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
            title: const Text('确认批量删除'),
            content: Text('将删除已选 ${widget.selectedAssets.length} 项素材，是否继续？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    final deletedCount = await widget.onDeleteSelected();
    if (!mounted) return;
    AppToast.show(
      context,
      message: '已删除 $deletedCount 项素材',
      tone: AppToastTone.success,
    );
  }

  Widget _buildDemoDetail(AssetVm detailAsset) {
    return SingleChildScrollView(
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
          const Text('标签', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detailAsset.tags
                .map((tag) => Chip(label: Text(tag)))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text('来源', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SourceRow(
            icon: Icons.calendar_month,
            iconAsset: timeIconAsset,
            label: '创建时间',
            value: detailAsset.capturedAt,
          ),
          const SourceRow(
            icon: Icons.person_outline,
            iconAsset: userIconAsset,
            label: '创建者',
            value: '示例档案',
          ),
          const SourceRow(
            icon: Icons.devices_other,
            iconAsset: bearHeadIconAsset,
            label: '来源设备',
            value: '内置示例',
          ),
          const SourceRow(
            icon: Icons.folder_outlined,
            iconAsset: folderIconAsset,
            label: '存储位置',
            value: '示例素材库',
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: widget.selectedAssets.contains(detailAsset.id)
                ? '从本次作品集移除'
                : '加入本次作品集',
            iconAsset: widget.selectedAssets.contains(detailAsset.id)
                ? deleteIconAsset
                : addIconAsset,
            onPressed: () => widget.onToggle(detailAsset.id),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '仅用于本次生成，不会修改原始素材',
              style: TextStyle(color: Color(0xff6f8d72), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableDetail(AssetVm detailAsset) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetArtworkPreview(
            path: detailAsset.previewPath,
            fallbackIcon: detailAsset.icon,
            label: detailAsset.title,
            height: 238,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  detailAsset.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Chip(label: Text(_displayType(detailAsset.type))),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: _fieldDecoration('标题'),
          ),
          const SizedBox(height: 10),
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
              typeValue = value ?? _defaultTypeFromOptions(widget.typeOptions);
            }),
            decoration: _fieldDecoration('类型'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            minLines: 3,
            maxLines: 4,
            decoration: _fieldDecoration('描述'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: tagsController,
            decoration: _fieldDecoration('标签（逗号分隔）'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: capturedAtController,
            onChanged: (value) => capturedAt = value,
            decoration: _fieldDecoration('日期（ISO）'),
          ),
          const SizedBox(height: 18),
          const Text('来源', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          SourceRow(
            icon: Icons.calendar_month,
            iconAsset: timeIconAsset,
            label: '创建时间',
            value: detailAsset.capturedAt.isEmpty
                ? '未填写'
                : detailAsset.capturedAt,
          ),
          SourceRow(
            icon: Icons.image_outlined,
            iconAsset: imageFileIconAsset,
            label: '原始文件',
            value: detailAsset.originalFilename.isEmpty
                ? '本地素材'
                : detailAsset.originalFilename,
          ),
          SourceRow(
            icon: Icons.cloud_done_outlined,
            iconAsset: cloudUploadIconAsset,
            label: '存储状态',
            value: _storageStatusLabel(detailAsset.storageStatus),
          ),
          if (widget.onSyncAsset != null) ...[
            const SizedBox(height: 4),
            _AssetStorageAction(
              status: detailAsset.storageStatus,
              onPressed: () => _syncAsset(detailAsset.id),
            ),
          ],
          const SizedBox(height: 12),
          _SelectionBasket(
            selectedAssets: selectedBasketAssets,
            selectedCount: widget.selectedAssets.length,
            onGoToGenerate: widget.onGoToGenerate,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: '保存元数据',
            iconAsset: completeIconAsset,
            onPressed: () async {
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
                  capturedAt: capturedAt.trim().isEmpty ? null : capturedAt.trim(),
                  type: typeValue,
                ),
              );
              if (!mounted) return;
              AppToast.show(
                context,
                message: ok ? '保存成功' : '保存失败',
                tone: ok ? AppToastTone.success : AppToastTone.error,
              );
            },
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '删除素材',
            iconAsset: deleteIconAsset,
            onPressed: () async {
              final confirmed =
                  await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('确认删除素材'),
                      content: const Text('删除后将从本地素材库移除，是否继续？'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('取消'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('删除'),
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
                message: ok ? '已删除' : '删除失败',
                tone: ok ? AppToastTone.success : AppToastTone.error,
              );
            },
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: widget.selectedAssets.contains(detailAsset.id)
                ? '从本次作品集移除'
                : '加入本次作品集',
            iconAsset: widget.selectedAssets.contains(detailAsset.id)
                ? deleteIconAsset
                : addIconAsset,
            onPressed: () => widget.onToggle(detailAsset.id),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    const borderColor = Color(0xffeadbc9);
    return InputDecoration(
      labelText: label,
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

  Future<void> _syncAsset(String assetId) async {
    final sync = widget.onSyncAsset;
    if (sync == null) return;
    final ok = await sync(assetId);
    if (!mounted) return;
    AppToast.show(
      context,
      message: ok ? '已加入同步队列' : '同步入队失败，请检查 Supabase Storage 配置',
      tone: ok ? AppToastTone.success : AppToastTone.error,
    );
  }
}
