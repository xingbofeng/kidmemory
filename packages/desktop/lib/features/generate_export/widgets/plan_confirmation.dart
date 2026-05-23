import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/layout.dart';
import '../generate_export_models.dart';
import 'shared_ui.dart';

class CreationPlanConfirmationPanel extends StatelessWidget {
  const CreationPlanConfirmationPanel({
    required this.plan,
    required this.onConfirm,
    required this.onEditRequest,
    super.key,
  });

  final CreationTaskPreviewVm plan;
  final VoidCallback onConfirm;
  final VoidCallback onEditRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleSteps = plan.steps.take(5).toList(growable: false);
    final visibleRequirements = plan.requirements
        .take(4)
        .toList(growable: false);
    return SurfaceCard(
      backgroundColor: const Color(0xfff6fbf2),
      borderColor: const Color(0xffc8e4bf),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppAssetIcon(completeIconAsset, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.creationPlanConfirmationTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              StatusChip(
                label: l10n.creationPhasePlanReady,
                color: const Color(0xff168542),
                background: const Color(0xffe8f4ea),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (plan.summary.isNotEmpty)
            Text(
              plan.summary,
              style: const TextStyle(color: Color(0xff4f443c), height: 1.45),
            ),
          const SizedBox(height: 12),
          ConsoleFact(
            label: l10n.creationPlanSkillLabel,
            value: plan.skillName.isEmpty
                ? l10n.creationPlanUnknownSkill
                : plan.skillName,
          ),
          if (visibleSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.creationPlanStepsLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < visibleSteps.length; index++)
              _PlanPreviewStep(index: index + 1, step: visibleSteps[index]),
          ],
          if (visibleRequirements.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.creationPlanRequirementsLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final requirement in visibleRequirements)
                  StatusChip(
                    label: requirement,
                    color: const Color(0xff5d5148),
                    background: const Color(0xfffffcf7),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 240,
                child: PrimaryButton(
                  label: l10n.creationConfirmPlanAction,
                  iconAsset: playIconAsset,
                  onPressed: onConfirm,
                  height: 48,
                ),
              ),
              SecondaryButton(
                label: l10n.generateExportEditRequestLabel,
                iconAsset: editIconAsset,
                onPressed: onEditRequest,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanPreviewStep extends StatelessWidget {
  const _PlanPreviewStep({required this.index, required this.step});

  final int index;
  final CreationTaskStepVm step;

  @override
  Widget build(BuildContext context) {
    final detail = step.detail.isNotEmpty ? step.detail : step.status;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xffe8f4ea),
            child: Text(
              '$index',
              style: const TextStyle(
                color: Color(0xff168542),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: const TextStyle(
                      color: Color(0xff7a6a5b),
                      fontSize: 12,
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
