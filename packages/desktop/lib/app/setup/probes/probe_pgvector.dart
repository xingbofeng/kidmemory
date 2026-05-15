part of '../../desktop_shell.dart';

extension _DesktopShellSetupProbePgvector on _DesktopShellState {
  List<String> _pgvectorLibraryCandidates(String prefix) {
    return [
      '$prefix/vector.so',
      '$prefix/bitcode/vector',
    ];
  }

  List<String> _pgvectorPostgres16DynamicLibraries(String prefix) {
    return [
      '$prefix/lib/postgresql/vector.dylib',
      '$prefix/lib/postgresql/vector.so',
      '$prefix/lib/postgresql@16/vector.dylib',
      '$prefix/lib/postgresql@16/vector.so',
    ];
  }

  bool _pgvectorLegacyLibraryDetected() {
    for (final prefix in _pgvectorLegacyLibraryPrefixes) {
      if (_anyFileExists(_pgvectorLibraryCandidates(prefix))) {
        return true;
      }
    }
    return false;
  }

  _PgvectorLocalStatus? _detectPgvectorStatusFromBrew() {
    final brew = _findExecutable('brew');
    if (brew == null) return null;
    try {
      final output = _commandOutputIfOk(brew, ['list', '--formula']);
      if (output.trim().isEmpty) return null;
      final formulas = output
          .toString()
          .split('\n')
          .map((line) => line.trim())
          .toSet();
      return formulas.contains('pgvector')
          ? _PgvectorLocalStatus.installed
          : null;
    } catch (_) {
      return _PgvectorLocalStatus.unknown;
    }
  }

  _PgvectorLocalStatus _detectPgvectorLocal() {
    if (!Platform.isMacOS) return _PgvectorLocalStatus.unknown;

    if (_pgvectorInstalledForPostgres16()) {
      return _PgvectorLocalStatus.installed;
    }

    if (_pgvectorLegacyLibraryDetected()) return _PgvectorLocalStatus.installed;

    final brewStatus = _detectPgvectorStatusFromBrew();
    if (brewStatus != null) return brewStatus;

    return _PgvectorLocalStatus.notInstalled;
  }

  bool _pgvectorInstalledForPostgres16() {
    if (!Platform.isMacOS) return false;
    for (final prefix in _postgres16OptPrefixes) {
      final control = File(
        '$prefix/share/postgresql@16/extension/vector.control',
      );
      final dynamicLibraryCandidates = _pgvectorPostgres16DynamicLibraries(
        prefix,
      );
      if (control.existsSync() && _anyFileExists(dynamicLibraryCandidates)) {
        return true;
      }
    }
    return false;
  }
}
