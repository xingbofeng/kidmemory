part of '../../desktop_shell.dart';

extension _DesktopShellSetupProgressUpdates on _DesktopShellState {
  void _setSetupProgress(
    String checkTitle,
    double progress,
    String label, {
    required String state,
  }) {
    if (!mounted) return;
    _setShellState(() {
      readinessChecks = _replaceSetupCheck(
        readinessChecks,
        checkTitle,
        (check) => SetupCheckVm(
          index: check.index,
          title: check.title,
          body: check.body,
          action: check.action,
          state: state,
          ok: null,
          secondaryActionLabel: check.secondaryActionLabel,
          secondaryActionPath: check.secondaryActionPath,
          progress: progress,
          progressLabel: label,
          actionEnabled: false,
        ),
      );
    });
  }

  void _finishSetupProgress(
    String checkTitle,
    String label, {
    required bool ok,
  }) {
    if (!mounted) return;
    _setShellState(() {
      readinessChecks = _replaceSetupCheck(
        readinessChecks,
        checkTitle,
        (check) => SetupCheckVm(
          index: check.index,
          title: check.title,
          body: check.body,
          action: check.action,
          state: ok
              ? AppLocalizations.of(context)!.setupConfigured
              : AppLocalizations.of(context)!.setupNeedsAction,
          ok: ok,
          secondaryActionLabel: check.secondaryActionLabel,
          secondaryActionPath: check.secondaryActionPath,
          progress: 1,
          progressLabel: label,
          actionEnabled: true,
        ),
      );
    });
  }

  List<SetupCheckVm> _replaceSetupCheck(
    List<SetupCheckVm> source,
    String checkTitle,
    SetupCheckVm Function(SetupCheckVm check) replace,
  ) {
    final checks = source.isEmpty ? _disconnectedSetupChecks(context) : source;
    var replaced = false;
    final next = checks.map((check) {
      if (check.title != checkTitle) return check;
      replaced = true;
      return replace(check);
    }).toList();
    if (replaced) return next;
    return checks;
  }
}
