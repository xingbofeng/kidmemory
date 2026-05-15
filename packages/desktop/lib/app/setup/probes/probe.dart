part of '../../desktop_shell.dart';

const List<String> _postgres16OptPrefixes = [
  '/opt/homebrew/opt/postgresql@16',
  '/usr/local/opt/postgresql@16',
];
const List<String> _postgres16BinPrefixes = [
  '/opt/homebrew/opt/postgresql@16/bin',
  '/usr/local/opt/postgresql@16/bin',
];
const List<String> _commonLocalBinPrefixes = [
  '/opt/homebrew/bin',
  '/usr/local/bin',
];
const List<String> _pgvectorLegacyLibraryPrefixes = [
  '/opt/homebrew/lib/postgresql@16',
  '/opt/homebrew/lib/postgresql@15',
  '/opt/homebrew/lib/postgresql@14',
  '/usr/local/lib/postgresql@16',
  '/usr/local/lib/postgresql@15',
];

const String _pgDefaultHost = 'localhost';
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

  String? _postgresPgConfig() {
    for (final candidate in [
      ..._postgres16BinPrefixes.map((prefix) => '$prefix/pg_config'),
      _postgresTool('pg_config'),
      _findExecutable('pg_config'),
    ]) {
      if (candidate != null && File(candidate).existsSync()) return candidate;
    }
    return null;
  }
}
