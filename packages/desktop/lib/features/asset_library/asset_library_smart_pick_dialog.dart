import 'package:flutter/material.dart';

import '../../shared/models/library_models.dart';
import '../../shared/widgets/status.dart';
import '../../../l10n/app_localizations.dart';
import 'asset_library_smart_pick.dart';

enum AssetLibrarySmartPickAction { confirm, manual }

class AssetLibrarySmartPickDialogResult {
  const AssetLibrarySmartPickDialogResult({
    required this.action,
    required this.suggestedAssets,
  });

  final AssetLibrarySmartPickAction action;
  final List<AssetVm> suggestedAssets;
}

Future<AssetLibrarySmartPickDialogResult?> showAssetLibrarySmartPickDialog({
  required BuildContext context,
  required List<AssetVm> assets,
}) async {
  if (assets.isEmpty) {
    AppToast.show(
      context,
      title: AppLocalizations.of(context)!.assetLibraryPageS572,
      message: AppLocalizations.of(context)!.assetLibraryPageS481,
      tone: AppToastTone.info,
    );
    return null;
  }

  var target = 'picture_book';
  var seed = 0;
  var suggested = buildAssetLibrarySmartSuggestion(
    assets: assets,
    target: target,
    seed: seed,
  );

  final action = await showDialog<AssetLibrarySmartPickAction>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.assetLibrarySmartPickLabel,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.assetLibraryPageS869),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: target,
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() {
                      target = value;
                      seed = 0;
                      suggested = buildAssetLibrarySmartSuggestion(
                        assets: assets,
                        target: target,
                        seed: seed,
                      );
                    });
                  },
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'picture_book',
                        title: Text(
                          AppLocalizations.of(context)!.assetLibraryPageS902,
                        ),
                        dense: true,
                      ),
                      RadioListTile<String>(
                        value: 'memory_album',
                        title: Text(
                          AppLocalizations.of(context)!.assetLibraryPageS901,
                        ),
                        dense: true,
                      ),
                      RadioListTile<String>(
                        value: 'memory_video',
                        title: Text(
                          AppLocalizations.of(context)!.assetLibraryPageS900,
                        ),
                        dense: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.assetLibrarySmartPickedCount(suggested.length),
                ),
                const SizedBox(height: 10),
                AssetLibrarySmartPickPreview(assets: suggested),
                if (assets.length <= suggested.length) ...[
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.assetLibrarySmartPickAllIncludedHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(AssetLibrarySmartPickAction.manual),
                child: Text(AppLocalizations.of(context)!.assetLibraryPageS503),
              ),
              TextButton(
                onPressed: assets.length <= suggested.length
                    ? null
                    : () {
                        setDialogState(() {
                          seed += 1;
                          suggested = buildAssetLibrarySmartSuggestion(
                            assets: assets,
                            target: target,
                            seed: seed,
                          );
                        });
                      },
                child: Text(AppLocalizations.of(context)!.assetLibraryPageS919),
              ),
              FilledButton(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(AssetLibrarySmartPickAction.confirm),
                child: Text(AppLocalizations.of(context)!.assetLibraryPageS765),
              ),
            ],
          );
        },
      );
    },
  );

  if (action == null) return null;
  return AssetLibrarySmartPickDialogResult(
    action: action,
    suggestedAssets: suggested,
  );
}

class AssetLibrarySmartPickPreview extends StatelessWidget {
  const AssetLibrarySmartPickPreview({super.key, required this.assets});

  final List<AssetVm> assets;

  @override
  Widget build(BuildContext context) {
    final previewAssets = assets.take(4).toList();
    if (previewAssets.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final asset in previewAssets)
          InputChip(
            label: Text(asset.title.trim().isEmpty ? asset.id : asset.title),
            showCheckmark: false,
            selected: true,
          ),
      ],
    );
  }
}
