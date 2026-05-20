part of '../../desktop_shell.dart';

extension _DesktopShellSetupLocalDataPicker on _DesktopShellState {
  Future<String?> _pickLocalDataRootPath() async {
    try {
      return await pickDataDirectoryPath();
    } catch (error) {
      if (!mounted) return null;
      _showSnackBar(
        AppLocalizations.of(context)!.setupOpenDirectoryPickerFailed(error),
      );
      _appendLog(
        AppLocalizations.of(context)!.setupLocalDataDirPickFailedLog(error),
      );
      return null;
    }
  }
}
