import 'dart:io';

import 'package:flutter/material.dart';

import '../../shared/widgets/status.dart';
import '../../../l10n/app_localizations.dart';
import 'asset_library_models.dart';

AssetMetadataUpdate buildAssetMetadataUpdate({
  required String title,
  required String description,
  required String tags,
  required String capturedAt,
  required String type,
}) {
  return AssetMetadataUpdate(
    title: title.trim(),
    description: description.trim(),
    tags: tags
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(),
    capturedAt: capturedAt.trim().isEmpty ? null : capturedAt.trim(),
    type: type,
  );
}

Future<void> openAssetOriginalFile({
  required BuildContext context,
  required String path,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final trimmedPath = path.trim();
  if (trimmedPath.isEmpty) return;
  try {
    await Process.start('open', [trimmedPath]);
    if (!context.mounted) return;
    AppToast.show(
      context,
      message: l10n.assetLibraryPageS447,
      tone: AppToastTone.success,
    );
  } catch (error) {
    if (!context.mounted) return;
    AppToast.show(
      context,
      message: l10n.assetLibraryOpenOriginalFailedMessage(error),
      tone: AppToastTone.error,
    );
  }
}

void showAssetMetadataSaveToast(BuildContext context, {required bool ok}) {
  AppToast.show(
    context,
    message: ok
        ? AppLocalizations.of(context)!.assetLibraryPageS249
        : AppLocalizations.of(context)!.assetLibraryPageS248,
    tone: ok ? AppToastTone.success : AppToastTone.error,
  );
}

void showAssetDeleteResultToast(BuildContext context, {required bool ok}) {
  AppToast.show(
    context,
    message: ok
        ? AppLocalizations.of(context)!.assetLibraryPageS434
        : AppLocalizations.of(context)!.assetLibraryPageS299,
    tone: ok ? AppToastTone.success : AppToastTone.error,
  );
}

void showAssetSyncResultToast(BuildContext context, {required bool ok}) {
  AppToast.show(
    context,
    message: ok
        ? AppLocalizations.of(context)!.assetLibraryPageS437
        : AppLocalizations.of(context)!.assetLibraryPageS338,
    tone: ok ? AppToastTone.success : AppToastTone.error,
  );
}
