part of '../desktop_shell.dart';

extension _DesktopShellSidecarLifecycle on _DesktopShellState {
  Future<void> _bootstrapSidecarAndRefresh() async {
    if (mounted) {
      _setShellState(() => readinessMessage = 'Sidecar 状态检查中');
    }
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      await _ensureSidecarRunning();
      await refreshReadiness();
      return;
    }
    if (_bundledPostgresRuntimeAvailable()) {
      final pgReady = await _ensureBundledPostgresReady('PostgreSQL 配置');
      if (!pgReady) {
        _markSidecarUnavailable('内置 PostgreSQL 启动失败，已阻断 sidecar 启动。');
        return;
      }
      final relaunched = await _ensureSidecarRunning(forceRestart: true);
      if (!relaunched) {
        _markSidecarUnavailable('Sidecar 重启失败，初始化未完成。');
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
        readinessMessage = '正在启动 Sidecar';
        readinessChecks = _pgFirstSetupChecks();
      });
    }
    final sidecarReady = await _ensureSidecarRunning();
    if (!sidecarReady) {
      _markSidecarUnavailable('Sidecar 未就绪，初始化未完成。');
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
      readinessMessage = _sidecarDisconnectedMessage;
      readinessChecks = _pgFirstSetupChecks();
    });
  }

  List<SetupCheckVm> _pgFirstSetupChecks() {
    final checks = _disconnectedSetupChecks();
    return _applySequentialSetupLocks(checks);
  }

  List<SetupCheckVm> _applySequentialSetupLocks(List<SetupCheckVm> checks) {
    var blocked = false;
    return checks.map((check) {
      final enabled = check.actionEnabled && !blocked;
      final next = enabled
          ? check
          : _copySetupCheck(
              check,
              state: check.ok == true ? check.state : '等待上一步',
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
