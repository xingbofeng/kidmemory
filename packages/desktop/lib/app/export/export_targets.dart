part of '../desktop_shell.dart';

extension _DesktopShellExportTargets on _DesktopShellState {
  String _exportFileNameForJob(String id, _ExportTarget target) {
    final extension = switch (target) {
      _ExportTarget.pdf => '.pdf',
      _ExportTarget.longImagePng => '.png',
      _ExportTarget.longImageJpg => '.jpg',
    };
    return id.toLowerCase().endsWith(extension) ? id : '$id$extension';
  }

  String _buildExportTargetPath(String directoryPath, String fileName) {
    final normalizedDirectory = directoryPath.endsWith(Platform.pathSeparator)
        ? directoryPath.substring(0, directoryPath.length - 1)
        : directoryPath;
    return '$normalizedDirectory${Platform.pathSeparator}$fileName';
  }

  _ExportTarget _exportTargetFromLabel(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('jpg') || normalized.contains('jpeg')) {
      return _ExportTarget.longImageJpg;
    }
    if (normalized.contains('png')) return _ExportTarget.longImagePng;
    return _ExportTarget.pdf;
  }

  String _exportLabel(_ExportTarget target) {
    return switch (target) {
      _ExportTarget.pdf => 'PDF',
      _ExportTarget.longImagePng => AppLocalizations.of(context)!.generateExportS934,
      _ExportTarget.longImageJpg => AppLocalizations.of(context)!.generateExportS931,
    };
  }

  String _artifactKindForTarget(_ExportTarget target) {
    return switch (target) {
      _ExportTarget.pdf => 'pdf',
      _ExportTarget.longImagePng => 'long_image_png',
      _ExportTarget.longImageJpg => 'long_image_jpg',
    };
  }
}
