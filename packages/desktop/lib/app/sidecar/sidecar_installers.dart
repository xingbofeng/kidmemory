part of '../desktop_shell.dart';

extension _DesktopShellSidecarInstallers on _DesktopShellState {
  Future<bool> _ensureNodeAvailable() async {
    if (_findExecutable('node') != null) return true;

    if (Platform.isWindows) {
      return _installNodeWindows();
    }
    if (Platform.isLinux) {
      return _installNodeLinux();
    }
    if (Platform.isMacOS) {
      return _installNodeMacOS();
    }
    return false;
  }
}
