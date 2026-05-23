import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/content.dart';
import '../../../shared/widgets/layout.dart';
import '../generate_export_assets.dart';
import '../generate_export_models.dart';
import '../generate_export_utils.dart';
import 'shared_ui.dart';

class GenerateSettingsPanel extends StatelessWidget {
  const GenerateSettingsPanel({
    required this.generated,
    required this.generating,
    required this.exported,
    required this.creationPhase,
    required this.selectedCount,
    required this.templateText,
    required this.creationTypeText,
    required this.sizeText,
    required this.styleText,
    required this.exportText,
    required this.exportTargets,
    required this.onGenerate,
    required this.onConfirmPlan,
    required this.onExport,
    required this.onExportTargetChanged,
    required this.onViewSelectedAssets,
    required this.onPreviewAllPages,
    super.key,
  });

  final bool generated;
  final bool generating;
  final bool exported;
  final CreationWorkflowPhase creationPhase;
  final int selectedCount;
  final String templateText;
  final String creationTypeText;
  final String sizeText;
  final String styleText;
  final String exportText;
  final List<String> exportTargets;
  final VoidCallback? onGenerate;
  final VoidCallback onConfirmPlan;
  final VoidCallback onExport;
  final ValueChanged<String> onExportTargetChanged;
  final VoidCallback? onViewSelectedAssets;
  final VoidCallback onPreviewAllPages;

  @override
  Widget build(BuildContext context) {
    if (!generated &&
        !exported &&
        creationPhase == CreationWorkflowPhase.preparing) {
      return _CreationSidebarSummary(selectedCount: selectedCount);
    }
    final exportLabel = exportDisplayName(context, exportText);
    final hasAssets = selectedCount > 0;
    final planReady = creationPhase == CreationWorkflowPhase.planReady;
    final subtitle = generated
        ? AppLocalizations.of(
            context,
          )!.generateExportReadyToExportSubtitle(exportLabel)
        : planReady
        ? AppLocalizations.of(context)!.creationPlanReadySubtitle
        : AppLocalizations.of(context)!.generateExportS871;
    final primaryLabel = generated
        ? (exported
              ? AppLocalizations.of(
                  context,
                )!.generateExportExportedState(exportLabel)
              : exportButtonLabel(context, exportText))
        : planReady
        ? AppLocalizations.of(context)!.creationConfirmPlanAction
        : (generating
              ? creationPhaseLabel(context, creationPhase)
              : AppLocalizations.of(
                  context,
                )!.generateExportStartPlanningAction);
    final primaryAction = generating
        ? null
        : (generated ? onExport : (planReady ? onConfirmPlan : onGenerate));
    final primaryIcon = generated ? pdfIconAsset : addIconAsset;
    final previewsVideo = isMp4ExportTarget(context, exportText);

    return SurfaceCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.generateExportS741,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Color(0xff6f6258))),
            const SizedBox(height: 18),
            _ReadinessSummary(
              selectedCount: selectedCount,
              generated: generated,
              exported: exported,
            ),
            const SizedBox(height: 20),
            _SettingRow(
              title: AppLocalizations.of(context)!.generateExportS279,
              value: creationTypeText,
              iconAsset: bookIconAsset,
            ),
            ExportOption(
              title: AppLocalizations.of(context)!.generateExportS644,
              value: compactGenerationOption(context, templateText),
              iconAsset: imageIconAsset,
            ),
            ExportOption(
              title: AppLocalizations.of(context)!.generateExportS942,
              value: compactGenerationOption(context, sizeText),
              iconAsset: a4FileIconAsset,
            ),
            ExportOption(
              title: AppLocalizations.of(context)!.generateExportS553,
              value: compactGenerationOption(context, styleText),
              iconAsset: brushIconAsset,
            ),
            ExportTargetSelector(
              value: exportText,
              options: exportTargets,
              onChanged: onExportTargetChanged,
            ),
            PrimaryButton(
              label: primaryLabel,
              onPressed: primaryAction,
              iconAsset: primaryIcon,
            ),
            const SizedBox(height: 14),
            generated
                ? SecondaryButton(
                    label: generating
                        ? AppLocalizations.of(context)!.generateExportS719
                        : AppLocalizations.of(context)!.generateExportS921,
                    iconAsset: refreshIconAsset,
                    fullWidth: true,
                    height: 48,
                    onPressed: generating ? null : onGenerate,
                  )
                : SecondaryButton(
                    label: AppLocalizations.of(context)!.generateExportS623,
                    iconAsset: gridIconAsset,
                    fullWidth: true,
                    height: 48,
                    onPressed: hasAssets ? onViewSelectedAssets : null,
                  ),
            if (!generated && !hasAssets) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.generateExportS860,
                style: TextStyle(
                  color: Color(0xff9a5a14),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 14),
            if (generated) ...[
              SecondaryButton(
                label: previewsVideo
                    ? AppLocalizations.of(
                        context,
                      )!.generateExportOpenVideoPreviewAction
                    : AppLocalizations.of(context)!.generateExportS951,
                iconAsset: previewsVideo ? playIconAsset : viewIconAsset,
                fullWidth: true,
                height: 48,
                onPressed: onPreviewAllPages,
              ),
              const SizedBox(height: 22),
              Text(
                AppLocalizations.of(
                  context,
                )!.generateExportDirectoryHint(exportLabel),
                style: const TextStyle(color: Color(0xffa57a3a), fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CreationSidebarSummary extends StatelessWidget {
  const _CreationSidebarSummary({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_rounded,
                size: 20,
                color: Color(0xff8d6f55),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.generateExportCreationSummaryTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SummaryStateTile(
            iconAsset: bookIconAsset,
            tint: const Color(0xffe8f4ea),
            label: l10n.generateExportS279,
            value: l10n.generateExportSummaryTypeEmpty,
          ),
          const SizedBox(height: 6),
          _SummaryStateTile(
            iconAsset: starIconAsset,
            tint: const Color(0xfffff4d8),
            label: l10n.generateExportSummaryGoalLabel,
            value: l10n.generateExportSummaryGoalEmpty,
          ),
          const SizedBox(height: 6),
          _SummaryStateTile(
            iconAsset: imageIconAsset,
            tint: const Color(0xffecf4ff),
            label: l10n.generateExportS460,
            value: l10n.generateExportSummarySelectedAssetsValue(selectedCount),
          ),
          const SizedBox(height: 6),
          _SummaryStateTile(
            iconAsset: rightArrowIconAsset,
            tint: const Color(0xffe8f4ea),
            label: l10n.generateExportSummaryNextStepLabel,
            value: l10n.generateExportSummaryNextStepValue,
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 304,
              height: 164,
              child: Image.asset(
                creationSummaryBearsIconAsset,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xfffffcf8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffeadccf)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: Color(0xffd7a64f),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.generateExportMaterialTip,
                    style: const TextStyle(
                      color: Color(0xff6f6258),
                      height: 1.45,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStateTile extends StatelessWidget {
  const _SummaryStateTile({
    required this.iconAsset,
    required this.tint,
    required this.label,
    required this.value,
  });

  final String iconAsset;
  final Color tint;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xfffffcf8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffeadccf)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: tint,
            child: AppAssetIcon(iconAsset, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xff7a6a5b),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xff3b3128),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessSummary extends StatelessWidget {
  const _ReadinessSummary({
    required this.selectedCount,
    required this.generated,
    required this.exported,
  });

  final int selectedCount;
  final bool generated;
  final bool exported;

  @override
  Widget build(BuildContext context) {
    final hasAssets = selectedCount > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasAssets ? const Color(0xffe8f4ea) : const Color(0xfffff4d8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasAssets ? const Color(0xffb6dec0) : const Color(0xffefd39a),
        ),
      ),
      child: Column(
        children: [
          ConsoleFact(
            label: AppLocalizations.of(context)!.generateExportS821,
            value: hasAssets
                ? AppLocalizations.of(
                    context,
                  )!.generateExportReadinessAssetRatio(selectedCount)
                : AppLocalizations.of(context)!.generateExportS83,
          ),
          const SizedBox(height: 8),
          ConsoleFact(
            label: AppLocalizations.of(context)!.generateExportS227,
            value: exported
                ? AppLocalizations.of(context)!.generateExportS444
                : generated
                ? AppLocalizations.of(context)!.generateExportS450
                : hasAssets
                ? AppLocalizations.of(context)!.generateExportS795
                : AppLocalizations.of(context)!.generateExportS800,
          ),
          const SizedBox(height: 8),
          ConsoleFact(
            label: AppLocalizations.of(context)!.generateExportCloudShareLabel,
            value: AppLocalizations.of(context)!.generateExportCloudShareValue,
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.value,
    required this.iconAsset,
  });

  final String title;
  final String value;
  final String iconAsset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xffeadbc9)),
          ),
          child: Row(
            children: [
              AppAssetIcon(iconAsset, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ExportTargetSelector extends StatelessWidget {
  const ExportTargetSelector({
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalizedOptions = options.isEmpty
        ? [AppLocalizations.of(context)!.generateExportDefaultPdfTarget]
        : options;
    final selected = normalizedOptions.contains(value)
        ? value
        : normalizedOptions.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.generateExportS417,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(selected),
            initialValue: selected,
            isExpanded: true,
            items: normalizedOptions
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.9),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: AppAssetIcon(pdfIconAsset, size: inlineIconSize),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xffeadbc9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xff2faa61)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
