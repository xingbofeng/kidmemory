import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

Future<bool> confirmAssetLibraryDeleteSelected({
  required BuildContext context,
  required int selectedCount,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.assetLibraryPageS767),
          content: Text(
            AppLocalizations.of(
              context,
            )!.assetLibraryDeleteSelectedConfirm(selectedCount),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(context)!.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppLocalizations.of(context)!.assetLibraryPageS296),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> confirmAssetLibraryDeleteAsset(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.assetLibraryPageS766),
          content: Text(AppLocalizations.of(context)!.assetLibraryPageS298),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(context)!.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppLocalizations.of(context)!.assetLibraryPageS296),
            ),
          ],
        ),
      ) ??
      false;
}
