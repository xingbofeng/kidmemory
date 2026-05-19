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
    if (message.contains(AppLocalizations.of(context)!.uploadStatusFailedLabel) ||
        message.contains(AppLocalizations.of(context)!.feedbackPageS555) ||
        message.contains(AppLocalizations.of(context)!.feedbackPageS583) ||
        message.contains(AppLocalizations.of(context)!.feedbackPageS673) ||
        message.contains(AppLocalizations.of(context)!.generateExportS875)) {
      return AppToastTone.error;
    }
    if (message.contains(AppLocalizations.of(context)!.feedbackPageS582) ||
        message.contains('请') ||
        message.contains(AppLocalizations.of(context)!.actionCancel)) {
      return AppToastTone.warning;
    }
    if (message.contains(AppLocalizations.of(context)!.success) ||
        message.contains(AppLocalizations.of(context)!.feedbackPageS383) ||
        message.contains(AppLocalizations.of(context)!.setupConfigured) ||
        message.contains(AppLocalizations.of(context)!.feedbackPageS429) ||
        message.contains(AppLocalizations.of(context)!.feedbackPageS448)) {
      return AppToastTone.success;
    }
    return AppToastTone.info;
  }
}
