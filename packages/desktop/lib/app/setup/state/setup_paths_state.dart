part of '../../desktop_shell.dart';

extension _DesktopShellSetupPathsState on _DesktopShellState {
  List<SetupCheckVm> _replacePathChecks(
    List<SetupCheckVm> source,
    _KidMemoryPathSet paths, {
    required String state,
  }) {
    final checks = source.isEmpty ? _disconnectedSetupChecks(context) : source;
    return checks.map((check) {
      if (check.title == AppLocalizations.of(context)!.setupLocalDataDirTitle) {
        return SetupCheckVm(
          index: check.index,
          title: check.title,
          body: _localDataDirectoryDescription(paths),
          action: check.action,
          secondaryActionLabel: AppLocalizations.of(context)!.actionOpenDirectory,
          secondaryActionPath: paths.dataDir,
          state: state,
          ok: true,
        );
      }
      return check;
    }).toList();
  }

  _KidMemoryPathSet _pathsFromConfig(
    PathConfigDto config,
    _KidMemoryPathSet fallback,
  ) {
    return (
      dataDir: _resolveConfiguredPath(
        _stringOrDefault(config.dataDir, fallback.dataDir),
        fallback.dataDir,
      ),
      workspaceDir: _resolveConfiguredPath(
        _stringOrDefault(config.workspaceDir, fallback.workspaceDir),
        fallback.workspaceDir,
      ),
      exportDir: _resolveConfiguredPath(
        _stringOrDefault(config.exportDir, fallback.exportDir),
        fallback.exportDir,
      ),
    );
  }
}
