part of '../desktop_shell.dart';

extension _DesktopShellExecutableFinder on _DesktopShellState {
  String? _findExecutable(String name) {
    final candidates = [
      ..._commonLocalBinPrefixes.map((prefix) => '$prefix/$name'),
      '${Platform.environment['HOME'] ?? ''}/.volta/bin/$name',
      '${Platform.environment['HOME'] ?? ''}/.asdf/shims/$name',
    ];
    for (final candidate in candidates) {
      if (File(candidate).existsSync()) return candidate;
    }
    final pathSeparator = Platform.isWindows ? ';' : ':';
    final pathEntries = (Platform.environment['PATH'] ?? '').split(
      pathSeparator,
    );
    final pathExtensions = Platform.isWindows
        ? const ['.exe', '.cmd', '.bat', '']
        : const [''];
    for (final entry in pathEntries) {
      final trimmed = entry.trim();
      if (trimmed.isEmpty) continue;
      for (final ext in pathExtensions) {
        final candidate = '$trimmed/$name$ext';
        if (File(candidate).existsSync()) return candidate;
      }
    }
    return null;
  }
}
