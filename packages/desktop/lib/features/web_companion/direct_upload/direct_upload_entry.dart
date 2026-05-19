import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Entry button surfacing the Supabase Direct Upload flow.
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
      icon: const Icon(Icons.qr_code_2_outlined),
      label: Text(AppLocalizations.of(context)!.directUploadEntryButtonLabel),
    );
  }
}
