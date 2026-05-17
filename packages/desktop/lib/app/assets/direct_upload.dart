part of '../desktop_shell.dart';

extension _DesktopShellDirectUpload on _DesktopShellState {
  Future<void> _openDirectUploadDialog() async {
    final childId = selectedChildId;
    if (childId == null || childId.isEmpty) {
      _showSnackBar('请先选择一个孩子再创建扫码上传会话');
      return;
    }

    final controller = DirectUploadController(api: api);
    try {
      _showSnackBar('正在创建 Direct Upload 扫码会话...');
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
                    _showSnackBar('Direct Upload 回拉失败：$error');
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
        _showSnackBar('创建 Direct Upload 会话失败：$message');
      }
    }
  }
}
