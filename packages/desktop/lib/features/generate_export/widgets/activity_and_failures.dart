import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/layout.dart';
import '../generate_export_models.dart';
import '../generate_export_utils.dart';
import 'shared_ui.dart';

class ActivityTimelinePanel extends StatelessWidget {
  const ActivityTimelinePanel({
    required this.generated,
    required this.generating,
    required this.exported,
    required this.creationPhase,
    required this.statusMessage,
    required this.requestId,
    required this.logLines,
    required this.onViewDetails,
    super.key,
  });

  final bool generated;
  final bool generating;
  final bool exported;
  final CreationWorkflowPhase creationPhase;
  final String statusMessage;
  final String requestId;
  final List<String> logLines;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final entries = logLines.isEmpty
        ? [AppLocalizations.of(context)!.generateExportS796]
        : logLines.map((line) => ordinaryTimelineText(context, line)).toList();
    final ordinaryStatusMessage = ordinaryTimelineText(context, statusMessage);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.generateExportS108,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              StatusChip(
                label: creationPhase != CreationWorkflowPhase.preparing
                    ? creationPhaseLabel(context, creationPhase)
                    : exported
                    ? AppLocalizations.of(context)!.generateExportS442
                    : generated
                    ? AppLocalizations.of(context)!.generateExportS794
                    : generating
                    ? AppLocalizations.of(context)!.generateExportS895
                    : AppLocalizations.of(context)!.generateExportS795,
                color:
                    exported ||
                        generated ||
                        creationPhase == CreationWorkflowPhase.published ||
                        creationPhase == CreationWorkflowPhase.reviewing
                    ? const Color(0xff168542)
                    : generating ||
                          creationPhase == CreationWorkflowPhase.planning ||
                          creationPhase == CreationWorkflowPhase.creatingJob ||
                          creationPhase == CreationWorkflowPhase.exporting
                    ? const Color(0xff9a5a14)
                    : const Color(0xff7a6a5b),
                background:
                    exported ||
                        generated ||
                        creationPhase == CreationWorkflowPhase.published ||
                        creationPhase == CreationWorkflowPhase.reviewing
                    ? const Color(0xffe8f4ea)
                    : generating ||
                          creationPhase == CreationWorkflowPhase.planning ||
                          creationPhase == CreationWorkflowPhase.creatingJob ||
                          creationPhase == CreationWorkflowPhase.exporting
                    ? const Color(0xfffff4d8)
                    : const Color(0xfff6f0e8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < entries.take(5).length; index++)
            _TimelineEntry(
              text: entries[index],
              active: index == entries.length - 1 && generating,
              complete: generated || exported || index < entries.length - 1,
            ),
          if (ordinaryStatusMessage.trim().isNotEmpty && logLines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                AppLocalizations.of(
                  context,
                )!.generateExportCurrentStatusLine(ordinaryStatusMessage),
                style: const TextStyle(
                  color: Color(0xff7a6a5b),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: logLines.isEmpty
                ? AppLocalizations.of(context)!.generateExportS726
                : AppLocalizations.of(context)!.contentViewDetailsLabel,
            iconAsset: timelineIconAsset,
            onPressed: logLines.isEmpty ? null : onViewDetails,
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.text,
    required this.active,
    required this.complete,
  });

  final String text;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final color = complete
        ? const Color(0xff3f8c55)
        : active
        ? const Color(0xff9a5a14)
        : const Color(0xffc7b8a7);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(radius: 5, backgroundColor: color),
              Container(width: 1, height: 22, color: const Color(0xffe8dccb)),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xff5d5148), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class GenerationErrorActionsPanel extends StatelessWidget {
  const GenerationErrorActionsPanel({
    required this.statusMessage,
    required this.requestId,
    required this.failure,
    required this.creationType,
    required this.onRetry,
    required this.onEditRequest,
    required this.onViewLogs,
    super.key,
  });

  final String statusMessage;
  final String requestId;
  final CreationFailureVm? failure;
  final String creationType;
  final VoidCallback onRetry;
  final VoidCallback onEditRequest;
  final VoidCallback onViewLogs;

  @override
  Widget build(BuildContext context) {
    final title =
        statusMessage.contains(AppLocalizations.of(context)!.generateExportS419)
        ? AppLocalizations.of(context)!.generateExportS421
        : AppLocalizations.of(context)!.generateExportS729;
    final failureVm = failure;
    final reason = failureVm?.reason.isNotEmpty == true
        ? failureVm!.reason
        : _extractReason(context, statusMessage);
    final ordinaryReason = ordinaryTimelineText(context, reason);
    return SurfaceCard(
      backgroundColor: const Color(0xfffff4f3),
      borderColor: const Color(0xffefc8c4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xff8f3226),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(
              context,
            )!.generateExportReasonLine(ordinaryReason),
            style: const TextStyle(color: Color(0xff6f6258), height: 1.45),
          ),
          if (failureVm?.stepLabel.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.creationFailureStepLine(failureVm!.stepLabel),
              style: const TextStyle(
                color: Color(0xff6f6258),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (failureVm?.code.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(
                context,
              )!.creationFailureCodeLine(failureVm!.code),
              style: const TextStyle(color: Color(0xff8f6a60), fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(
                label: _generationFailureRetryLabel(
                  context,
                  failureVm,
                  creationType,
                ),
                iconAsset: refreshIconAsset,
                onPressed: onRetry,
              ),
              SecondaryButton(
                label: AppLocalizations.of(
                  context,
                )!.generateExportEditRequestLabel,
                iconAsset: editIconAsset,
                onPressed: onEditRequest,
              ),
              SecondaryButton(
                label: AppLocalizations.of(context)!.generateExportS624,
                iconAsset: timelineIconAsset,
                onPressed: onViewLogs,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _extractReason(BuildContext context, String message) {
    final normalized = message.trim();
    if (normalized.isEmpty) {
      return AppLocalizations.of(context)!.generateExportS226;
    }
    final colonIndex = normalized.indexOf('：');
    if (colonIndex >= 0 && colonIndex + 1 < normalized.length) {
      return normalized.substring(colonIndex + 1).trim();
    }
    return normalized;
  }
}

String _generationFailureRetryLabel(
  BuildContext context,
  CreationFailureVm? failure,
  String creationType,
) {
  if (failure == null) {
    return AppLocalizations.of(context)!.actionRetryLabel;
  }
  final category = failure.category.toLowerCase();
  if (creationType == 'memoir_video' ||
      category.contains('hyperframes') ||
      category.contains('environment')) {
    return AppLocalizations.of(context)!.generateExportS921;
  }
  return AppLocalizations.of(context)!.creationReplanAction;
}

class CoverFailureActionPanel extends StatelessWidget {
  const CoverFailureActionPanel({
    required this.requestId,
    required this.onRetry,
    required this.onViewLog,
    super.key,
  });

  final String requestId;
  final VoidCallback onRetry;
  final VoidCallback onViewLog;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    backgroundColor: const Color(0xfffff4f1),
    borderColor: const Color(0xffffd5cd),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.generateExportS421,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xff9b3a2b),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.generateExportS315,
          style: TextStyle(color: Color(0xff6f6258), height: 1.45),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SecondaryButton(
              label: AppLocalizations.of(context)!.actionRetryLabel,
              iconAsset: refreshIconAsset,
              onPressed: onRetry,
            ),
            SecondaryButton(
              label: AppLocalizations.of(context)!.generateExportS624,
              iconAsset: timelineIconAsset,
              onPressed: onViewLog,
            ),
          ],
        ),
      ],
    ),
  );
}
