import 'package:flutter/material.dart';

import '../../shared/widgets/chrome.dart';
import '../../../l10n/app_localizations.dart';

List<Map<String, String>> assetLibrarySortOptions(BuildContext context) => [
  {
    'value': 'created_desc',
    'label': AppLocalizations.of(context)!.assetLibraryPageS285,
  },
  {
    'value': 'created_asc',
    'label': AppLocalizations.of(context)!.assetLibraryPageS286,
  },
  {
    'value': 'type',
    'label': AppLocalizations.of(context)!.assetLibraryPageS786,
  },
  {
    'value': 'title',
    'label': AppLocalizations.of(context)!.assetLibraryPageS631,
  },
];


String assetLibraryStorageStatusLabel(BuildContext context, String status) {
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

String assetLibraryIconAsset(BuildContext context, String type) {
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
