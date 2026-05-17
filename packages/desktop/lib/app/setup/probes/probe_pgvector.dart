part of '../../desktop_shell.dart';

extension _DesktopShellSetupProbePgvector on _DesktopShellState {
  List<String> _pgvectorPostgres16DynamicLibraries(String prefix) {
    return [
      '$prefix/lib/postgresql/vector.dylib',
      '$prefix/lib/postgresql/vector.so',
      '$prefix/lib/postgresql@16/vector.dylib',
      '$prefix/lib/postgresql@16/vector.so',
    ];
  }

  _PgvectorLocalStatus _detectPgvectorLocal() {
    if (!Platform.isMacOS) return _PgvectorLocalStatus.unknown;
    if (!_bundledPostgresRuntimeAvailable()) {
      return _PgvectorLocalStatus.notInstalled;
    }

    if (_pgvectorInstalledForPostgres16()) {
      return _PgvectorLocalStatus.installed;
    }

    return _PgvectorLocalStatus.notInstalled;
  }

  bool _pgvectorInstalledForPostgres16() {
    if (!Platform.isMacOS) return false;
    final bundledPrefix = _bundledPostgresRuntimeDirectory()?.path;
    final bundledPrefixes = bundledPrefix == null
        ? const <String>[]
        : <String>[bundledPrefix];
    final prefixes = [...bundledPrefixes];
    for (final prefix in prefixes) {
      final control = File(
        '$prefix/share/postgresql@16/extension/vector.control',
      );
      final bundledControl = File('$prefix/share/extension/vector.control');
      final dynamicLibraryCandidates = _pgvectorPostgres16DynamicLibraries(
        prefix,
      );
      final bundledLibraryCandidates = [
        '$prefix/lib/vector.dylib',
        '$prefix/lib/vector.so',
      ];
      if ((control.existsSync() && _anyFileExists(dynamicLibraryCandidates)) ||
          (bundledControl.existsSync() &&
              _anyFileExists(bundledLibraryCandidates))) {
        return true;
      }
    }
    return false;
  }
}
