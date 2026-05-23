import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/layout.dart';
import '../generate_export_models.dart';

class CreationStageStepper extends StatelessWidget {
  const CreationStageStepper({required this.currentStage, super.key});

  final CreationMainStage currentStage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stages = [
      _StageStepData(
        stage: CreationMainStage.prepare,
        title: l10n.creationPhasePreparing,
        subtitle: l10n.creationStagePrepareSubtitle,
        iconAsset: editIconAsset,
      ),
      _StageStepData(
        stage: CreationMainStage.plan,
        title: l10n.creationPhasePlanConfirm,
        subtitle: l10n.creationStagePlanSubtitle,
        iconAsset: fileIconAsset,
      ),
      _StageStepData(
        stage: CreationMainStage.generate,
        title: l10n.creationStageGenerateTitle,
        subtitle: l10n.creationStageGenerateSubtitle,
        iconAsset: magicStarIconAsset,
      ),
      _StageStepData(
        stage: CreationMainStage.preview,
        title: l10n.creationStagePreviewTitle,
        subtitle: l10n.creationStagePreviewSubtitle,
        iconAsset: viewIconAsset,
      ),
      _StageStepData(
        stage: CreationMainStage.share,
        title: l10n.creationStageShareTitle,
        subtitle: l10n.creationStageShareSubtitle,
        iconAsset: linkIconAsset,
      ),
    ];
    final currentIndex = stages.indexWhere(
      (step) => step.stage == currentStage,
    );
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.creationFlowTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              for (var index = 0; index < stages.length; index++) ...[
                Expanded(
                  child: _StageStep(
                    index: index + 1,
                    data: stages[index],
                    active: index == currentIndex,
                    complete: index < currentIndex,
                  ),
                ),
                if (index < stages.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StageStepData {
  const _StageStepData({
    required this.stage,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
  });

  final CreationMainStage stage;
  final String title;
  final String subtitle;
  final String iconAsset;
}

class _StageStep extends StatelessWidget {
  const _StageStep({
    required this.index,
    required this.data,
    required this.active,
    required this.complete,
  });

  final int index;
  final _StageStepData data;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final foreground = complete || active
        ? const Color(0xff168542)
        : const Color(0xff8c7c6d);
    final background = active
        ? const Color(0xffe8f4ea)
        : complete
        ? const Color(0xfff0f7ed)
        : const Color(0xfff6f0e8);
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? const Color(0xffb6dec0) : const Color(0xffeadbc9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: active || complete
                    ? const Color(0xff168542)
                    : const Color(0xffd8cbbd),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AppAssetIcon(data.iconAsset, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff7a6a5b),
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
