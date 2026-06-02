part of '../desktop_shell.dart';

extension _DesktopShellSidecarLifecycle on _DesktopShellState {
  Future<void> _bootstrapSidecarAndRefresh() async {
    final l10n = AppLocalizations.of(context)!;
    if (mounted) {
      _setShellState(() => readinessMessage = l10n.sidecarS151);
    }
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      await _ensureSidecarRunning();
      await refreshReadiness();
      return;
    }
    if (_bundledPostgresRuntimeAvailable()) {
      final bool pgReady;
      try {
        pgReady = await _ensureBundledPostgresReady(
          l10n.setupPostgresTitle,
        );
      } catch (error) {
        _appendLog(l10n.setupSidecarStartFailedNodeOrBundled);
        _appendLog('$error');
        _markSidecarUnavailable(l10n.sidecarS266);
        return;
      }
      if (!pgReady) {
        _markSidecarUnavailable(l10n.sidecarS266);
        return;
      }
      final relaunched = await _ensureSidecarRunning(forceRestart: true);
      if (!relaunched) {
        _markSidecarUnavailable(l10n.sidecarS155);
        return;
      }
      await refreshReadiness();
      return;
    }
    if (await _waitForSidecarApiReady()) {
      await refreshReadiness();
      return;
    }
    if (mounted) {
      _setShellState(() {
        readinessMessage = l10n.sidecarS652;
        readinessChecks = _pgFirstSetupChecks();
      });
    }
    final sidecarReady = await _ensureSidecarRunning();
    if (!sidecarReady) {
      _markSidecarUnavailable(l10n.sidecarS145);
      return;
    }
    await refreshReadiness();
  }

  Future<bool> _ensureSidecarRunning({bool forceRestart = false}) async {
    return sidecarLauncher.ensureRunning(forceRestart: forceRestart);
  }

  Future<bool> _sidecarApiReady() async {
    return sidecarLauncher.apiReady();
  }

  Future<bool> _waitForSidecarApiReady({int attempts = 12}) async {
    return sidecarLauncher.waitForApiReady(attempts: attempts);
  }

  void _markSidecarUnavailable([String? logMessage]) {
    if (logMessage != null) _appendLog(logMessage);
    if (!mounted) return;
    _setShellState(() {
      readinessMessage = _sidecarDisconnectedMessage(context);
      readinessChecks = _pgFirstSetupChecks();
    });
  }

  List<SetupCheckVm> _pgFirstSetupChecks() {
    final checks = _disconnectedSetupChecks(context);
    return _applySequentialSetupLocks(checks);
  }

  List<SetupCheckVm> _applySequentialSetupLocks(List<SetupCheckVm> checks) {
    var blocked = false;
    return checks.map((check) {
      final isLocalDataDirectory =
          check.title == AppLocalizations.of(context)!.setupLocalDataDirTitle;
      final enabled = check.actionEnabled && (!blocked || isLocalDataDirectory);
      final next = enabled
          ? check
          : _copySetupCheck(
              check,
              state: check.ok == true
                  ? check.state
                  : AppLocalizations.of(context)!.sidecarS792,
              actionEnabled: false,
            );
      if (check.ok != true) blocked = true;
      return next;
    }).toList();
  }

  SetupCheckVm _copySetupCheck(
    SetupCheckVm check, {
    String? index,
    String? title,
    String? body,
    String? action,
    String? state,
    bool? ok,
    String? secondaryActionLabel,
    String? secondaryActionPath,
    double? progress,
    String? progressLabel,
    bool? actionEnabled,
  }) {
    return SetupCheckVm(
      index: index ?? check.index,
      title: title ?? check.title,
      body: body ?? check.body,
      action: action ?? check.action,
      state: state ?? check.state,
      ok: ok ?? check.ok,
      secondaryActionLabel: secondaryActionLabel ?? check.secondaryActionLabel,
      secondaryActionPath: secondaryActionPath ?? check.secondaryActionPath,
      progress: progress ?? check.progress,
      progressLabel: progressLabel ?? check.progressLabel,
      actionEnabled: actionEnabled ?? check.actionEnabled,
    );
  }
}
