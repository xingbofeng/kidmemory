part of '../desktop_shell.dart';

extension _DesktopShellPages on _DesktopShellState {
  Widget _pageForStep(AppStep effectiveStep) {
    return switch (effectiveStep) {
      AppStep.setup => _buildSetupPage(),
      AppStep.sample => _buildSampleDatasetPage(),
      AppStep.child => _buildChildProfilePage(),
      AppStep.assets => _buildAssetLibraryPage(),
      AppStep.generate => _buildGenerateExportPage(),
    };
  }

  Widget _buildSetupPage() {
    return SetupPage(
      readinessMessage: readinessMessage,
      checks: readinessChecks,
      supabaseStorage: supabaseStorage,
      onContinue: () => _setShellState(() => step = AppStep.child),
      onSetupAction: _runSetupAction,
      onRefreshReadiness: () => unawaited(refreshReadiness()),
      onOpenDirectory: (path) => unawaited(_openDirectory(path)),
      onConfigureSupabaseStorage: () => unawaited(_configureSupabaseStorage()),
      onTestSupabaseStorage: () => unawaited(_testSupabaseStorage()),
    );
  }

  Widget _buildSampleDatasetPage() {
    return SampleDatasetPage(
      imported: sampleImported,
      importing: sampleImporting,
      previewAssets: _samplePreviewAssets,
      artworkCount: _countAssetsByType(assets, 'artwork'),
      craftCount: _countAssetsByType(assets, 'craft'),
      photoCount: _countAssetsByType(assets, 'photo'),
      tagCount: _countUniqueTags(assets),
      onReset: () => resetSampleDataset(),
      onOpenSamplePdf: () => unawaited(_openSamplePdf()),
      onImport: () => unawaited(importSampleDataset()),
    );
  }

  Widget _buildChildProfilePage() {
    return ChildProfilePage(
      children: children,
      assets: assets,
      selectedChildId: selectedChildId,
      onAddProfile: () => unawaited(_createChildProfile()),
      onEditProfile: () => unawaited(_editSelectedChildProfile()),
    );
  }

  Widget _buildAssetLibraryPage() {
    return AssetLibraryPage(
      children: children,
      selectedChildId: selectedChildId,
      assets: assets,
      typeOptions: searchTypeOptions,
      selectedAssets: selectedAssets,
      onChildChanged: _handleAssetLibraryChildChanged,
      onToggle: _toggleSelectedAsset,
      onUpdateAsset: _updateAssetFromLibrary,
      onDeleteAsset: _deleteSingleAssetFromLibrary,
      onDeleteSelected: _deleteSelectedAssetsFromLibrary,
      onImportFiles: importFiles,
      onImportFolder: importFolderRecursive,
      onImportDroppedPaths: importDroppedPaths,
      onSemanticSearch: searchAssetsInline,
      onRefreshSearchIndexing: refreshSearchIndexingMessage,
      onGoToGenerate: () => _setShellState(() => step = AppStep.generate),
      onSyncAsset: syncAssetToStorage,
      onOpenDirectUpload: _openDirectUploadDialog,
      sidecarApi: api,
      onTrustedUploadFinished: refreshDataset,
    );
  }

  Widget _buildGenerateExportPage() {
    return GenerateExportPage(
      selectedCount: selectedAssets.length,
      generated: generated,
      generating: generating,
      exported: exported,
      statusMessage: statusMessage,
      logLines: activityLog,
      templateOptions: generationTemplates,
      pageSizeOptions: generationPageSizes,
      styleOptions: generationStyles,
      exportTargetOptions: generationExportTargets,
      selectedTemplate: generationTemplate,
      selectedPageSize: generationPageSize,
      selectedStyle: generationStyle,
      selectedExportTarget: generationExportTarget,
      onGenerate: generateBook,
      onExport: exportPdf,
      onExportTargetChanged: (target) =>
          _setShellState(() => generationExportTarget = target),
      exportResult: exportResult,
      onOpenExportFolder: () => unawaited(_openExportFolder()),
      onCopyShareText: () => unawaited(_copyShareText()),
      onCopyLongImage: () => unawaited(_copyLongImage()),
      onViewSelectedAssets: () => _setShellState(() => step = AppStep.assets),
      onViewLogDetails: () => unawaited(_showGenerationLogDetails()),
      onPreviewAllPages: () => unawaited(_previewAllPages()),
    );
  }
}
