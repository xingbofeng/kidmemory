import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import 'asset_library_import_feedback.dart';
import 'asset_library_page.dart';

mixin AssetLibraryImportActions on State<AssetLibraryPage> {
  bool get importBusy;
  set importBusy(bool value);

  Future<void> importFilesWithMessage() async {
    await runImportWithMessage(widget.onImportFiles);
  }

  Future<void> importFolderWithMessage() async {
    await runImportWithMessage(widget.onImportFolder);
  }

  Future<void> runImportWithMessage(
    Future<AssetImportReport> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => importBusy = true);
    try {
      final report = await action();
      if (!mounted) return;
      showAssetLibraryImportToast(context, report);
    } catch (error) {
      if (!mounted) return;
      showAssetLibraryImportToast(
        context,
        AssetImportReport(
          imported: 0,
          duplicates: 0,
          skipped: 0,
          failed: 1,
          message: l10n.assetLibraryImportFailedMessage(error),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => importBusy = false);
      }
    }
  }

  Future<void> importDroppedPathsWithMessage(List<String> paths) async {
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
    showAssetLibraryImportToast(context, report);
  }
}
