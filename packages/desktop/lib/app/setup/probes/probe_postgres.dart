part of '../../desktop_shell.dart';

final RegExp _whitespaceSequence = RegExp(r'\s+');
final RegExp _postgresServiceNamePattern = RegExp(r'^postgresql(?:@\d+)?$');

Iterable<String> splitProbeOutputLines(String output) {
  return output
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty);
}

bool isPostgresFormulaLine(String line) {
  return line == 'postgresql' || line.startsWith('postgresql@');
}

bool isStartedPostgresServiceLine(String line) {
  final parts = line.split(_whitespaceSequence).where((part) => part.isNotEmpty);
  return isStartedPostgresServiceColumns(parts);
}

bool isStartedPostgresServiceColumns(Iterable<String> parts) {
  final iterator = parts.iterator;
  if (!iterator.moveNext()) return false;
  final serviceName = iterator.current;
  if (!isPostgresServiceName(serviceName)) return false;
  if (!iterator.moveNext()) return false;
  return iterator.current == 'started';
}

bool isPostgresServiceName(String value) {
  return _postgresServiceNamePattern.hasMatch(value);
}

extension _DesktopShellSetupProbePostgres on _DesktopShellState {
  String? _postgresTool(String name) {
    for (final prefix in [
      ..._postgres16BinPrefixes,
      ..._commonLocalBinPrefixes,
    ]) {
      final candidate = '$prefix/$name';
      if (File(candidate).existsSync()) return candidate;
    }
    return null;
  }

  _PgLocalStatus _detectPgLocal() {
    if (!Platform.isMacOS) return _PgLocalStatus.unknown;

    if (_pgPortListening()) return _PgLocalStatus.running;
    if (_pgIsReady()) return _PgLocalStatus.running;

    final brewStatus = _detectPgStatusFromBrew();
    if (brewStatus != null) return brewStatus;

    final toolStatus = _detectPgStatusFromPsqlTools();
    if (toolStatus != null) return toolStatus;

    return _PgLocalStatus.notInstalled;
  }

  _PgLocalStatus? _detectPgStatusFromBrew() {
    final brew = _findExecutable('brew');
    if (brew == null) return null;
    try {
      final formulaList = _commandOutputIfOk(brew, ['list', '--formula']);
      if (!_hasPostgresFormula(formulaList)) return null;

      final svcOutput = _commandOutputIfOk(brew, ['services', 'list']);
      return _hasStartedPostgresService(svcOutput)
          ? _PgLocalStatus.running
          : _PgLocalStatus.installedNotRunning;
    } catch (_) {
      // Fall through to psql/pg_isready probing below.
      return null;
    }
  }

  _PgLocalStatus? _detectPgStatusFromPsqlTools() {
    final psql = _findExecutable('psql');
    final pgIsReady = _findExecutable('pg_isready');
    if (psql == null) return null;
    if (pgIsReady == null) return _PgLocalStatus.unknown;
    try {
      final exitCode = _commandExitCode(pgIsReady, [
        '-h',
        _pgDefaultHost,
        '-p',
        '$_pgDefaultPort',
      ]);
      return exitCode == 0
          ? _PgLocalStatus.running
          : _PgLocalStatus.installedNotRunning;
    } catch (_) {
      return _PgLocalStatus.unknown;
    }
  }

  bool _pgPortListening() {
    try {
      final output = _commandOutputIfOk('/usr/sbin/lsof', [
        '-nP',
        '-iTCP:$_pgDefaultPort',
        '-sTCP:LISTEN',
      ]);
      return output.contains('LISTEN');
    } catch (_) {
      return false;
    }
  }

  bool _pgIsReady() {
    final pgIsReady =
        _postgresTool('pg_isready') ?? _findExecutable('pg_isready');
    if (pgIsReady == null) return false;
    try {
      final exitCode = _commandExitCode(pgIsReady, [
        '-h',
        _pgDefaultLoopback,
        '-p',
        '$_pgDefaultPort',
      ]);
      return exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  bool _hasPostgresFormula(String output) {
    return splitProbeOutputLines(output).any(isPostgresFormulaLine);
  }

  bool _hasStartedPostgresService(String output) {
    return splitProbeOutputLines(output).any(isStartedPostgresServiceLine);
  }
}
