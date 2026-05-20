import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/sidecar/sidecar_api.dart';
import '../../../shared/widgets/chrome.dart';
import 'trusted_upload_controller.dart';
import 'trusted_upload_dialog.dart';

/// Trusted Upload entry button.
///
/// Uses trusted backend sessions, signed upload targets, and pullback workers.
class TrustedUploadEntryButton extends StatelessWidget {
  const TrustedUploadEntryButton({
    required this.sidecarApi,
    required this.childId,
    this.onSessionFinished,
    super.key,
  });

  final SidecarApi sidecarApi;
  final String childId;
  final Future<void> Function()? onSessionFinished;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showTrustedUploadDialog(context),
      icon: const AppAssetIcon(uploadIconAsset, size: 20),
      label: Text(AppLocalizations.of(context)!.trustedUploadEntryButtonLabel),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _showTrustedUploadDialog(BuildContext context) async {
    final controller = TrustedUploadController(
      sidecarApi: sidecarApi,
      childId: childId,
    );

    try {
      await controller.createSession();

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => TrustedUploadDialog(
          controller: controller,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
      await onSessionFinished?.call();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.trustedUploadCreateSessionFailed(e),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
