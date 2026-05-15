part of '../desktop_shell.dart';

extension _DesktopShellReadinessStartupGate on _DesktopShellState {
  void _applyStartupConfigurationGate({required bool needsConfiguration}) {
    if (_startupConfigurationGateChecked) return;
    _startupConfigurationGateChecked = true;
    _startupConfigurationRequired = needsConfiguration;
    if (needsConfiguration) step = AppStep.setup;
  }

  bool _needsStartupConfiguration({
    required List<ReadinessCheckDto> checks,
  }) {
    return checks.any(_readinessNeedsConfiguration);
  }

  bool _readinessNeedsConfiguration(ReadinessCheckDto result) {
    if (result.isEmpty) return false;
    if (!result.blocksGeneration) return false;
    return result.needsConfiguration;
  }
}
