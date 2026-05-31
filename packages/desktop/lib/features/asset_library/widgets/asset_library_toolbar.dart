import 'package:flutter/material.dart';

import '../../../core/sidecar/sidecar_api.dart';
import '../../../shared/models/library_models.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/content.dart';
import '../../../shared/widgets/layout.dart';
import '../../web_companion/direct_upload/direct_upload_entry.dart';
import '../../web_companion/trusted_upload/trusted_upload_entry.dart';
import '../../../../l10n/app_localizations.dart';
import '../asset_library_utils.dart';
import 'asset_library_palette.dart';
import 'asset_library_toolbar_controls.dart';

class AssetLibraryToolbar extends StatelessWidget {
  const AssetLibraryToolbar({
    super.key,
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
                      foregroundColor: AssetLibraryPalette.successAction,
                      backgroundColor: AssetLibraryPalette.successSoft,
                      side: const BorderSide(
                        color: AssetLibraryPalette.successStrongBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (showImportActions)
                  AssetLibraryToolbarButton(
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
                  AssetLibraryToolbarButton(
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
                ToolbarLabeledField(
                  label: AppLocalizations.of(context)!.assetLibraryChildLabel,
                  width: 188,
                  child: children.isEmpty
                      ? ReadonlyToolbarField(
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
              ToolbarLabeledField(
                label: AppLocalizations.of(context)!.assetLibrarySortLabel,
                width: 236,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedSortMode,
                  isExpanded: true,
                  items: assetLibrarySortOptions(context)
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
              InlineStatusChip(
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
      fillColor: AssetLibraryPalette.fieldFill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AssetLibraryPalette.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AssetLibraryPalette.focusBorder),
      ),
    );
  }
}
