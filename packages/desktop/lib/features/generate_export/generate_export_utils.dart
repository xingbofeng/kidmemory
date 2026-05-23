import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'generate_export_models.dart';

CreationMainStage mainStageFor(
  CreationWorkflowPhase phase, {
  required bool generated,
  required bool exported,
}) {
  if (exported ||
      phase == CreationWorkflowPhase.exporting ||
      phase == CreationWorkflowPhase.published) {
    return CreationMainStage.share;
  }
  if (generated || phase == CreationWorkflowPhase.reviewing) {
    return CreationMainStage.preview;
  }
  return switch (phase) {
    CreationWorkflowPhase.preparing => CreationMainStage.prepare,
    CreationWorkflowPhase.planning ||
    CreationWorkflowPhase.planReady => CreationMainStage.plan,
    CreationWorkflowPhase.creatingJob ||
    CreationWorkflowPhase.environmentPreparing ||
    CreationWorkflowPhase.generating ||
    CreationWorkflowPhase.failed => CreationMainStage.generate,
    CreationWorkflowPhase.reviewing => CreationMainStage.preview,
    CreationWorkflowPhase.exporting ||
    CreationWorkflowPhase.published => CreationMainStage.share,
  };
}

bool shouldShowGenerationError(BuildContext context, String statusMessage) {
  final message = statusMessage.trim();
  if (message.isEmpty) {
    return false;
  }
  if (message ==
      AppLocalizations.of(context)!.contentPreviewWaitingForGenerationLabel) {
    return false;
  }
  if (message == AppLocalizations.of(context)!.generateExportS662) {
    return false;
  }
  if (message.contains(AppLocalizations.of(context)!.generateExportS731)) {
    return false;
  }
  return message.contains(
        AppLocalizations.of(context)!.uploadStatusFailedLabel,
      ) ||
      message.contains(AppLocalizations.of(context)!.generateExportS472) ||
      message.contains(AppLocalizations.of(context)!.generateExportS214) ||
      message.contains(AppLocalizations.of(context)!.generateExportS875);
}

String creationPhaseLabel(
  BuildContext context,
  CreationWorkflowPhase creationPhase,
) {
  final l10n = AppLocalizations.of(context)!;
  return switch (creationPhase) {
    CreationWorkflowPhase.preparing => l10n.creationPhasePreparing,
    CreationWorkflowPhase.planning => l10n.creationPhasePlanning,
    CreationWorkflowPhase.planReady => l10n.creationPhasePlanReady,
    CreationWorkflowPhase.creatingJob => l10n.creationPhaseCreatingJob,
    CreationWorkflowPhase.environmentPreparing =>
      l10n.creationPhaseEnvironmentPreparing,
    CreationWorkflowPhase.generating => l10n.creationPhaseGenerating,
    CreationWorkflowPhase.reviewing => l10n.creationPhaseReviewing,
    CreationWorkflowPhase.exporting => l10n.creationPhaseExporting,
    CreationWorkflowPhase.published => l10n.creationPhasePublished,
    CreationWorkflowPhase.failed => l10n.creationPhaseFailed,
  };
}

String creationTypeLabel(BuildContext context, String creationType) {
  return switch (creationType) {
    'memory_book' => AppLocalizations.of(context)!.generateExportS740,
    'memoir_video' => AppLocalizations.of(
      context,
    )!.assetLibraryBatchGenerateVideoLabel,
    _ => AppLocalizations.of(context)!.generateExportS721,
  };
}

bool creationPhaseHasReached(
  CreationWorkflowPhase current,
  CreationWorkflowPhase target,
) {
  const order = [
    CreationWorkflowPhase.preparing,
    CreationWorkflowPhase.planning,
    CreationWorkflowPhase.planReady,
    CreationWorkflowPhase.creatingJob,
    CreationWorkflowPhase.environmentPreparing,
    CreationWorkflowPhase.generating,
    CreationWorkflowPhase.reviewing,
    CreationWorkflowPhase.exporting,
    CreationWorkflowPhase.published,
  ];
  if (current == CreationWorkflowPhase.failed) return false;
  return order.indexOf(current) >= order.indexOf(target);
}

int estimatedPageCount(int selectedCount) {
  if (selectedCount <= 0) return 1;
  return selectedCount * 3 > 12 ? 12 : selectedCount * 3;
}

String compactGenerationOption(BuildContext context, String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return AppLocalizations.of(context)!.generateExportS957;
  }
  return normalized.split(RegExp(r'\s{2,}')).first.trim();
}

String ordinaryTimelineText(BuildContext context, String text) {
  final l10n = AppLocalizations.of(context)!;
  var sanitized = text.trim();
  if (sanitized.isEmpty) return sanitized;

  if (RegExp('taskId\\s*:', caseSensitive: false).hasMatch(sanitized)) {
    return l10n.exportGenerationStateS736;
  }

  final localizedPortKeyword = String.fromCharCodes([0x7aef, 0x53e3]);
  if (RegExp(
    r'\bpg_ctl\b|PostgreSQL|postgres|stdout:|stderr:|PID\s*=|dist/main\.js|KIDMEMORY_SIDECAR|'
    '$localizedPortKeyword\\s*\\d+|port\\s*\\d+',
    caseSensitive: false,
  ).hasMatch(sanitized)) {
    return l10n.setupLocalServicePreparing;
  }

  sanitized = sanitized.replaceAll(
    RegExp('Request ID\\s*:\\s*\\S+', caseSensitive: false),
    '',
  );
  sanitized = sanitized.replaceAll(
    RegExp('requestId\\s*[:=]\\s*\\S+', caseSensitive: false),
    '',
  );
  sanitized = sanitized.replaceAll(
    RegExp('Supabase\\s+Storage', caseSensitive: false),
    l10n.generateExportCloudStorageLabel,
  );
  sanitized = sanitized.replaceAll(
    RegExp('Supabase', caseSensitive: false),
    l10n.generateExportCloudStorageLabel,
  );
  sanitized = sanitized.replaceAll(
    RegExp('sidecar', caseSensitive: false),
    l10n.generateExportLocalServiceLabel,
  );

  sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();
  sanitized = sanitized.replaceAll(RegExp(r'\s+，'), '，').trim();
  return sanitized.isEmpty ? l10n.generateExportS796 : sanitized;
}

String exportButtonLabel(BuildContext context, String exportText) {
  if (isMp4ExportTarget(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportMp4Action;
  }
  if (isJpgExportTarget(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportS404;
  }
  if (isPngExportTarget(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportS406;
  }
  return AppLocalizations.of(context)!.generateExportS405;
}

String exportDisplayName(BuildContext context, String exportText) {
  if (isMp4ExportTarget(context, exportText)) {
    return 'MP4';
  }
  if (isJpgExportTarget(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportS931;
  }
  if (isPngExportTarget(context, exportText)) {
    return AppLocalizations.of(context)!.generateExportS934;
  }
  return 'PDF';
}

bool isPngExportTarget(BuildContext context, String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('png') ||
      exportText.contains(AppLocalizations.of(context)!.generateExportS934);
}

bool isJpgExportTarget(BuildContext context, String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('jpg') ||
      normalized.contains('jpeg') ||
      exportText.contains(AppLocalizations.of(context)!.generateExportS931);
}

bool isMp4ExportTarget(BuildContext context, String exportText) {
  final normalized = exportText.toLowerCase();
  return normalized.contains('mp4') ||
      exportText.contains(
        AppLocalizations.of(context)!.generateExportVideoKeyword,
      );
}

String storageStatusLabel(BuildContext context, String status) {
  final normalized = status.trim();
  if (normalized == 'synced') {
    return AppLocalizations.of(context)!.generateExportS438;
  }
  if (normalized == 'pending' || normalized == 'running') {
    return AppLocalizations.of(context)!.generateExportS336;
  }
  if (normalized == 'retry_wait') {
    return AppLocalizations.of(context)!.generateExportS802;
  }
  if (normalized == 'failed') {
    return AppLocalizations.of(context)!.generateExportS340;
  }
  if (normalized.isEmpty ||
      normalized == 'local_only' ||
      normalized == 'ready') {
    return AppLocalizations.of(context)!.generateExportS219;
  }
  return normalized;
}
