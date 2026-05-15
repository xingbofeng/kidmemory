part of '../../desktop_shell.dart';

extension _DesktopShellImportUtils on _DesktopShellState {
  String _basename(String path) {
    final normalized = path.replaceAll('\\', Platform.pathSeparator);
    return normalized.split(Platform.pathSeparator).last;
  }

  String _dirname(String path) {
    final separator = Platform.pathSeparator;
    final index = path.lastIndexOf(separator);
    return index <= 0 ? separator : path.substring(0, index);
  }

  int _intOrDefault(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  int _newAssetCount(Set<String> previousAssetIds) {
    return assets.where((asset) => !previousAssetIds.contains(asset.id)).length;
  }
}
