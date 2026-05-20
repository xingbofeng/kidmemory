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
    final label = normalized == 'failed'
        ? AppLocalizations.of(context)!.assetLibraryResyncLabel
        : AppLocalizations.of(context)!.assetLibrarySyncToStorageLabel;
    final reason = synced
        ? AppLocalizations.of(context)!.assetLibrarySyncedToStorageText
        : running
        ? AppLocalizations.of(context)!.assetLibrarySyncRunningOrRetryText
        : AppLocalizations.of(context)!.assetLibraryLocalSyncFallbackText;

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

String _storageStatusLabel(BuildContext context, String status) {
  final normalized = status.trim();
  if (normalized == 'synced') {
    return AppLocalizations.of(context)!.assetLibraryStatusSynced;
  }
  if (normalized == 'pending' || normalized == 'running') {
    return AppLocalizations.of(context)!.assetLibraryStatusSyncing;
  }
  if (normalized == 'retry_wait') {
    return AppLocalizations.of(context)!.assetLibraryStatusRetryWaiting;
  }
  if (normalized == 'failed') {
    return AppLocalizations.of(context)!.assetLibraryStatusFailed;
  }
  if (normalized.isEmpty ||
      normalized == 'local_only' ||
      normalized == 'ready') {
    return AppLocalizations.of(context)!.assetLibraryStatusLocalOnly;
  }
  return normalized;
}

class _LibraryHeaderStatus extends StatelessWidget {
  const _LibraryHeaderStatus({
    required this.childName,
    required this.assetCount,
    required this.indexingMessage,
  });

  final String childName;
  final int assetCount;
  final String indexingMessage;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _SoftStatusChip(
          iconAsset: childIconAsset,
          text: AppLocalizations.of(
            context,
          )!.assetLibraryCurrentChildChip(childName),
        ),
        _SoftStatusChip(
          iconAsset: gridIconAsset,
          text: AppLocalizations.of(
            context,
          )!.assetLibraryAssetCountChip(assetCount),
        ),
        _SoftStatusChip(iconAsset: completeIconAsset, text: indexingMessage),
      ],
    );
  }
}

class _SoftStatusChip extends StatelessWidget {
  const _SoftStatusChip({required this.iconAsset, required this.text});

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _AssetLibraryPalette.fieldBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAssetIcon(iconAsset, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _AssetLibraryPalette.bodyStrong,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetStatusBar extends StatelessWidget {
  const _AssetStatusBar({
    required this.typeOptions,
    required this.selectedType,
    required this.counts,
    required this.indexingMessage,
    required this.onChanged,
  });

  final List<Map<String, String>> typeOptions;
  final String selectedType;
  final Map<String, int> counts;
  final String indexingMessage;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final segmented = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xfffffcf7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _AssetLibraryPalette.fieldBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < typeOptions.length; index++) ...[
              _SegmentOption(
                label: typeOptions[index]['label'] ?? '',
                count: counts[typeOptions[index]['value']] ?? 0,
                selected: selectedType == typeOptions[index]['value'],
                onTap: () => onChanged(typeOptions[index]['value'] ?? 'all'),
              ),
              if (index != typeOptions.length - 1) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
    final status = _IndexingStatusPill(text: indexingMessage);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [segmented, const SizedBox(height: 8), status],
          );
        }
        return Row(
          children: [
            Expanded(child: segmented),
            const SizedBox(width: 12),
            status,
          ],
        );
      },
    );
  }
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? _AssetLibraryPalette.successTint
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: _AssetLibraryPalette.successStrongBorder)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? _AssetLibraryPalette.successText
                    : _AssetLibraryPalette.bodyMuted,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                color: selected
                    ? _AssetLibraryPalette.successText
                    : _AssetLibraryPalette.bodyMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label, required this.type});

  final String label;
  final String type;

  @override
  Widget build(BuildContext context) {
    final colors = switch (type) {
      'photo' => (
        const Color(0xffeef6ff),
        const Color(0xffbad3ef),
        const Color(0xff355b8c),
      ),
      'craft' => (
        const Color(0xfffff4d8),
        const Color(0xffefcf8b),
        const Color(0xff8f5b18),
      ),
      _ => (
        const Color(0xffe8f4ea),
        const Color(0xffb6dec0),
        const Color(0xff2b7d4a),
      ),
    };
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.$2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.$3,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
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
    required this.importBusy,
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
  final bool importBusy;
  final VoidCallback? onOpenDirectUpload;
  final SidecarApi? sidecarApi;
  final Future<void> Function()? onTrustedUploadFinished;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              Widget searchRow() {
                return Row(
                  children: [
                    Expanded(
                      child: SearchBox(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        hintText: AppLocalizations.of(
                          context,
                        )!.assetLibrarySearchHintText,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 88,
                      height: 46,
                      child: FilledButton(
                        onPressed: semanticSearching || importBusy
                            ? null
                            : onSemanticSearch,
                        child: Text(
                          semanticSearching
                              ? AppLocalizations.of(
                                  context,
                                )!.assetLibrarySearchingLabel
                              : AppLocalizations.of(
                                  context,
                                )!.assetLibrarySearchButtonLabel,
                        ),
                      ),
                    ),
                  ],
                );
              }

              final actions = <Widget>[
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: onSmartPick,
                    icon: const AppAssetIcon(wandIconAsset, size: 18),
                    label: Text(
                      AppLocalizations.of(context)!.assetLibrarySmartPickLabel,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _AssetLibraryPalette.successAction,
                      backgroundColor: _AssetLibraryPalette.successSoft,
                      side: const BorderSide(
                        color: _AssetLibraryPalette.successStrongBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (showImportActions)
                  _ToolbarButton(
                    iconAsset: imageIconAsset,
                    label: importBusy
                        ? AppLocalizations.of(
                            context,
                          )!.sampleDatasetImportingActionLabel
                        : AppLocalizations.of(
                            context,
                          )!.assetLibraryImportPhotoLabel,
                    onPressed: importBusy ? null : onImportFiles,
                  ),
                if (showImportActions)
                  _ToolbarButton(
                    iconAsset: folderIconAsset,
                    label: importBusy
                        ? AppLocalizations.of(
                            context,
                          )!.sampleDatasetImportingActionLabel
                        : AppLocalizations.of(
                            context,
                          )!.assetLibraryImportFolderLabel,
                    onPressed: importBusy ? null : onImportFolder,
                  ),
              ];

              if (constraints.maxWidth < 820) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchRow(),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchRow()),
                  const SizedBox(width: 8),
                  for (var index = 0; index < actions.length; index++) ...[
                    actions[index],
                    if (index != actions.length - 1) const SizedBox(width: 8),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!isDemoMode)
                _ToolbarLabeledField(
                  label: AppLocalizations.of(context)!.assetLibraryChildLabel,
                  width: 188,
                  child: children.isEmpty
                      ? _ReadonlyToolbarField(
                          iconAsset: childIconAsset,
                          label: AppLocalizations.of(
                            context,
                          )!.assetLibraryNoChildProfileText,
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
                          decoration: _toolbarDecoration(),
                        ),
                ),
              _ToolbarLabeledField(
                label: AppLocalizations.of(context)!.assetLibrarySortLabel,
                width: 236,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedSortMode,
                  isExpanded: true,
                  items: _assetSortOptions(context)
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
                  decoration: _toolbarDecoration(),
                ),
              ),
              _InlineStatusChip(
                iconAsset: refreshIconAsset,
                label: refreshingIndex
                    ? AppLocalizations.of(
                        context,
                      )!.assetLibraryIndexRefreshingLabel
                    : AppLocalizations.of(
                        context,
                      )!.assetLibraryRefreshIndexLabel,
                onPressed: refreshingIndex ? null : onRefreshSearchIndexing,
              ),
              if (showImportActions) ...[
                if (sidecarApi != null && selectedChildId != null)
                  TrustedUploadEntryButton(
                    sidecarApi: sidecarApi!,
                    childId: selectedChildId!,
                    onSessionFinished: onTrustedUploadFinished,
                  ),
                if (sidecarApi == null && onOpenDirectUpload != null)
                  DirectUploadEntryButton(onTap: onOpenDirectUpload!),
              ],
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _toolbarDecoration() {
    return InputDecoration(
      isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppAssetIcon(completeIconAsset, size: 16),
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
            TextButton(
              onPressed: onClear,
              child: Text(
                AppLocalizations.of(context)!.assetLibraryClearSearchLabel,
              ),
            ),
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
                  AppLocalizations.of(
                    context,
                  )!.assetLibraryCollectionSelectedCount(selectedCount),
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
            Text(
              AppLocalizations.of(context)!.assetLibraryNoSelectedAssetsText,
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
                      _assetIconAsset(context, asset.type),
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
            label: AppLocalizations.of(context)!.assetLibraryGoToGenerateLabel,
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

String _assetIconAsset(BuildContext context, String type) {
  if (type == 'photo' ||
      type == AppLocalizations.of(context)!.contentAssetTypePhotoLabel) {
    return cameraIconAsset;
  }
  if (type == 'craft' ||
      type == AppLocalizations.of(context)!.contentAssetTypeCraftLabel) {
    return bearDocumentIconAsset;
  }
  return paletteIconAsset;
}

class _ReadonlyToolbarField extends StatelessWidget {
  const _ReadonlyToolbarField({required this.iconAsset, required this.label});

  final String iconAsset;
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
          AppAssetIcon(iconAsset, size: compactInlineIconSize, opacity: 0.86),
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

class _ToolbarLabeledField extends StatelessWidget {
  const _ToolbarLabeledField({
    required this.label,
    required this.child,
    required this.width,
  });

  final String label;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Text(
            '$label：',
            style: const TextStyle(
              color: _AssetLibraryPalette.bodyMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _InlineStatusChip extends StatelessWidget {
  const _InlineStatusChip({
    required this.iconAsset,
    required this.label,
    this.onPressed,
  });

  final String iconAsset;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: AppAssetIcon(iconAsset, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: _AssetLibraryPalette.bodyStrong,
          side: const BorderSide(color: _AssetLibraryPalette.fieldBorder),
          backgroundColor: _AssetLibraryPalette.fieldFill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.iconAsset,
    required this.label,
    required this.onPressed,
  });

  final String iconAsset;
  final String label;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: AppAssetIcon(iconAsset, size: compactInlineIconSize),
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
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({
    required this.selectedCount,
    required this.onDeleteSelected,
    required this.onClearSelection,
    required this.deleteBusy,
    this.onGoToGenerate,
  });

  final int selectedCount;
  final Future<void> Function()? onDeleteSelected;
  final VoidCallback onClearSelection;
  final bool deleteBusy;
  final VoidCallback? onGoToGenerate;

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
            AppLocalizations.of(
              context,
            )!.assetLibrarySelectedAssetsCount(selectedCount),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: _AssetLibraryPalette.successText,
            ),
          ),
          const Spacer(),
          _BatchTextButton(
            label: AppLocalizations.of(
              context,
            )!.assetLibraryBatchGeneratePictureBookLabel,
            onPressed: onGoToGenerate,
          ),
          _BatchTextButton(
            label: AppLocalizations.of(
              context,
            )!.assetLibraryBatchGenerateVideoLabel,
            onPressed: onGoToGenerate,
          ),
          _BatchTextButton(
            label: AppLocalizations.of(
              context,
            )!.assetLibraryBatchGenerateAlbumLabel,
            onPressed: onGoToGenerate,
          ),
          TextButton(
            onPressed: onClearSelection,
            child: Text(
              AppLocalizations.of(context)!.assetLibraryClearSelectionLabel,
            ),
          ),
          TextButton.icon(
            onPressed: onDeleteSelected,
            icon: const AppAssetIcon(deleteIconAsset, size: 18),
            label: Text(
              deleteBusy
                  ? AppLocalizations.of(context)!.assetLibraryBatchDeletingLabel
                  : AppLocalizations.of(
                      context,
                    )!.assetLibraryBatchDeleteButtonLabel,
            ),
            style: TextButton.styleFrom(
              foregroundColor: _AssetLibraryPalette.dangerText,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchTextButton extends StatelessWidget {
  const _BatchTextButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _AssetLibraryPalette.successAction,
      ),
      child: Text(label),
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
              Text(
                AppLocalizations.of(context)!.assetLibraryEmptyLibraryTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.assetLibraryImportDescriptionText,
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
                    iconAsset: imageIconAsset,
                    label: AppLocalizations.of(
                      context,
                    )!.assetLibraryImportPhotoLabel,
                    onPressed: onImportFiles,
                  ),
                  const SizedBox(width: 12),
                  _ToolbarButton(
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

class _EmptySearchResults extends StatelessWidget {
  const _EmptySearchResults({
    required this.onClearSearch,
    required this.onSmartPick,
  });

  final VoidCallback onClearSearch;
  final Future<void> Function() onSmartPick;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      backgroundColor: _AssetLibraryPalette.fieldFill,
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
                  color: _AssetLibraryPalette.bodyMuted,
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

class _InspectorEmptyState extends StatelessWidget {
  const _InspectorEmptyState({required this.onSmartPick});

  final Future<void> Function() onSmartPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _AssetLibraryPalette.successSoft,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _AssetLibraryPalette.successBorder),
            ),
            child: const AppAssetIcon(viewIconAsset, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            AppLocalizations.of(context)!.assetLibrarySelectAssetTitle,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.assetLibraryInspectorHintText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _AssetLibraryPalette.bodyMuted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onSmartPick,
            icon: const AppAssetIcon(wandIconAsset, size: 18),
            label: Text(
              AppLocalizations.of(context)!.assetLibrarySmartOrganizeLabel,
            ),
          ),
        ],
      ),
    );
  }
}
