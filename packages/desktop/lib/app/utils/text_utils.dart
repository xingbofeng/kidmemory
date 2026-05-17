part of '../desktop_shell.dart';

extension _DesktopShellTextUtils on _DesktopShellState {
  String _shortProcessOutput(String output) {
    final trimmed = output.trim();
    if (trimmed.isEmpty) return '无错误输出';
    final lines = const LineSplitter().convert(trimmed);
    final tail = lines.length > 6 ? lines.sublist(lines.length - 6) : lines;
    final text = tail.join(' | ');
    if (text.length <= 1200) return text;
    return text.substring(text.length - 1200);
  }
}
