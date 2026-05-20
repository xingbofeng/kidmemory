part of '../desktop_shell.dart';

extension _DesktopShellDirectUpload on _DesktopShellState {
  Future<void> _openDirectUploadDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final childId = selectedChildId;
    if (childId == null || childId.isEmpty) {
      _showSnackBar(l10n.directUploadS855);
      return;
    }

    final controller = DirectUploadController(
      api: api,
      serviceUnavailableMessage: l10n.directUploadServiceUnavailableMessage,
      sessionIncompleteMessage: l10n.directUploadSessionIncompleteMessage,
      configIncompleteMessage: l10n.directUploadConfigIncompleteMessage,
    );
    try {
      _showSnackBar(l10n.directUploadS650);
      final config = await controller.createSession(childId);
      if (!mounted) return;

      DirectUploadStatusSnapshot? status;
      var busy = false;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> runPullback({List<String>? objectKeys}) async {
                if (busy) return;
                setDialogState(() => busy = true);
                try {
                  final next = await controller.triggerPullback(
                    config.sessionId,
                    token: config.token,
                    objectKeys: objectKeys,
                  );
                  if (dialogContext.mounted) {
                    setDialogState(() => status = next);
                  }
                  await refreshDataset();
                } catch (error) {
                  if (mounted) {
                    _showSnackBar(
                      l10n.directUploadPullbackFailedMessage(error),
                    );
                  }
                } finally {
                  if (dialogContext.mounted) {
                    setDialogState(() => busy = false);
                  }
                }
              }

              return DirectUploadDialog(
                config: config,
                status: status,
                busy: busy,
                onClose: () => Navigator.of(dialogContext).pop(),
                onPullback: () => runPullback(),
                onRetry: (objectKey) => runPullback(objectKeys: [objectKey]),
              );
            },
          );
        },
      );

      if (mounted) await refreshDataset();
    } catch (error) {
      if (mounted) {
        final message = error is StateError ? error.message : error.toString();
        _showSnackBar(l10n.directUploadCreateSessionFailedMessage(message));
      }
    }
  }
}
