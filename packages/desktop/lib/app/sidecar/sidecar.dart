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
    if (await _waitForSidecarApiReady()) {
      await refreshReadiness();
      return;
    }
    final localPg = _detectPgLocal();
    if (mounted) {
      _setShellState(() {
        readinessMessage = localPg == _PgLocalStatus.running
            ? 'PostgreSQL 已就绪，正在启动 Sidecar'
            : '正在启动 Sidecar，并继续检测 PostgreSQL 配置';
        readinessChecks = _pgFirstSetupChecks(localPg);
      });
    }
    if (localPg != _PgLocalStatus.running) {
      _appendLog('PostgreSQL 未确认就绪，仍将启动 sidecar 读取配置状态。');
    }
    final sidecarReady = await _ensureSidecarRunning();
    if (!sidecarReady) {
      _markSidecarUnavailable('Sidecar 未就绪，初始化未完成。');
      return;
    }
    await refreshReadiness();
  }

  Future<bool> _ensureSidecarRunning() async {
    return sidecarLauncher.ensureRunning();
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
    final localPg = Platform.environment['FLUTTER_TEST'] == 'true'
        ? _PgLocalStatus.unknown
        : _detectPgLocal();
    _setShellState(() {
      readinessMessage = _sidecarDisconnectedMessage;
      readinessChecks = _pgFirstSetupChecks(localPg);
      _applyStartupConfigurationGate(needsConfiguration: true);
    });
  }

  List<SetupCheckVm> _pgFirstSetupChecks(
    _PgLocalStatus localPg, {
    bool sidecarReady = false,
  }) {
    final (pgAction, pgState) = _pgActionAndState(false, localPg);
    final pgOk = localPg == _PgLocalStatus.running;
    final checks = _disconnectedSetupChecks();
    return _applySequentialSetupLocks(
      checks.map((check) {
        if (check.title == 'PostgreSQL 配置') {
          return _copySetupCheck(
            check,
            action: pgAction,
            state: pgState,
            ok: pgOk,
            actionEnabled: true,
          );
        }
        if (check.title == _sidecarSetupTitle) {
          return _copySetupCheck(
            check,
            state: sidecarReady ? '已启动' : (pgOk ? '待启动' : '等待 PG'),
            ok: sidecarReady,
            actionEnabled: pgOk,
          );
        }
        return check;
      }).toList(),
    );
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
