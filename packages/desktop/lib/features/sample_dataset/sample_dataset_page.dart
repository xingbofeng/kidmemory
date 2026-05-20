import 'package:flutter/material.dart';

import '../../shared/widgets/chrome.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/layout.dart';
import '../../../l10n/app_localizations.dart';

class SampleDatasetPage extends StatelessWidget {
  const SampleDatasetPage({
    required this.imported,
    required this.onImport,
    required this.previewAssets,
    required this.artworkCount,
    required this.craftCount,
    required this.photoCount,
    required this.tagCount,
    required this.onReset,
    required this.onOpenSamplePdf,
    required this.onBrowseSampleAssets,
    required this.onGenerateSampleBook,
    required this.importing,
    this.onBack,
    this.importFailed = false,
    super.key,
  });

  final bool imported;
  final bool importing;
  final bool importFailed;
  final VoidCallback onImport;
  final List<AssetPreviewItem> previewAssets;
  final int artworkCount;
  final int craftCount;
  final int photoCount;
  final int tagCount;
  final VoidCallback onReset;
  final VoidCallback onOpenSamplePdf;
  final VoidCallback onBrowseSampleAssets;
  final VoidCallback onGenerateSampleBook;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final assets = previewAssets;
    final displayAssets = assets.isEmpty
        ? _samplePreviewPlaceholders(context)
        : assets;
    final samplePreviewOnly = assets.isEmpty;
    final counts = {
      "artwork": samplePreviewOnly ? _sampleArtworkCount : artworkCount,
      "craft": samplePreviewOnly ? _sampleCraftCount : craftCount,
      "photo": samplePreviewOnly ? _samplePhotoCount : photoCount,
    };
    final totalCount = samplePreviewOnly ? _sampleAssetCount : assets.length;
    final effectiveTagCount = samplePreviewOnly ? _sampleTagCount : tagCount;

    return PageFrame(
      title: AppLocalizations.of(context)!.sampleDatasetPageTitle,
      subtitle: AppLocalizations.of(context)!.sampleDatasetPageSubtitle,
      leading: onBack == null
          ? null
          : PageBackButton(
              tooltip: AppLocalizations.of(context)!.sampleDatasetBackTooltip,
              onPressed: onBack!,
            ),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  MetricStrip(
                    metrics: [
                      (
                        l10n.contentMetricTotalLabel,
                        l10n.contentMetricItemCount(totalCount),
                      ),
                      (
                        l10n.contentCategoryArtworkLabel,
                        l10n.contentMetricImageCount(counts['artwork'] ?? 0),
                      ),
                      (
                        l10n.contentCategoryCraftLabel,
                        l10n.contentMetricCraftCount(counts['craft'] ?? 0),
                      ),
                      (l10n.contentLicenseLabel, 'CC0'),
                      (
                        l10n.contentAssetTypePhotoLabel,
                        l10n.contentMetricImageCount(counts['photo'] ?? 0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AssetPreviewGrid(compact: true, items: displayAssets),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: SmallInfoCard(
                          iconAsset: infoIconAsset,
                          title: AppLocalizations.of(
                            context,
                          )!.sampleDatasetInfoCardTitle,
                          text: AppLocalizations.of(
                            context,
                          )!.sampleDatasetInfoCardDescription,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: SmallInfoCard(
                          iconAsset: uploadIconAsset,
                          title: AppLocalizations.of(
                            context,
                          )!.sampleDatasetImportStepsTitle,
                          text: AppLocalizations.of(
                            context,
                          )!.sampleDatasetImportStepsDescription,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: SmallInfoCard(
                          iconAsset: pdfIconAsset,
                          title: AppLocalizations.of(
                            context,
                          )!.sampleDatasetExpectedOutputTitle,
                          text: AppLocalizations.of(
                            context,
                          )!.sampleDatasetExpectedOutputDescription,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 22),
            SizedBox(
              width: 320,
              child: Column(
                children: [
                  SidePanel(
                    title: AppLocalizations.of(
                      context,
                    )!.sampleDatasetAfterImportDescriptionTitle,
                    artworkCount: counts['artwork'] ?? 0,
                    craftCount: counts['craft'] ?? 0,
                    photoCount: counts['photo'] ?? 0,
                    tagCount: effectiveTagCount,
                  ),
                  const SizedBox(height: 14),
                  _SampleActionPanel(
                    imported: imported,
                    importing: importing,
                    importFailed: importFailed,
                    onImport: onImport,
                    onBrowseSampleAssets: onBrowseSampleAssets,
                    onGenerateSampleBook: onGenerateSampleBook,
                    onOpenSamplePdf: onOpenSamplePdf,
                    onReset: onReset,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<AssetPreviewItem> _samplePreviewPlaceholders(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return [
    AssetPreviewItem(
      label: l10n.sampleDatasetPlaceholderSunlightGardenLabel,
      icon: Icons.photo_camera_rounded,
      typeLabel: l10n.contentAssetTypePhotoLabel,
      iconAsset: cameraIconAsset,
      path: l10n.sampleDatasetPlaceholderSunlightGardenPath,
    ),
    AssetPreviewItem(
      label: l10n.sampleDatasetPlaceholderGrassFieldLabel,
      icon: Icons.photo_camera_rounded,
      typeLabel: l10n.contentAssetTypePhotoLabel,
      iconAsset: cameraIconAsset,
      path: l10n.sampleDatasetPlaceholderGrassFieldPath,
    ),
    AssetPreviewItem(
      label: l10n.sampleDatasetPlaceholderBirthdayCakeLabel,
      icon: Icons.photo_camera_rounded,
      typeLabel: l10n.contentAssetTypePhotoLabel,
      iconAsset: cameraIconAsset,
      path: l10n.sampleDatasetPlaceholderBirthdayCakePath,
    ),
    AssetPreviewItem(
      label: l10n.sampleDatasetPlaceholderBirthdayBoyLabel,
      icon: Icons.photo_camera_rounded,
      typeLabel: l10n.contentAssetTypePhotoLabel,
      iconAsset: cameraIconAsset,
      path: l10n.sampleDatasetPlaceholderBirthdayBoyPath,
    ),
    AssetPreviewItem(
      label: l10n.sampleDatasetPlaceholderOceanWorldLabel,
      icon: Icons.photo_camera_rounded,
      typeLabel: l10n.contentAssetTypePhotoLabel,
      iconAsset: cameraIconAsset,
      path: l10n.sampleDatasetPlaceholderOceanWorldPath,
    ),
    AssetPreviewItem(
      label: l10n.sampleDatasetPlaceholderDinosaurWorldLabel,
      icon: Icons.photo_camera_rounded,
      typeLabel: l10n.contentAssetTypePhotoLabel,
      iconAsset: cameraIconAsset,
      path: l10n.sampleDatasetPlaceholderDinosaurWorldPath,
    ),
    AssetPreviewItem(
      label: l10n.sampleDatasetPlaceholderHappinessFamilyLabel,
      icon: Icons.photo_camera_rounded,
      typeLabel: l10n.contentAssetTypePhotoLabel,
      iconAsset: cameraIconAsset,
      path: l10n.sampleDatasetPlaceholderHappinessFamilyPath,
    ),
    AssetPreviewItem(
      label: l10n.sampleDatasetPlaceholderDrawingLabel,
      icon: Icons.photo_camera_rounded,
      typeLabel: l10n.contentAssetTypePhotoLabel,
      iconAsset: cameraIconAsset,
      path: l10n.sampleDatasetPlaceholderDrawingPath,
    ),
  ];
}

const _sampleAssetCount = 17;
const _sampleArtworkCount = 6;
const _sampleCraftCount = 2;
const _samplePhotoCount = 9;
const _sampleTagCount = 31;

class _SampleActionPanel extends StatelessWidget {
  const _SampleActionPanel({
    required this.imported,
    required this.importing,
    required this.importFailed,
    required this.onImport,
    required this.onBrowseSampleAssets,
    required this.onGenerateSampleBook,
    required this.onOpenSamplePdf,
    required this.onReset,
  });

  final bool imported;
  final bool importing;
  final bool importFailed;
  final VoidCallback onImport;
  final VoidCallback onBrowseSampleAssets;
  final VoidCallback onGenerateSampleBook;
  final VoidCallback onOpenSamplePdf;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    if (importing) {
      return Column(
        children: [
          _SampleStatusCard(
            iconAsset: uploadIconAsset,
            title: AppLocalizations.of(
              context,
            )!.sampleDatasetImportingStatusTitle,
            text: AppLocalizations.of(
              context,
            )!.sampleDatasetImportingStatusDescription,
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: AppLocalizations.of(
              context,
            )!.sampleDatasetImportingActionLabel,
            icon: Icons.hourglass_top_rounded,
            iconAsset: uploadIconAsset,
            onPressed: null,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: AppLocalizations.of(context)!.sampleDatasetViewPdfLabel,
            icon: Icons.picture_as_pdf_rounded,
            iconAsset: pdfIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: null,
          ),
        ],
      );
    }

    if (imported) {
      return Column(
        children: [
          _SampleStatusCard(
            iconAsset: completeIconAsset,
            title: AppLocalizations.of(context)!.sampleDatasetImportedTitle,
            text: AppLocalizations.of(context)!.sampleDatasetImportedStatusText,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: AppLocalizations.of(context)!.sampleDatasetBrowseAssetsLabel,
            icon: Icons.grid_view_rounded,
            iconAsset: gridIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: onBrowseSampleAssets,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: AppLocalizations.of(
              context,
            )!.sampleDatasetGenerateSampleBookLabel,
            icon: Icons.auto_awesome_rounded,
            iconAsset: wandIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: onGenerateSampleBook,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: AppLocalizations.of(context)!.sampleDatasetViewPdfLabel,
            icon: Icons.picture_as_pdf_rounded,
            iconAsset: pdfIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: onOpenSamplePdf,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: AppLocalizations.of(context)!.sampleDatasetResetDataLabel,
            icon: Icons.refresh_rounded,
            iconAsset: refreshIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: onReset,
          ),
        ],
      );
    }

    if (importFailed) {
      return Column(
        children: [
          _SampleStatusCard(
            iconAsset: infoIconAsset,
            title: AppLocalizations.of(context)!.sampleDatasetImportFailedTitle,
            text: AppLocalizations.of(context)!.sampleDatasetResetDataHint,
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: AppLocalizations.of(
              context,
            )!.sampleDatasetRetryImportButtonLabel,
            icon: Icons.refresh_rounded,
            iconAsset: refreshIconAsset,
            onPressed: onImport,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: AppLocalizations.of(context)!.sampleDatasetViewPdfLabel,
            icon: Icons.picture_as_pdf_rounded,
            iconAsset: pdfIconAsset,
            fullWidth: true,
            height: 58,
            onPressed: null,
          ),
        ],
      );
    }

    return Column(
      children: [
        _SampleStatusCard(
          iconAsset: infoIconAsset,
          title: AppLocalizations.of(context)!.sampleDatasetNotImportedTitle,
          text: AppLocalizations.of(
            context,
          )!.sampleDatasetImportInstructionText,
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: AppLocalizations.of(context)!.sampleDatasetImportButtonLabel,
          icon: Icons.upload_rounded,
          iconAsset: uploadIconAsset,
          onPressed: onImport,
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: AppLocalizations.of(context)!.sampleDatasetViewPdfLabel,
          icon: Icons.picture_as_pdf_rounded,
          iconAsset: pdfIconAsset,
          fullWidth: true,
          height: 58,
          onPressed: null,
        ),
      ],
    );
  }
}

class _SampleStatusCard extends StatelessWidget {
  const _SampleStatusCard({
    required this.iconAsset,
    required this.title,
    required this.text,
  });

  final String iconAsset;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xfffffcf6),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xffeadfce)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAssetIcon(iconAsset, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff28170f),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xff766b61),
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
