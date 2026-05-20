part of '../desktop_shell.dart';

extension _DesktopShellInstallRunner on _DesktopShellState {
  Future<bool> _runInstallCommand(
    String executable,
    List<String> args,
    String action, {
    String? workingDirectory,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      _appendLog(l10n.installRunnerAttemptLog(action));
      final process = await Process.start(
        executable,
        args,
        workingDirectory: workingDirectory,
      );

      final outFuture = process.stdout.transform(utf8.decoder).join();
      final errFuture = process.stderr.transform(utf8.decoder).join();
      var timedOut = false;

      final exitCode = await process.exitCode.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          timedOut = true;
          process.kill(ProcessSignal.sigterm);
          return -1;
        },
      );

      final output = await Future.wait([
        outFuture,
        errFuture,
      ]).timeout(const Duration(seconds: 5), onTimeout: () => const ['', '']);
      final out = output[0];
      final err = output[1];

      if (exitCode == 0) {
        _appendLog(l10n.installRunnerCommandSucceededLog(action));
        return true;
      }
      if (timedOut) {
        _appendLog(l10n.installRunnerTimeoutLog(action));
        return false;
      }
      final details = err.trim().isNotEmpty ? err : out;
      _appendLog(
        l10n.installRunnerFailedWithOutputLog(
          action,
          _shortProcessOutput(details),
        ),
      );
      return false;
    } catch (error) {
      _appendLog(l10n.installRunnerFailedWithErrorLog(action, error));
      return false;
    }
  }
}
