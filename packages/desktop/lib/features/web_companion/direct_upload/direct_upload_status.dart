import 'package:flutter/material.dart';

import 'direct_upload_models.dart';

/// Renders the pull-back status rows produced by the sidecar status
/// endpoint. Each row reflects one of the four states defined by the
/// state machine: `pending_remote`, `downloading`, `ready`, `failed`.
class DirectUploadStatusList extends StatelessWidget {
  const DirectUploadStatusList({
    required this.items,
    required this.onRetry,
    super.key,
  });

  final List<DirectUploadStatusItem> items;
  final Future<void> Function(String objectKey) onRetry;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '暂无远端对象，请先在手机端扫码上传',
          style: TextStyle(color: Color(0xff6f8d72)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          _DirectUploadStatusRow(item: item, onRetry: onRetry),
      ],
    );
  }
}

class _DirectUploadStatusRow extends StatelessWidget {
  const _DirectUploadStatusRow({required this.item, required this.onRetry});

  final DirectUploadStatusItem item;
  final Future<void> Function(String objectKey) onRetry;

  @override
  Widget build(BuildContext context) {
    final descriptor = _describe(item);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 24, height: 24, child: descriptor.leading),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      descriptor.statusLabel,
                      style: TextStyle(
                        color: descriptor.statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        descriptor.identifier,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff324737),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (descriptor.detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    descriptor.detail!,
                    style: const TextStyle(
                      color: Color(0xffc0392b),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.status == 'failed') ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => onRetry(item.objectKey),
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }

  _RowDescriptor _describe(DirectUploadStatusItem item) {
    switch (item.status) {
      case 'pending_remote':
        return _RowDescriptor(
          leading: const Icon(
            Icons.cloud_queue_outlined,
            color: Color(0xff6f8d72),
            size: 22,
          ),
          statusLabel: '等待回拉',
          statusColor: const Color(0xff6f8d72),
          identifier: item.displayName,
        );
      case 'downloading':
        return _RowDescriptor(
          leading: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          statusLabel: '回拉中',
          statusColor: const Color(0xff2f80ed),
          identifier: item.displayName,
        );
      case 'ready':
        return _RowDescriptor(
          leading: const Icon(
            Icons.check_circle_outline,
            color: Color(0xff2faa61),
            size: 22,
          ),
          statusLabel: '已入库',
          statusColor: const Color(0xff2faa61),
          identifier: item.assetId ?? item.displayName,
        );
      case 'failed':
        return _RowDescriptor(
          leading: const Icon(
            Icons.error_outline,
            color: Color(0xffc0392b),
            size: 22,
          ),
          statusLabel: '回拉失败',
          statusColor: const Color(0xffc0392b),
          identifier: item.displayName,
          detail: item.errorMessage ?? item.errorCode ?? '未知错误',
        );
      default:
        return _RowDescriptor(
          leading: const Icon(
            Icons.info_outline,
            color: Color(0xff6f8d72),
            size: 22,
          ),
          statusLabel: item.status,
          statusColor: const Color(0xff324737),
          identifier: item.displayName,
        );
    }
  }
}

class _RowDescriptor {
  _RowDescriptor({
    required this.leading,
    required this.statusLabel,
    required this.statusColor,
    required this.identifier,
    this.detail,
  });

  final Widget leading;
  final String statusLabel;
  final Color statusColor;
  final String identifier;
  final String? detail;
}
