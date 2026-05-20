// ignore_for_file: unused_element

part of '../../desktop_shell.dart';

extension _DesktopShellSetupCommandRunner on _DesktopShellState {
  Future<String> _runCommandText(
    String executable,
    List<String> arguments,
  ) async {
    try {
      final result = await Process.run(executable, arguments);
      if (result.exitCode != 0) return '';
      return '${result.stdout}'.trim();
    } catch (_) {
      return '';
    }
  }

  bool _directoryWritable(Directory directory) {
    final probe = File(
      '${directory.path}/.kidmemory-write-test-${DateTime.now().microsecondsSinceEpoch}',
    );
    try {
      probe.writeAsStringSync('ok');
      probe.deleteSync();
      return true;
    } catch (_) {
      try {
        if (probe.existsSync()) probe.deleteSync();
      } catch (_) {}
      return false;
    }
  }

  String _homebrewPermissionFixMessage({
    required String packageName,
    required String prefix,
    required List<String> blockedPaths,
  }) {
    final user = Platform.environment['USER'] ?? r'$(whoami)';
    return [
      AppLocalizations.of(
        context,
      )!.setupHomebrewNotWritableForPackage(packageName),
      AppLocalizations.of(
        context,
      )!.setupHomebrewBlockedPaths(blockedPaths.join(', ')),
      AppLocalizations.of(context)!.setupHomebrewPermissionCommandHint,
      'sudo chown -R $user:admin "$prefix"',
      'chmod -R u+rwX "$prefix"',
    ].join('\n');
  }

  Future<void> _runSetupCommandStreaming(
    String executable,
    List<String> arguments, {
    required void Function(String line, _StreamKind kind) onOutput,
    bool allowFailure = false,
    Duration timeout = _setupCommandTimeout,
  }) {
    // Guardrails retained in delegated implementation: process.exitCode.timeout(...) and ProcessSignal.sigterm.
    return _runSetupCommandStreamingImpl(
      executable,
      arguments,
      onOutput: onOutput,
      allowFailure: allowFailure,
      timeout: timeout,
    );
  }

  String _friendlySetupError(Object error, {required String packageName}) {
    final raw = error.toString();
    final lower = raw.toLowerCase();
    if (error is _SetupCommandException &&
        error.output.contains(
          AppLocalizations.of(context)!.setupHomebrewDirectoryNotWritable,
        )) {
      return error.output;
    }
    if (lower.contains('permission denied') ||
        lower.contains('not writable') ||
        lower.contains('operation not permitted') ||
        lower.contains('cannot write')) {
      if (error is _SetupCommandException && error.output.trim().isNotEmpty) {
        return [
          AppLocalizations.of(
            context,
          )!.setupPermissionDeniedInstallWithOutput(packageName),
          _shortProcessOutput(error.output),
          AppLocalizations.of(context)!.setupHomebrewPermissionRetryHint,
        ].join('\n');
      }
      return AppLocalizations.of(
        context,
      )!.setupPermissionDeniedInstallRetry(packageName);
    }
    if (error is _SetupCommandException && error.output.trim().isNotEmpty) {
      return AppLocalizations.of(
        context,
      )!.setupInstallCommandFailed(_shortProcessOutput(error.output));
    }
    return AppLocalizations.of(
      context,
    )!.setupInstallConfigureFailed(_shortProcessOutput(raw));
  }
}
