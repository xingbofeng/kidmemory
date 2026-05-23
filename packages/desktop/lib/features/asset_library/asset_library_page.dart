import 'package:flutter/material.dart';

import '../../core/sidecar/sidecar_api.dart';
import '../../shared/models/library_models.dart';

import 'asset_library_models.dart';
import 'asset_library_page_state.dart';

export 'asset_library_models.dart';

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
  /// The asset library toolbar surfaces a dedicated Direct Upload entry.
  /// button next to the existing import actions. Leaving this `null` keeps
  /// the toolbar identical to the standard import-only behavior.
  final VoidCallback? onOpenDirectUpload;

  /// Optional SidecarApi for Trusted Upload. When provided, enables the
  /// trusted upload entry button in the toolbar.
  final SidecarApi? sidecarApi;
  final Future<void> Function()? onTrustedUploadFinished;

  @override
  State<AssetLibraryPage> createState() => AssetLibraryPageState();
}
