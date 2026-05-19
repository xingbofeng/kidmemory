part of '../desktop_shell.dart';

extension _DesktopShellReadinessRules on _DesktopShellState {
  String _setupActionForTitle(Object? rawAction, String title) {
    if (title == AppLocalizations.of(context)!.setupPostgresTitle ||
        title == _sidecarSetupTitle ||
        title == AppLocalizations.of(context)!.setupPgvectorTitle ||
        title == AppLocalizations.of(context)!.setupOpenAiTitle ||
        title == AppLocalizations.of(context)!.setupLocalDataDirTitle) {
      return _defaultSetupAction(title);
    }
    final resolved = '$rawAction'.trim();
    if (resolved.isEmpty || resolved == 'null') {
      return _defaultSetupAction(title);
    }
    if (_defaultSetupAction(title) == resolved) {
      return resolved;
    }
    return resolved;
  }

  String _defaultSetupAction(String title) {
    if (title == AppLocalizations.of(context)!.setupPostgresTitle) {
      return AppLocalizations.of(context)!.actionInstallAndConfigure;
    }
    if (title == _sidecarSetupTitle) return AppLocalizations.of(context)!.actionStartSidecar;
    if (title == AppLocalizations.of(context)!.setupPgvectorTitle) {
      return AppLocalizations.of(context)!.actionInstallAndConfigure;
    }
    if (title == AppLocalizations.of(context)!.setupOpenAiTitle) {
      return AppLocalizations.of(context)!.actionConfigure;
    }
    if (title == AppLocalizations.of(context)!.setupLocalDataDirTitle) {
      return AppLocalizations.of(context)!.actionConfigureDirectory;
    }
    return AppLocalizations.of(context)!.actionView;
  }

  String _extractSetupPurpose(String body) {
    final lines = body.split('\n');
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line == AppLocalizations.of(context)!.setupPurposeLabel) return AppLocalizations.of(context)!.setupSystemConfigItemSummary;
      if (line.startsWith(AppLocalizations.of(context)!.setupPurposePrefixCn)) {
        return line.replaceFirst(AppLocalizations.of(context)!.setupPurposePrefixCn, '').trim();
      }
      if (line.startsWith(AppLocalizations.of(context)!.setupPurposePrefixAscii)) {
        return line.replaceFirst(AppLocalizations.of(context)!.setupPurposePrefixAscii, '').trim();
      }
      if (line.startsWith(AppLocalizations.of(context)!.setupPurposeLabel)) {
        final marker = line.indexOf('：');
        if (marker != -1 && marker + 1 < line.length) {
          return line.substring(marker + 1).trim();
        }
      }
      return line;
    }
    return AppLocalizations.of(context)!.setupSystemConfigItemSummary;
  }
}
