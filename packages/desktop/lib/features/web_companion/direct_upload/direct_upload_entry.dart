import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';

/// Entry button surfacing the QR upload flow.
class DirectUploadEntryButton extends StatelessWidget {
  const DirectUploadEntryButton({
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: enabled ? onTap : null,
      icon: const AppAssetIcon(uploadIconAsset, size: 20),
      label: Text(AppLocalizations.of(context)!.directUploadEntryButtonLabel),
    );
  }
}
