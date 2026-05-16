part of '../desktop_shell.dart';

extension _DesktopShellFeedback on _DesktopShellState {
  void _appendLog(String message) {
    final clock = _clockStamp(DateTime.now());
    final line = '$clock  $message';
    activityLog.insert(0, line);
    if (activityLog.length > 12) {
      activityLog.removeRange(12, activityLog.length);
    }
    debugPrint(line);
    unawaited(
      desktopLogger.append(
        level: DesktopLogLevel.info,
        event: 'desktop.ui.log',
        traceId: traceId.isEmpty ? null : traceId,
        requestId: requestId.isEmpty ? null : requestId,
        data: {'message': message},
      ),
    );
  }

  String _clockStamp(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    AppToast.show(context, message: message, tone: _toastTone(message));
  }

  AppToastTone _toastTone(String message) {
    if (message.contains('失败') ||
        message.contains('无法') ||
        message.contains('未找到') ||
        message.contains('没有') ||
        message.contains('超时')) {
      return AppToastTone.error;
    }
    if (message.contains('未就绪') ||
        message.contains('请') ||
        message.contains('取消')) {
      return AppToastTone.warning;
    }
    if (message.contains('成功') ||
        message.contains('完成') ||
        message.contains('已配置') ||
        message.contains('已保存') ||
        message.contains('已更新')) {
      return AppToastTone.success;
    }
    return AppToastTone.info;
  }
}
