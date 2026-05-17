import 'package:flutter/material.dart';
import '../../../core/sidecar/sidecar_api.dart';
import 'trusted_upload_controller.dart';
import 'trusted_upload_dialog.dart';

/// Trusted Upload 入口按钮
///
/// 与 Direct Upload 的区别：
/// - 使用后端可信会话（token hash、过期时间、数量限制）
/// - 支持 signed upload target
/// - 支持 pullback worker 自动入库
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
      icon: const Icon(Icons.qr_code_2),
      label: const Text('扫码上传'),
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
      // 创建上传会话
      await controller.createSession();

      if (!context.mounted) return;

      // 显示对话框
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
          content: Text('创建上传会话失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
