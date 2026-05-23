import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../shared/models/library_models.dart';
import '../../shared/widgets/status.dart';

import 'asset_library_dialogs.dart';
import 'asset_library_page.dart';
import 'asset_library_smart_pick_dialog.dart';

mixin AssetLibrarySelectionActions on State<AssetLibraryPage> {
  List<AssetVm> get displayedAssets;
  String? get selectedAssetId;
  set selectedAssetId(String? value);
  bool get deleteBusy;
  set deleteBusy(bool value);

  void syncEditor();

  void clearSelectedAssets() {
    final replace = widget.onReplaceSelectedAssets;
    if (replace != null) {
      replace(<String>{});
      return;
    }
    for (final id in widget.selectedAssets.toList()) {
      widget.onToggle(id);
    }
  }

  Future<void> showSmartPickDialog() async {
    final result = await showAssetLibrarySmartPickDialog(
      context: context,
      assets: displayedAssets,
    );
    if (!mounted || result == null) return;

    if (result.action == AssetLibrarySmartPickAction.confirm) {
      final next = result.suggestedAssets.map((asset) => asset.id).toSet();
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
      syncEditor();
      AppToast.show(
        context,
        title: AppLocalizations.of(context)!.assetLibraryPageS564,
        message: AppLocalizations.of(
          context,
        )!.assetLibrarySmartPickAppliedMessage(next.length),
        tone: AppToastTone.success,
      );
      return;
    }

    if (result.action == AssetLibrarySmartPickAction.manual) {
      AppToast.show(
        context,
        title: AppLocalizations.of(context)!.assetLibraryPageS430,
        message: AppLocalizations.of(context)!.assetLibraryPageS235,
        tone: AppToastTone.info,
      );
    }
  }

  Future<void> deleteSelectedWithConfirmation() async {
    final confirmed = await confirmAssetLibraryDeleteSelected(
      context: context,
      selectedCount: widget.selectedAssets.length,
    );
    if (!confirmed) return;
    setState(() => deleteBusy = true);
    try {
      final deletedCount = await widget.onDeleteSelected();
      if (!mounted) return;
      AppToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.assetLibraryDeletedSelectedMessage(deletedCount),
        tone: AppToastTone.success,
      );
    } finally {
      if (mounted) {
        setState(() => deleteBusy = false);
      }
    }
  }
}
