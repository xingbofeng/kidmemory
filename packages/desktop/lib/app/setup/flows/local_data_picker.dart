part of '../../desktop_shell.dart';

extension _DesktopShellSetupLocalDataPicker on _DesktopShellState {
  Future<String?> _pickLocalDataRootPath() async {
    try {
      return await pickDataDirectoryPath();
    } catch (error) {
      if (!mounted) return null;
      _showSnackBar('打开目录选择器失败：$error');
      _appendLog('本地数据目录选择失败：$error');
      return null;
    }
  }
}
