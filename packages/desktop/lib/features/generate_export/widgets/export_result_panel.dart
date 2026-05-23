import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/layout.dart';
import '../generate_export_models.dart';
import '../generate_export_utils.dart';

class ExportResultPanel extends StatelessWidget {
  const ExportResultPanel({
    required this.generated,
    required this.shareCreating,
    this.result,
    this.onOpenExportFolder,
    this.onCreateShareLink,
    this.onCopyShareText,
    this.onOpenShareLink,
    this.onCopyLongImage,
    this.onViewLogDetails,
    super.key,
  });

  final bool generated;
  final bool shareCreating;
  final ExportResultVm? result;
  final VoidCallback? onOpenExportFolder;
  final VoidCallback? onCreateShareLink;
  final VoidCallback? onCopyShareText;
  final VoidCallback? onOpenShareLink;
  final VoidCallback? onCopyLongImage;
  final VoidCallback? onViewLogDetails;

  @override
  Widget build(BuildContext context) {
    final current = result;
    if (!generated && current == null) {
      return SurfaceCard(
        backgroundColor: const Color(0xfff6f0e8),
        borderColor: const Color(0xffeadbc9),
        child: Row(
          children: [
            const AppAssetIcon(downloadIconAsset, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.generateExportS735,
                style: const TextStyle(
                  color: Color(0xff7a6a5b),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final hasLocalFile = current?.localPath.trim().isNotEmpty == true;
    final hasShare = current?.shareText.trim().isNotEmpty == true;
    final hasShareUrl = current?.remoteUrl.trim().isNotEmpty == true;
    final canCopyImage = current?.isLongImage == true && hasLocalFile;
    final shareFailed =
        !shareCreating &&
        hasLocalFile &&
        current?.artifactId.trim().isNotEmpty == true &&
        !hasShareUrl &&
        (current?.errorReason.trim().contains(
              AppLocalizations.of(context)!.generateExportShareFailedStatus,
            ) ??
            false);
    final exportFailed =
        !shareCreating &&
        !hasLocalFile &&
        current?.storageStatus.trim() == 'failed' &&
        (current?.errorReason.trim().isNotEmpty ?? false);
    final status = current == null
        ? (generated
              ? AppLocalizations.of(context)!.generateExportS794
              : AppLocalizations.of(context)!.generateExportS724)
        : storageStatusLabel(context, current.storageStatus);
    final remoteStatus = current == null
        ? AppLocalizations.of(context)!.generateExportS723
        : shareCreating
        ? AppLocalizations.of(context)!.generateExportShareCreatingStatus
        : shareFailed
        ? AppLocalizations.of(context)!.generateExportShareFailedStatus
        : current.remoteUrl.trim().isNotEmpty
        ? AppLocalizations.of(context)!.generateExportShareCreatedStatus
        : hasShare
        ? AppLocalizations.of(context)!.generateExportS329
        : AppLocalizations.of(context)!.generateExportS220;
    final error = current?.errorReason.trim() ?? '';

    return SurfaceCard(
      backgroundColor: current == null
          ? const Color(0xfff6f0e8)
          : const Color(0xfff4fbf8),
      borderColor: current == null
          ? const Color(0xffeadbc9)
          : const Color(0xffcdebd6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppAssetIcon(cloudUploadIconAsset, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.generateExportS418,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                status,
                style: const TextStyle(
                  color: Color(0xff31564a),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 28,
            runSpacing: 8,
            children: [
              _ExportFact(
                label: AppLocalizations.of(context)!.generateExportS611,
                value: hasLocalFile
                    ? current!.localPath
                    : AppLocalizations.of(context)!.generateExportS428,
              ),
              _ExportFact(
                label: AppLocalizations.of(context)!.generateExportS218,
                value: status,
              ),
              _ExportFact(
                label: AppLocalizations.of(context)!.generateExportS274,
                value: remoteStatus,
              ),
              if (error.isNotEmpty)
                _ExportFact(
                  label: AppLocalizations.of(context)!.generateExportS930,
                  value: error,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(
                label: AppLocalizations.of(context)!.generateExportS518,
                iconAsset: folderIconAsset,
                onPressed: hasLocalFile ? onOpenExportFolder : null,
              ),
              SecondaryButton(
                label: hasShare
                    ? AppLocalizations.of(context)!.generateExportS357
                    : hasShareUrl
                    ? AppLocalizations.of(context)!.generateExportCopyLinkLabel
                    : shareFailed
                    ? AppLocalizations.of(
                        context,
                      )!.generateExportRetryShareLabel
                    : AppLocalizations.of(
                        context,
                      )!.generateExportCreateShareLinkLabel,
                iconAsset: linkIconAsset,
                onPressed: hasShare || hasShareUrl
                    ? onCopyShareText
                    : hasLocalFile && !shareCreating
                    ? onCreateShareLink
                    : null,
              ),
              if (hasShareUrl)
                SecondaryButton(
                  label: AppLocalizations.of(
                    context,
                  )!.generateExportOpenLinkLabel,
                  iconAsset: viewIconAsset,
                  onPressed: onOpenShareLink,
                ),
              if (shareFailed || exportFailed)
                SecondaryButton(
                  label: AppLocalizations.of(context)!.generateExportS624,
                  iconAsset: infoIconAsset,
                  onPressed: onViewLogDetails,
                ),
              SecondaryButton(
                label: AppLocalizations.of(context)!.generateExportS358,
                iconAsset: imageFileIconAsset,
                onPressed: canCopyImage ? onCopyLongImage : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _actionReason(
              context,
              hasLocalFile: hasLocalFile,
              hasShare: hasShare,
              canCopyImage: canCopyImage,
              result: current,
              shareCreating: shareCreating,
            ),
            style: const TextStyle(color: Color(0xff8c7663), fontSize: 12),
          ),
          if (shareCreating) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.generateExportShareCreatingStatus,
              style: const TextStyle(
                color: Color(0xff31564a),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (current?.shareText.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              current!.shareText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff31564a),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _actionReason(
    BuildContext context, {
    required bool hasLocalFile,
    required bool hasShare,
    required bool canCopyImage,
    required ExportResultVm? result,
    required bool shareCreating,
  }) {
    if (!hasLocalFile) return AppLocalizations.of(context)!.generateExportS411;
    if (shareCreating) {
      return AppLocalizations.of(context)!.generateExportShareCreatingStatus;
    }
    if (!hasShare && result?.remoteUrl.trim().isEmpty != false) {
      return AppLocalizations.of(context)!.generateExportShareReadyHint;
    }
    if (!canCopyImage) return AppLocalizations.of(context)!.generateExportS476;
    return AppLocalizations.of(context)!.generateExportS275;
  }
}

class _ExportFact extends StatelessWidget {
  const _ExportFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Text(
      '$label：$value',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xff5d5148),
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
