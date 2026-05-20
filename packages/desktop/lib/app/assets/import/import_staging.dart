part of '../../desktop_shell.dart';

extension _DesktopShellImportStaging on _DesktopShellState {
  Future<List<String>> _stageImportPaths(Iterable<String> paths) async {
    final stagingRoot = await Directory.systemTemp.createTemp(
      'kidmemory-import-',
    );
    final stagedPaths = <String>[];
    var index = 0;
    for (final sourcePath in paths.where((path) => path.isNotEmpty)) {
      final sourceType = await FileSystemEntity.type(sourcePath);
      if (sourceType == FileSystemEntityType.file) {
        final staged = await _copyFileToImportStage(
          sourcePath,
          stagingRoot.path,
          index++,
        );
        if (staged != null) stagedPaths.add(staged);
      } else if (sourceType == FileSystemEntityType.directory) {
        final stagedDir = Directory(
          '${stagingRoot.path}${Platform.pathSeparator}folder_${index++}',
        );
        await stagedDir.create(recursive: true);
        await _copyDirectoryToImportStage(sourcePath, stagedDir.path);
        stagedPaths.add(stagedDir.path);
      }
    }
    return stagedPaths;
  }

  Future<String?> _copyFileToImportStage(
    String sourcePath,
    String targetDir,
    int index,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final name = _basename(sourcePath);
      final targetPath = '$targetDir${Platform.pathSeparator}${index}_$name';
      await File(sourcePath).copy(targetPath);
      return targetPath;
    } catch (error) {
      _appendLog(l10n.importStagingFailedLog(sourcePath, error));
      return null;
    }
  }

  Future<void> _copyDirectoryToImportStage(
    String sourcePath,
    String targetDir,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await for (final entity in Directory(sourcePath).list(recursive: true)) {
      if (entity is! File) continue;
      final relative = entity.path
          .substring(sourcePath.length)
          .replaceFirst(RegExp(r'^[\\/]+'), '');
      if (relative.isEmpty) continue;
      final targetPath = '$targetDir${Platform.pathSeparator}$relative';
      await Directory(_dirname(targetPath)).create(recursive: true);
      try {
        await entity.copy(targetPath);
      } catch (error) {
        _appendLog(l10n.importStagingFailedLog(entity.path, error));
      }
    }
  }
}
