part of 'desktop_shell.dart';

enum _ExportTarget { pdf, longImagePng, longImageJpg }

class _ExportSyncResult {
  const _ExportSyncResult({
    required this.storageStatus,
    this.remoteUrl = '',
    this.shareText = '',
    this.errorReason = '',
  });

  final String storageStatus;
  final String remoteUrl;
  final String shareText;
  final String errorReason;

  factory _ExportSyncResult.localOnly() {
    return const _ExportSyncResult(storageStatus: 'local_only');
  }
}

class _UiConfigSnapshot {
  const _UiConfigSnapshot({
    required this.setupChecks,
    required this.searchTypeOptions,
    required this.generationTemplates,
    required this.generationPageSizes,
    required this.generationStyles,
    required this.generationExportTargets,
    required this.defaultGenerationTemplate,
    required this.defaultGenerationPageSize,
    required this.defaultGenerationStyle,
    required this.defaultGenerationExportTarget,
  });

  final List<SetupCheckVm> setupChecks;
  final List<Map<String, String>> searchTypeOptions;
  final List<String> generationTemplates;
  final List<String> generationPageSizes;
  final List<String> generationStyles;
  final List<String> generationExportTargets;
  final String defaultGenerationTemplate;
  final String defaultGenerationPageSize;
  final String defaultGenerationStyle;
  final String defaultGenerationExportTarget;
}
