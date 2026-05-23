import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/layout.dart';
import '../generate_export_utils.dart';
import 'shared_ui.dart';

class CreativePreviewPanel extends StatelessWidget {
  const CreativePreviewPanel({
    required this.selectedCount,
    required this.generated,
    required this.generating,
    super.key,
  });

  final int selectedCount;
  final bool generated;
  final bool generating;

  @override
  Widget build(BuildContext context) {
    final pageCount = estimatedPageCount(selectedCount);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  generated
                      ? AppLocalizations.of(
                          context,
                        )!.generateExportPagePreviewCount(pageCount)
                      : AppLocalizations.of(context)!.generateExportS943,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              StatusChip(
                label: generating
                    ? AppLocalizations.of(context)!.generateExportS718
                    : generated
                    ? AppLocalizations.of(context)!.generateExportS334
                    : AppLocalizations.of(
                        context,
                      )!.contentPreviewWaitingForGenerationLabel,
                color: generating
                    ? const Color(0xff9a5a14)
                    : generated
                    ? const Color(0xff168542)
                    : const Color(0xff7a6a5b),
                background: generating
                    ? const Color(0xfffff4d8)
                    : generated
                    ? const Color(0xffe8f4ea)
                    : const Color(0xfff6f0e8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            generating
                ? AppLocalizations.of(context)!.generateExportS663
                : generated
                ? AppLocalizations.of(context)!.generateExportS420
                : AppLocalizations.of(context)!.generateExportS954,
            style: const TextStyle(color: Color(0xff7a6a5b), height: 1.45),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _PreviewTile(
                title: generated
                    ? AppLocalizations.of(context)!.generateExportS419
                    : AppLocalizations.of(context)!.generateExportS419,
                iconAsset: bookIconAsset,
                active: generated,
              ),
              const SizedBox(width: 12),
              _PreviewTile(
                title: generated
                    ? AppLocalizations.of(context)!.generateExportS790
                    : AppLocalizations.of(context)!.generateExportS548,
                iconAsset: a4FileIconAsset,
                active: generated,
              ),
              const SizedBox(width: 12),
              _PreviewTile(
                title: generated
                    ? AppLocalizations.of(context)!.generateExportS413
                    : AppLocalizations.of(context)!.generateExportS413,
                iconAsset: pdfIconAsset,
                active: generated,
              ),
            ],
          ),
          if (generating) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                minHeight: 8,
                backgroundColor: Color(0xfffff0df),
                color: Color(0xff3f8c55),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.title,
    required this.iconAsset,
    required this.active,
  });

  final String title;
  final String iconAsset;
  final bool active;

  @override
  Widget build(BuildContext context) => Expanded(
    child: AspectRatio(
      aspectRatio: 1.55,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? const Color(0xfffffcf7) : const Color(0xfff6f0e8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffe8dccb)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAssetIcon(iconAsset, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ),
  );
}

class PreviewFailureActionPanel extends StatelessWidget {
  const PreviewFailureActionPanel({
    required this.reason,
    required this.onOpenFolder,
    required this.onViewLog,
    super.key,
  });

  final String reason;
  final VoidCallback? onOpenFolder;
  final VoidCallback onViewLog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trimmedReason = reason.trim();
    return SurfaceCard(
      backgroundColor: const Color(0xfffff4f1),
      borderColor: const Color(0xffffd5cd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.generateExportPreviewFailedTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xff9b3a2b),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.generateExportPreviewFailedBody,
            style: const TextStyle(color: Color(0xff6f6258), height: 1.45),
          ),
          if (trimmedReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.generateExportPreviewFailureReason(trimmedReason),
              style: const TextStyle(
                color: Color(0xff6f6258),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(
                label: l10n.generateExportS518,
                iconAsset: folderIconAsset,
                onPressed: onOpenFolder,
              ),
              SecondaryButton(
                label: l10n.generateExportS624,
                iconAsset: timelineIconAsset,
                onPressed: onViewLog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
