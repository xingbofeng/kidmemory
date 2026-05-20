part of '../../desktop_shell.dart';

extension _DesktopShellSetupState on _DesktopShellState {
  Future<void> _selectLocalDataRoot() async {
    final selectedRoot = await _pickLocalDataRootPath();
    if (selectedRoot == null || selectedRoot.trim().isEmpty) return;
    await _applySelectedLocalDataRoot(selectedRoot);
  }
}
