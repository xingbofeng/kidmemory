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
          state: result.okValue ? '已选择' : '本地已选择',
        );
      });
    _appendLog('本地数据目录已更新：${appliedPaths.dataDir}');
    _showSnackBar(
      result.okValue
          ? '本地数据目录已更新'
          : '本地数据目录已更新；sidecar 启动后会继续读取配置',
    );
    if (!mounted) return;
    await refreshReadiness();
  }
}
