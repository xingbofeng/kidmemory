part of '../../desktop_shell.dart';

extension _DesktopShellImportFlow on _DesktopShellState {
  Future<String?> _pickDataDirectoryPath() async {
    return getDirectoryPath(
      confirmButtonText: AppLocalizations.of(context)!.importPageS905,
      canCreateDirectories: true,
    );
  }

  Future<List<XFile>> _pickImportFiles() {
    final group = XTypeGroup(
      label: 'images',
      extensions: const ['jpg', 'jpeg', 'png', 'webp', 'zip'],
    );
    return openFiles(acceptedTypeGroups: [group], confirmButtonText: AppLocalizations.of(context)!.assetLibraryImportPhotoLabel);
  }

  Future<String?> _pickImportFolderPath() {
    return getDirectoryPath(confirmButtonText: AppLocalizations.of(context)!.importPageS904);
  }

  Future<AssetImportReport> importFiles() => _importFilesReport();

  Future<AssetImportReport> importFolderRecursive() => _importFolderReport();

  Future<AssetImportReport> importDroppedPaths(List<String> paths) =>
      _importDroppedPathsReport(paths);

  Future<AssetImportReport> _importFilesReport() async {
    final childId = await _ensureImportChild();
    if (childId == null) return _importBlockedReport();
    final files = await pickImportFiles();
    if (files.isEmpty) {
      return const AssetImportReport(imported: 0, duplicates: 0, failed: 0, skipped: 0);
    }
    final stagedPaths = await _stageImportPaths(files.map((f) => f.path));
    if (stagedPaths.isEmpty) return _importStagingFailedReport();
    return _importStagedPaths(childId: childId, stagedPaths: stagedPaths);
  }

  Future<AssetImportReport> _importFolderReport() async {
    final childId = await _ensureImportChild();
    if (childId == null) return _importBlockedReport();
    final folderPath = await pickImportFolderPath();
    if (folderPath == null || folderPath.isEmpty) {
      return const AssetImportReport(imported: 0, duplicates: 0, failed: 0, skipped: 0);
    }
    final stagedPaths = await _stageImportPaths([folderPath]);
    if (stagedPaths.isEmpty) return _importStagingFailedReport();
    return _importStagedPaths(childId: childId, stagedPaths: stagedPaths);
  }

  Future<AssetImportReport> _importDroppedPathsReport(List<String> paths) async {
    if (paths.isEmpty) {
      return const AssetImportReport(imported: 0, duplicates: 0, failed: 0, skipped: 0);
    }
    final childId = await _ensureImportChild();
    if (childId == null) return _importBlockedReport();
    final stagedPaths = await _stageImportPaths(paths);
    if (stagedPaths.isEmpty) return _importStagingFailedReport();
    return _importStagedPaths(childId: childId, stagedPaths: stagedPaths);
  }

  Future<AssetImportReport> _importStagedPaths({
    required String childId,
    required List<String> stagedPaths,
  }) async {
    final previousAssetIds = assets.map((asset) => asset.id).toSet();
    final result = await gateway.importAssetsDto(
      payload: ImportAssetsInput(childId: childId, paths: stagedPaths),
    );
    await refreshDataset();
    return _summarizeImport(
      result,
      fallbackImportedCount: _newAssetCount(previousAssetIds),
    );
  }

  Future<String?> _ensureImportChild() async {
    if (selectedChildId != null) return selectedChildId;
    const fallbackChildId = 'child-default';
    final result = await gateway.ensureChildDto(id: fallbackChildId, name: AppLocalizations.of(context)!.assetLibraryChildLabel);
    final childId = result.hasChild ? result.childId : fallbackChildId;
    await refreshDataset();
    if (!mounted) return null;
    _setShellState(() => selectedChildId = childId);
    return childId;
  }

  AssetImportReport _importBlockedReport() => AssetImportReport(
    imported: 0,
    duplicates: 0,
    skipped: 0,
    failed: 1,
    message: AppLocalizations.of(context)!.importPageS386,
  );

  AssetImportReport _importStagingFailedReport() => AssetImportReport(
    imported: 0,
    duplicates: 0,
    skipped: 0,
    failed: 1,
    message: AppLocalizations.of(context)!.importPageS674,
  );

}
