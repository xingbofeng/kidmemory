import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

import 'trusted_upload_controller.dart';
import 'trusted_upload_models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';

/// Trusted Upload dialog.
///
/// Shows QR/link access, session information, item status, and close controls.
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
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchStatus();
    });
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
            content: Text(
              AppLocalizations.of(context)!.trustedUploadCloseSessionFailed(e),
            ),
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
            content: Text(
              AppLocalizations.of(context)!.trustedUploadRetryFailed(e),
            ),
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
        content: Text(
          AppLocalizations.of(context)!.trustedUploadSessionNotReadyMessage,
        ),
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
            Row(
              children: [
                const AppAssetIcon(uploadIconAsset, size: 32),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.trustedUploadDialogTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const AppAssetIcon(stopIconAsset, size: 18),
                  onPressed: _handleClose,
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  AppAssetIcon(infoIconAsset, size: 22),
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

            _buildSessionInfo(session),
            const SizedBox(height: 16),

            _buildQRCodeSection(session),
            const SizedBox(height: 16),

            if (_status != null) _buildStatusSummary(_status!),
            const SizedBox(height: 16),

            Expanded(child: _buildItemsList()),
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
        const AppAssetIcon(timeIconAsset, size: 20),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(
            context,
          )!.trustedUploadRemainingMinutes(remainingMinutes),
        ),
        const SizedBox(width: 24),
        const AppAssetIcon(uploadIconAsset, size: 20),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context)!.trustedUploadMaxItems(session.maxItems),
        ),
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
                icon: const AppAssetIcon(linkIconAsset, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: session.webUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.trustedUploadCopiedMessage,
                      ),
                    ),
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
            const AppAssetIcon(stopIconAsset, size: 48),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(
                context,
              )!.trustedUploadLoadFailed(_error ?? ''),
            ),
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
      return Center(
        child: Text(AppLocalizations.of(context)!.trustedUploadNoItemsMessage),
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
    String iconAsset;

    if (item.isReady) {
      iconAsset = completeIconAsset;
    } else if (item.isFailed) {
      iconAsset = stopIconAsset;
    } else if (item.isPulling) {
      iconAsset = downloadIconAsset;
    } else if (item.isUploading) {
      iconAsset = cloudUploadIconAsset;
    } else {
      iconAsset = timeIconAsset;
    }

    return ListTile(
      leading: AppAssetIcon(iconAsset, size: 24),
      title: Text(item.filename),
      subtitle: Text(
        item.isFailed && item.errorMessage != null
            ? AppLocalizations.of(
                context,
              )!.trustedUploadItemFailed(item.errorMessage!)
            : item.status,
      ),
      trailing: item.isFailed
          ? IconButton(
              icon: const AppAssetIcon(refreshIconAsset, size: 20),
              onPressed: () => _handleRetry(item.uploadItemId),
            )
          : null,
    );
  }
}
