part of '../../desktop_shell.dart';

const List<String> _commonLocalBinPrefixes = [
  '/opt/homebrew/bin',
  '/usr/local/bin',
];

const String _pgDefaultLoopback = '127.0.0.1';
const int _pgDefaultPort = 5432;
const String _pgDefaultDatabase = 'kidmemory';

extension _DesktopShellSetupProbe on _DesktopShellState {
  String _commandOutputIfOk(String executable, List<String> arguments) {
    final result = Process.runSync(executable, arguments);
    return result.exitCode == 0 ? result.stdout.toString() : '';
  }

  int _commandExitCode(String executable, List<String> arguments) {
    final result = Process.runSync(executable, arguments);
    return result.exitCode;
  }

  bool _anyFileExists(List<String> candidates) {
    for (final path in candidates) {
      if (File(path).existsSync()) return true;
    }
    return false;
  }
}
