part of '../desktop_shell.dart';

extension _DesktopShellInstallRunner on _DesktopShellState {
  Future<bool> _runInstallCommand(
    String executable,
    List<String> args,
    String action, {
    String? workingDirectory,
  }) async {
    try {
      _appendLog('正在尝试：$action');
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
        _appendLog('安装命令成功：$action');
        return true;
      }
      if (timedOut) {
        _appendLog('安装超时（$action），已终止进程。');
        return false;
      }
      final details = err.trim().isNotEmpty ? err : out;
      _appendLog('安装失败（$action）：${_shortProcessOutput(details)}');
      return false;
    } catch (error) {
      _appendLog('安装失败（$action）：$error');
      return false;
    }
  }
}
