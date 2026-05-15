part of '../desktop_shell.dart';

extension _DesktopShellReadinessRefreshApply on _DesktopShellState {
  void _applyReadinessUiConfig(_UiConfigSnapshot loadedUiConfig) {
    if (!mounted) return;
    _setShellState(() {
      readinessChecks = loadedUiConfig.setupChecks;
      searchTypeOptions = loadedUiConfig.searchTypeOptions;
      generationTemplates = loadedUiConfig.generationTemplates;
      generationPageSizes = loadedUiConfig.generationPageSizes;
      generationStyles = loadedUiConfig.generationStyles;
      generationExportTargets = loadedUiConfig.generationExportTargets;
      generationTemplate = loadedUiConfig.defaultGenerationTemplate;
      generationPageSize = loadedUiConfig.defaultGenerationPageSize;
      generationStyle = loadedUiConfig.defaultGenerationStyle;
      generationExportTarget = loadedUiConfig.defaultGenerationExportTarget;
    });
  }

  void _applyReadinessStorageAndPaths(ReadinessConfigDto config) {
    if (!mounted) return;
    final defaultPaths = _defaultKidMemoryPaths();
    final pathConfig = config.pathConfig;
    _setShellState(() {
      supabaseStorage = _supabaseStorageFromConfig(
        config,
        previous: supabaseStorage,
      );
      currentExportDir = _stringOrDefault(
        pathConfig.exportDir,
        defaultPaths.exportDir,
      );
    });
  }
}
