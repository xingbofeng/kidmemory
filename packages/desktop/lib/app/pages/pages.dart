part of '../desktop_shell.dart';

extension _DesktopShellPages on _DesktopShellState {
  void _openSampleDatasetPage() {
    _setShellState(() => step = AppStep.sample);
  }

  void _returnToChildProfilePage() {
    _setShellState(() => step = AppStep.child);
  }

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
      importFailed: sampleImportFailed,
      previewAssets: _samplePreviewAssets,
      artworkCount: _countAssetsByType(assets, 'artwork'),
      craftCount: _countAssetsByType(assets, 'craft'),
      photoCount: _countAssetsByType(assets, 'photo'),
      tagCount: _countUniqueTags(assets),
      onReset: () => unawaited(_confirmResetSampleDataset()),
      onOpenSamplePdf: () => unawaited(_openSamplePdf()),
      onImport: () => unawaited(importSampleDataset()),
      onBrowseSampleAssets: browseSampleAssets,
      onGenerateSampleBook: generateSampleBook,
      onBack: _returnToChildProfilePage,
    );
  }

  Widget _buildChildProfilePage() {
    return ChildProfilePage(
      children: children,
      assets: assets,
      selectedChildId: selectedChildId,
      onAddProfile: () => unawaited(_createChildProfile()),
      onTrySample: _openSampleDatasetPage,
      onEditProfile: (child) => unawaited(_editSelectedChildProfile(child)),
      onDeleteProfile: (child) => unawaited(_deleteSelectedChildProfile(child)),
      onChildChanged: (childId) =>
          unawaited(_handleAssetLibraryChildChanged(childId)),
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
      onReplaceSelectedAssets: _replaceSelectedAssets,
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
      creationPhase: creationWorkflowPhase,
      statusMessage: statusMessage,
      requestId: requestId,
      logLines: activityLog,
      templateOptions: generationTemplates,
      pageSizeOptions: generationPageSizes,
      styleOptions: generationStyles,
      exportTargetOptions: generationExportTargets,
      selectedTemplate: generationTemplate,
      selectedPageSize: generationPageSize,
      selectedStyle: generationStyle,
      selectedExportTarget: generationExportTarget,
      selectedCreationType: generationCreationType,
      onGenerate: () => unawaited(generateBook()),
      onGeneratePictureBook: () =>
          unawaited(generateBook(creationType: 'storybook')),
      onGenerateMemoryAlbum: () =>
          unawaited(generateBook(creationType: 'memory_book')),
      onGenerateMemoryVideo: () =>
          unawaited(generateBook(creationType: 'memoir_video')),
      onConfirmPlan: () => unawaited(confirmCreationPlan()),
      onExport: exportPdf,
      onExportTargetChanged: _updateGenerationExportTarget,
      shareCreating: shareCreating,
      creationTask: creationTask,
      creationFailure: creationFailure,
      creationTaskSteps: creationTaskSteps,
      exportResult: exportResult,
      previewFailureReason: previewFailureReason,
      onOpenExportFolder: () => unawaited(_openExportFolder()),
      onOpenPreviewFailureFolder: () => unawaited(_openPreviewFailureFolder()),
      onCreateShareLink: () => unawaited(_confirmAndCreateShareLink()),
      onCopyShareText: () => unawaited(_copyShareText()),
      onOpenShareLink: () => unawaited(_openShareLink()),
      onCopyLongImage: () => unawaited(_copyLongImage()),
      onViewSelectedAssets: () => _setShellState(() => step = AppStep.assets),
      onViewLogDetails: () => unawaited(_showGenerationLogDetails()),
      onEditCreationRequest: _editCreationRequest,
      onPreviewAllPages: () => unawaited(_previewAllPages()),
    );
  }

  void _editCreationRequest() {
    _invalidateCreationPlanForInputChange();
    _setShellState(() => step = AppStep.assets);
  }

  void _updateGenerationExportTarget(String target) {
    if (target == generationExportTarget) return;
    _setShellState(() => generationExportTarget = target);
    _invalidateCreationPlanForInputChange();
  }
}
