part of '../desktop_shell.dart';

extension _DesktopShellReadinessChecks on _DesktopShellState {
  SetupCheckVm _setupCheck({
    required String index,
    required String title,
    required String body,
    required String action,
    required String state,
    required bool? ok,
    String? secondaryActionLabel,
    String? secondaryActionPath,
  }) {
    return SetupCheckVm(
      index: index,
      title: title,
      body: body,
      action: action,
      state: state,
      ok: ok,
      secondaryActionLabel: secondaryActionLabel,
      secondaryActionPath: secondaryActionPath,
    );
  }

  List<SetupCheckVm> _buildReadinessChecks({
    required ReadinessCheckDto openai,
  }) {
    final paths = _defaultKidMemoryPaths();
    final checks = [
      _setupCheck(
        index: '1',
        title: AppLocalizations.of(context)!.setupOpenAiTitle,
        body: _openAiReadinessDescription(),
        action: AppLocalizations.of(context)!.actionTestConnection,
        secondaryActionLabel: AppLocalizations.of(context)!.actionEditConfig,
        secondaryActionPath: AppLocalizations.of(
          context,
        )!.actionConfigurePathToken,
        state: _readinessState(openai),
        ok: openai.okOrNull,
      ),
      _setupCheck(
        index: '2',
        title: AppLocalizations.of(context)!.setupLocalDataDirTitle,
        body: _localDataDirectoryDescription(context, paths),
        action: AppLocalizations.of(context)!.actionConfigureDirectory,
        state: AppLocalizations.of(context)!.setupConfigured,
        ok: true,
        secondaryActionLabel: AppLocalizations.of(context)!.actionOpenDirectory,
        secondaryActionPath: paths.dataDir,
      ),
    ];
    return _applySequentialSetupLocks(checks);
  }
}
