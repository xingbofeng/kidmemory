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
    try {
      final directory = Directory(trimmed);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
    } catch (_) {
      // Keep user-facing failure messages coming from the open attempt if needed.
    }
    await _safeOpenExternalTarget(trimmed, '目录');
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
