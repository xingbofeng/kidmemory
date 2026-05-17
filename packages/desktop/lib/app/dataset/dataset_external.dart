part of '../desktop_shell.dart';

extension _DesktopShellDatasetExternal on _DesktopShellState {
  Future<void> _safeOpenExternalTarget(String target, String label) async {
    try {
      await openExternalTarget(target);
      _appendLog('$label 打开成功：$target');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('$label 打开失败：$error');
      _appendLog('$label 打开失败：$error');
    }
  }

  Future<void> _openDirectory(String path) async {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      _showSnackBar('目录路径为空，无法打开');
      return;
    }
    final normalized = _normalizeDirectoryPath(trimmed);
    try {
      final directory = Directory(normalized);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
    } catch (_) {
      // Keep user-facing failure messages coming from the open attempt if needed.
    }
    await _safeOpenExternalTarget(normalized, '目录');
  }

  String _normalizeDirectoryPath(String input) {
    if (_looksLikeAbsolutePath(input)) return input;
    final home =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';
    if (input.startsWith('./')) {
      final cwd = Directory.current.path;
      return '$cwd${Platform.pathSeparator}${input.substring(2)}';
    }
    if (input.startsWith('.${Platform.pathSeparator}') ||
        input.startsWith('.\\') ||
        input.startsWith('./')) {
      final cwd = Directory.current.path;
      final suffix = input.substring(2);
      return '$cwd${Platform.pathSeparator}$suffix';
    }
    if (input.startsWith('~${Platform.pathSeparator}') ||
        input.startsWith('~/')) {
      final suffix = input.substring(2);
      return home.isEmpty ? input : '$home${Platform.pathSeparator}$suffix';
    }
    if (input.startsWith('.')) {
      return home.isEmpty
          ? input
          : '$home${Platform.pathSeparator}${input.substring(1)}';
    }
    return home.isEmpty ? input : '$home${Platform.pathSeparator}$input';
  }

  bool _looksLikeAbsolutePath(String target) {
    if (target.startsWith(Platform.pathSeparator)) return true;
    return RegExp(r'^[A-Za-z]:[\\\\/]').hasMatch(target);
  }

  Future<void> _openExternalTargetDefault(String target) async {
    if (_looksLikeAbsolutePath(target)) {
      if (Platform.isMacOS) {
        await Process.run('open', [target]);
        return;
      }
      if (Platform.isLinux) {
        await Process.run('xdg-open', [target]);
        return;
      }
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', target]);
        return;
      }
      throw UnsupportedError('当前平台不支持打开本地路径');
    }

    final parsed = Uri.tryParse(target);
    if (parsed == null || !parsed.isAbsolute) {
      throw StateError('invalid external target: $target');
    }
    if (Platform.isMacOS) {
      await Process.run('open', [target]);
      return;
    }
    if (Platform.isLinux) {
      await Process.run('xdg-open', [target]);
      return;
    }
    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '', target]);
      return;
    }
    throw UnsupportedError('当前平台不支持外部打开');
  }

  Future<void> _copyTextToClipboardDefault(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
