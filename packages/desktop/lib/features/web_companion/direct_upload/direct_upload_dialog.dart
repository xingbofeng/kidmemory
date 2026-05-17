import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'direct_upload_models.dart';
import 'direct_upload_status.dart';

/// Direct Upload session dialog.
///
/// Renders the QR code, child id, bucket/sessionId path, the
/// risk banner, the pull-back action, the close affordance, and the
/// status list of remote objects + their pull-back state.
///
/// The dialog is intentionally driven by a synchronous [status] snapshot to
/// keep widget tests deterministic. Polling, when wired, can be done by the
/// parent and pushed down via [status].
class DirectUploadDialog extends StatelessWidget {
  const DirectUploadDialog({
    required this.config,
    required this.onClose,
    required this.onPullback,
    required this.onRetry,
    this.status,
    this.busy = false,
    super.key,
  });

  final DirectUploadConfig config;
  final DirectUploadStatusSnapshot? status;
  final VoidCallback onClose;
  final Future<void> Function() onPullback;
  final Future<void> Function(String objectKey) onRetry;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final items = status?.items ?? const <DirectUploadStatusItem>[];
    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogHeader(onClose: onClose),
              const SizedBox(height: 12),
              const _RiskBanner(),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoSection(config: config),
                      const SizedBox(height: 18),
                      _SummaryRow(summary: status?.summary),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: busy ? null : () => onPullback(),
                            icon: const Icon(Icons.cloud_download_outlined),
                            label: const Text('拉回本地'),
                          ),
                          const SizedBox(width: 12),
                          if (busy)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '回拉状态',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DirectUploadStatusList(items: items, onRetry: onRetry),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '扫码上传 · Direct',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        IconButton(
          tooltip: '关闭',
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _RiskBanner extends StatelessWidget {
  const _RiskBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xfffff4d6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5b94f)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.warning_amber_outlined, color: Color(0xffb38018)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Supabase 直传验证版 — 对象需电脑端回拉后才算入库',
              style: TextStyle(
                color: Color(0xff6c4a07),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.config});

  final DirectUploadConfig config;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QrCodeCard(data: config.publicUrl),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '孩子：${config.childId}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff324737),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '会话路径',
                style: TextStyle(color: Color(0xff6f8d72), fontSize: 12),
              ),
              SelectableText(
                config.sessionPath,
                style: const TextStyle(fontFamily: 'Menlo', fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Text(
                '扫码或复制链接',
                style: TextStyle(color: Color(0xff6f8d72), fontSize: 12),
              ),
              SelectableText(
                config.publicUrl,
                style: const TextStyle(fontFamily: 'Menlo', fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                '建议每次≤${config.recommendedClientLimit}张 · 仅为体验约束，并非安全约束',
                style: const TextStyle(color: Color(0xff6f8d72), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrCodeCard extends StatelessWidget {
  const _QrCodeCard({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 168,
      decoration: BoxDecoration(
        color: const Color(0xfff7f5ee),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffd9d6cb)),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Semantics(
        label: 'Direct Upload 扫码链接二维码',
        value: data,
        image: true,
        child: QrImageView(
          key: ValueKey<String>('direct-upload-qr:$data'),
          data: data,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(0xff324737),
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(0xff324737),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({this.summary});

  final DirectUploadStatusSummary? summary;

  @override
  Widget build(BuildContext context) {
    final s =
        summary ??
        DirectUploadStatusSummary(
          pendingRemote: 0,
          downloading: 0,
          ready: 0,
          failed: 0,
        );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SummaryChip(label: '等待回拉', value: s.pendingRemote),
        _SummaryChip(label: '回拉中', value: s.downloading),
        _SummaryChip(label: '已入库', value: s.ready),
        _SummaryChip(label: '失败', value: s.failed),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xfff2f5ee),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label · $value',
        style: const TextStyle(fontSize: 12, color: Color(0xff324737)),
      ),
    );
  }
}
