part of '../../desktop_shell.dart';

extension _DesktopShellSetupCommandRunner on _DesktopShellState {
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
