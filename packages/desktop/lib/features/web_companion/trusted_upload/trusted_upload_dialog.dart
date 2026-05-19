import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

import 'trusted_upload_controller.dart';
import 'trusted_upload_models.dart';
import '../../../../l10n/app_localizations.dart';

/// Trusted Upload 对话框
///
/// 显示：
/// - 二维码（或可复制的 URL）
/// - 会话信息（过期时间、上传数量）
/// - 上传项状态列表
/// - 关闭会话按钮
class TrustedUploadDialog extends StatefulWidget {
  const TrustedUploadDialog({
    required this.controller,
    required this.onClose,
    super.key,
  });

  final TrustedUploadController controller;
  final VoidCallback onClose;

  @override
  State<TrustedUploadDialog> createState() => _TrustedUploadDialogState();
}

class _TrustedUploadDialogState extends State<TrustedUploadDialog> {
  TrustedUploadStatus? _status;
  Timer? _pollTimer;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // 每 3 秒轮询一次状态
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchStatus();
    });
    // 立即获取一次
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final status = await widget.controller.fetchStatus();
      if (mounted) {
        setState(() {
          _status = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleClose() async {
    try {
      await widget.controller.closeSession();
      widget.onClose();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('关闭会话失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRetry(String uploadItemId) async {
    try {
      await widget.controller.retryItem(uploadItemId);
      await _fetchStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重试失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session;
    if (session == null) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.errorTitle),
        content: Text(AppLocalizations.of(context)!.trustedUploadSessionNotReadyMessage),
      );
    }

    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              children: [
                const Icon(Icons.qr_code_2, size: 32),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.trustedUploadDialogTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _handleClose,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 说明横幅
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.trustedUploadDescription,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 会话信息
            _buildSessionInfo(session),
            const SizedBox(height: 16),

            // 二维码或 URL
            _buildQRCodeSection(session),
            const SizedBox(height: 16),

            // 状态统计
            if (_status != null) _buildStatusSummary(_status!),
            const SizedBox(height: 16),

            // 上传项列表
            Expanded(
              child: _buildItemsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(TrustedUploadSession session) {
    final now = DateTime.now();
    final remaining = session.expiresAt.difference(now);
    final remainingMinutes = remaining.inMinutes;

    return Row(
      children: [
        const Icon(Icons.timer_outlined, size: 20),
        const SizedBox(width: 8),
        Text('剩余时间: $remainingMinutes 分钟'),
        const SizedBox(width: 24),
        const Icon(Icons.upload_outlined, size: 20),
        const SizedBox(width: 8),
        Text('上限: ${session.maxItems} 张'),
      ],
    );
  }

  Widget _buildQRCodeSection(TrustedUploadSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.trustedUploadCopyOrScanLabel,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 180,
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: QrImageView(
                  data: session.webUrl,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SelectableText(
                  session.webUrl,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: session.webUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.trustedUploadNetworkHint,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(TrustedUploadStatus status) {
    return Row(
      children: [
        _buildStatusChip(
          AppLocalizations.of(context)!.uploadStatusTotalLabel,
          status.totalCount,
          Colors.grey,
        ),
        const SizedBox(width: 8),
        _buildStatusChip(
          AppLocalizations.of(context)!.uploadStatusWaitingLabel,
          status.pendingCount,
          Colors.orange,
        ),
        const SizedBox(width: 8),
        _buildStatusChip(
          AppLocalizations.of(context)!.uploadStatusUploadingLabel,
          status.uploadingCount,
          Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildStatusChip(
          AppLocalizations.of(context)!.uploadStatusPullingLabel,
          status.pullingCount,
          Colors.purple,
        ),
        const SizedBox(width: 8),
        _buildStatusChip(
          AppLocalizations.of(context)!.uploadStatusReadyLabel,
          status.readyCount,
          Colors.green,
        ),
        const SizedBox(width: 8),
        _buildStatusChip(
          AppLocalizations.of(context)!.uploadStatusFailedLabel,
          status.failedCount,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildItemsList() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchStatus,
              child: Text(AppLocalizations.of(context)!.actionRetryLabel),
            ),
          ],
        ),
      );
    }

    if (_status == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_status!.items.isEmpty) {
      return const Center(
        child: Text('暂无上传项\n请在手机端选择图片上传'),
      );
    }

    return ListView.builder(
      itemCount: _status!.items.length,
      itemBuilder: (context, index) {
        final item = _status!.items[index];
        return _buildItemTile(item);
      },
    );
  }

  Widget _buildItemTile(TrustedUploadItem item) {
    IconData icon;
    Color color;

    if (item.isReady) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (item.isFailed) {
      icon = Icons.error;
      color = Colors.red;
    } else if (item.isPulling) {
      icon = Icons.download;
      color = Colors.purple;
    } else if (item.isUploading) {
      icon = Icons.cloud_upload;
      color = Colors.blue;
    } else {
      icon = Icons.pending;
      color = Colors.orange;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(item.filename),
      subtitle: Text(
        item.isFailed && item.errorMessage != null
            ? '失败: ${item.errorMessage}'
            : item.status,
      ),
      trailing: item.isFailed
          ? IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _handleRetry(item.uploadItemId),
            )
          : null,
    );
  }
}
