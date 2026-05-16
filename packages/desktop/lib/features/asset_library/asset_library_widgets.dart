part of 'asset_library_page.dart';

abstract final class _AssetLibraryPalette {
  static const textMuted = Color(0xff8c7663);
  static const fieldFill = Color(0xfffffbf5);
  static const fieldBorder = Color(0xffeadbc9);
  static const focusBorder = Color(0xff2faa61);
  static const successSoft = Color(0xfff4fbf5);
  static const successTint = Color(0xffeaf7ee);
  static const successBorder = Color(0xffcdebd6);
  static const successStrongBorder = Color(0xffb6dec0);
  static const successText = Color(0xff14773c);
  static const successAction = Color(0xff207947);
  static const successBody = Color(0xff31564a);
  static const neutralSoft = Color(0xfff4f7fb);
  static const neutralBorder = Color(0xffdae4ed);
  static const neutralText = Color(0xff35536a);
  static const activeSoft = Color(0xfff5f2ff);
  static const activeBorder = Color(0xffd6c8ff);
  static const activeText = Color(0xff4a2f95);
  static const bodyMuted = Color(0xff6f6258);
  static const bodyStrong = Color(0xff5d5148);
  static const dangerText = Color(0xff9b3a2b);
  static const emptyIconFill = Color(0xffffefc8);
  static const emptyIconBorder = Color(0xffffbd54);
}

class _AssetStorageAction extends StatelessWidget {
  const _AssetStorageAction({required this.status, required this.onPressed});

  final String status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim();
    final synced = normalized == 'synced';
    final running =
        normalized == 'pending' ||
        normalized == 'running' ||
        normalized == 'retry_wait';
    final label = normalized == 'failed' ? '重新同步' : '同步到 Supabase';
    final reason = synced
        ? '素材已同步到 Supabase Storage'
        : running
        ? '素材正在同步或等待重试'
        : '把本地素材同步到 Supabase Storage，失败不影响本地使用';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecondaryButton(
          label: label,
          iconAsset: cloudUploadIconAsset,
          fullWidth: true,
          height: 42,
          onPressed: synced || running ? null : onPressed,
        ),
        const SizedBox(height: 6),
        Text(
          reason,
          style: const TextStyle(
            color: _AssetLibraryPalette.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

String _storageStatusLabel(String status) {
  return switch (status.trim()) {
    'synced' => '已同步',
    'pending' || 'running' => '同步中',
    'retry_wait' => '等待重试',
    'failed' => '同步失败',
    'local_only' || '' || 'ready' => '仅本地',
    final value => value,
  };
}

class _LibraryToolbar extends StatelessWidget {
  const _LibraryToolbar({
    required this.isDemoMode,
    required this.showImportActions,
    required this.children,
    required this.selectedChildId,
    required this.searchController,
    required this.onSearchChanged,
    required this.onChildChanged,
    required this.selectedSortMode,
    required this.onSortChanged,
    required this.semanticSearching,
    required this.refreshingIndex,
    required this.onSemanticSearch,
    required this.onRefreshSearchIndexing,
    required this.onImportFiles,
    required this.onImportFolder,
    required this.onSmartPick,
    this.onOpenDirectUpload,
    this.sidecarApi,
    this.onTrustedUploadFinished,
  });

  final bool isDemoMode;
  final bool showImportActions;
  final List<ChildVm> children;
  final String? selectedChildId;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onChildChanged;
  final String selectedSortMode;
  final ValueChanged<String> onSortChanged;
  final bool semanticSearching;
  final bool refreshingIndex;
  final Future<void> Function() onSemanticSearch;
  final Future<void> Function() onRefreshSearchIndexing;
  final Future<void> Function() onImportFiles;
  final Future<void> Function() onImportFolder;
  final Future<void> Function() onSmartPick;
  final VoidCallback? onOpenDirectUpload;
  final SidecarApi? sidecarApi;
  final Future<void> Function()? onTrustedUploadFinished;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SearchBox(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  hintText: '搜索标题、标签，或输入自然语言搜图...',
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                height: 48,
                child: FilledButton(
                  onPressed: semanticSearching ? null : onSemanticSearch,
                  child: Text(semanticSearching ? '搜索中' : '搜索'),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: '刷新语义索引',
                child: IconButton.filledTonal(
                  onPressed: refreshingIndex ? null : onRefreshSearchIndexing,
                  icon: const AppAssetIcon(
                    refreshIconAsset,
                    size: inlineIconSize,
                  ),
                ),
              ),
              if (!isDemoMode) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: children.isEmpty
                      ? const _ReadonlyToolbarField(
                          icon: Icons.child_care,
                          iconAsset: childIconAsset,
                          label: '暂无孩子档案',
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: selectedChildId ?? children.first.id,
                          items: children
                              .map(
                                (child) => DropdownMenuItem(
                                  value: child.id,
                                  child: Text(child.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) onChildChanged(value);
                          },
                          decoration: _toolbarDecoration('当前孩子'),
                        ),
                ),
              ],
              const SizedBox(width: 12),
              SizedBox(
                width: 236,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedSortMode,
                  isExpanded: true,
                  items: _assetSortOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option['value'],
                          child: Text(
                            option['label'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onSortChanged(value);
                  },
                  decoration: _toolbarDecoration('排序方式').copyWith(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12),
                      child: AppAssetIcon(sortIconAsset, size: inlineIconSize),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showImportActions) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (sidecarApi != null && selectedChildId != null)
                  TrustedUploadEntryButton(
                    sidecarApi: sidecarApi!,
                    childId: selectedChildId!,
                    onSessionFinished: onTrustedUploadFinished,
                  ),
                if (onOpenDirectUpload != null)
                  DirectUploadEntryButton(onTap: onOpenDirectUpload!),
                _ToolbarButton(
                  icon: Icons.add_photo_alternate_outlined,
                  iconAsset: imageIconAsset,
                  label: '导入图片',
                  onPressed: onImportFiles,
                ),
                _ToolbarButton(
                  icon: Icons.folder_open_outlined,
                  iconAsset: folderIconAsset,
                  label: '导入文件夹',
                  onPressed: onImportFolder,
                ),
                _ToolbarButton(
                  icon: Icons.auto_awesome_rounded,
                  iconAsset: starIconAsset,
                  label: '帮我挑素材',
                  onPressed: onSmartPick,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _toolbarDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: _AssetLibraryPalette.fieldFill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _AssetLibraryPalette.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _AssetLibraryPalette.focusBorder),
      ),
    );
  }
}

class _IndexingStatusPill extends StatelessWidget {
  const _IndexingStatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _AssetLibraryPalette.successSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _AssetLibraryPalette.successBorder),
      ),
      child: Row(
        children: [
          const AppAssetIcon(completeIconAsset, size: compactInlineIconSize),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: _AssetLibraryPalette.successBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchStatusStrip extends StatelessWidget {
  const _SearchStatusStrip({
    required this.text,
    required this.active,
    this.onClear,
  });

  final String text;
  final bool active;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: active
            ? _AssetLibraryPalette.activeSoft
            : _AssetLibraryPalette.neutralSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? _AssetLibraryPalette.activeBorder
              : _AssetLibraryPalette.neutralBorder,
        ),
      ),
      child: Row(
        children: [
          AppAssetIcon(
            active ? searchIconAsset : infoIconAsset,
            size: 16,
            opacity: active ? 1 : 0.72,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: active
                    ? _AssetLibraryPalette.activeText
                    : _AssetLibraryPalette.neutralText,
                fontSize: 12,
              ),
            ),
          ),
          if (onClear != null)
            TextButton(onPressed: onClear, child: const Text('清除')),
        ],
      ),
    );
  }
}

class _SelectionBasket extends StatelessWidget {
  const _SelectionBasket({
    required this.selectedAssets,
    required this.selectedCount,
    this.onGoToGenerate,
  });

  final List<AssetVm> selectedAssets;
  final int selectedCount;
  final VoidCallback? onGoToGenerate;

  @override
  Widget build(BuildContext context) {
    final previewAssets = selectedAssets.take(3).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _AssetLibraryPalette.successSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AssetLibraryPalette.successBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppAssetIcon(gridIconAsset, size: inlineIconSize),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '本次作品集素材 $selectedCount 项',
                  style: const TextStyle(
                    color: _AssetLibraryPalette.successText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (previewAssets.isEmpty)
            const Text(
              '选择素材后会在这里汇总。',
              style: TextStyle(
                color: _AssetLibraryPalette.bodyMuted,
                fontSize: 12,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final asset in previewAssets)
                  Chip(
                    avatar: AppAssetIcon(
                      _assetIconAsset(asset.type),
                      size: compactInlineIconSize,
                    ),
                    label: Text(asset.title, overflow: TextOverflow.ellipsis),
                    visualDensity: VisualDensity.compact,
                  ),
                if (selectedAssets.length > previewAssets.length)
                  Chip(
                    avatar: const AppAssetIcon(
                      moreIconAsset,
                      size: compactInlineIconSize,
                    ),
                    label: Text(
                      '+${selectedAssets.length - previewAssets.length}',
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '去生成作品集',
            iconAsset: wandIconAsset,
            fullWidth: true,
            height: 42,
            onPressed: selectedCount > 0 ? onGoToGenerate : null,
          ),
        ],
      ),
    );
  }
}

String _assetIconAsset(String type) {
  return switch (type) {
    'photo' || '照片' => cameraIconAsset,
    'craft' || '手工' => bearDocumentIconAsset,
    _ => paletteIconAsset,
  };
}

class _ReadonlyToolbarField extends StatelessWidget {
  const _ReadonlyToolbarField({
    required this.icon,
    required this.label,
    this.iconAsset,
  });

  final IconData icon;
  final String? iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _AssetLibraryPalette.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AssetLibraryPalette.fieldBorder),
      ),
      child: Row(
        children: [
          AppAssetIcon(
            iconAsset,
            fallbackIcon: icon,
            size: compactInlineIconSize,
            opacity: 0.86,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _AssetLibraryPalette.bodyStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconAsset,
  });

  final IconData icon;
  final String? iconAsset;
  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: AppAssetIcon(
          iconAsset,
          fallbackIcon: icon,
          size: compactInlineIconSize,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: _AssetLibraryPalette.successAction,
          side: const BorderSide(
            color: _AssetLibraryPalette.successStrongBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: _AssetLibraryPalette.successSoft,
        ),
      ),
    );
  }
}

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({
    required this.selectedCount,
    required this.onDeleteSelected,
  });

  final int selectedCount;
  final Future<void> Function() onDeleteSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _AssetLibraryPalette.successTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _AssetLibraryPalette.successStrongBorder),
      ),
      child: Row(
        children: [
          const AppAssetIcon(completeIconAsset, size: 24),
          const SizedBox(width: 10),
          Text(
            '已选择 $selectedCount 项素材',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: _AssetLibraryPalette.successText,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onDeleteSelected,
            icon: const AppAssetIcon(
              deleteIconAsset,
              size: compactInlineIconSize,
            ),
            label: const Text('批量删除已选'),
            style: TextButton.styleFrom(
              foregroundColor: _AssetLibraryPalette.dangerText,
            ),
          ),
        ],
      ),
    );
  }
}

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
      backgroundColor: _AssetLibraryPalette.fieldFill,
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
                  color: _AssetLibraryPalette.emptyIconFill,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _AssetLibraryPalette.emptyIconBorder,
                  ),
                ),
                child: const AppAssetIcon(imageIconAsset, size: 42),
              ),
              const SizedBox(height: 18),
              const Text(
                '还没有素材',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                '导入本地图片、整个文件夹，或把文件拖拽到素材库后，这里会显示真实缩略图和 metadata 编辑入口。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _AssetLibraryPalette.bodyMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ToolbarButton(
                    icon: Icons.add_photo_alternate_outlined,
                    iconAsset: imageIconAsset,
                    label: '导入图片',
                    onPressed: onImportFiles,
                  ),
                  const SizedBox(width: 12),
                  _ToolbarButton(
                    icon: Icons.folder_open_outlined,
                    iconAsset: folderIconAsset,
                    label: '导入文件夹',
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
