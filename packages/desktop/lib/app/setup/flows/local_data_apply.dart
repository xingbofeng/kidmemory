part of '../../desktop_shell.dart';

extension _DesktopShellSetupLocalDataApply on _DesktopShellState {
  Future<void> _applySelectedLocalDataRoot(String selectedRoot) async {
    final paths = _pathsForDataRoot(selectedRoot);
    final result = await gateway.configurePathsDto(
      payload: PathsConfigInput(
        dataDir: paths.dataDir,
        workspaceDir: paths.workspaceDir,
        exportDir: paths.exportDir,
      ),
    );
    if (!mounted) return;
    final appliedPaths = _pathsFromConfig(result.pathConfig, paths);
    _setShellState(() {
        readinessChecks = _replacePathChecks(
          readinessChecks,
          appliedPaths,
          state: result.okValue ? AppLocalizations.of(context)!.setupChosen : AppLocalizations.of(context)!.setupLocalPathSelected,
        );
      });
    _appendLog('本地数据目录已更新：${appliedPaths.dataDir}');
    _showSnackBar(
      result.okValue
          ? AppLocalizations.of(context)!.setupLocalPathUpdated
          : AppLocalizations.of(context)!.setupLocalPathUpdatedSidecarPending,
    );
    if (!mounted) return;
    await refreshReadiness();
  }
}
