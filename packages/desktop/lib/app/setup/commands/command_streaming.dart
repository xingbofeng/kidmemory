part of '../../desktop_shell.dart';

const String _setupCommandPath =
    '/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin';

extension _DesktopShellSetupCommandStreaming on _DesktopShellState {
  Future<void> _runSetupCommandStreamingImpl(
    String executable,
    List<String> arguments, {
    required void Function(String line, _StreamKind kind) onOutput,
    bool allowFailure = false,
    Duration timeout = _setupCommandTimeout,
  }) async {
    final recentOutput = <String>[];

    void recordOutput(String line, _StreamKind kind) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        recentOutput.add(trimmed);
        if (recentOutput.length > 12) recentOutput.removeAt(0);
      }
      onOutput(line, kind);
    }

    final process = await Process.start(
      executable,
      arguments,
      environment: const {
        'PATH': _setupCommandPath,
      },
    );

    final stdoutDone = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => recordOutput(line, _StreamKind.stdout))
        .asFuture<void>();
    final stderrDone = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => recordOutput(line, _StreamKind.stderr))
        .asFuture<void>();

    var timedOut = false;
    final exitCode = await process.exitCode.timeout(
      timeout,
      onTimeout: () {
        timedOut = true;
        process.kill(ProcessSignal.sigterm);
        return -1;
      },
    );
    await Future.wait([
      stdoutDone,
      stderrDone,
    ]).timeout(const Duration(seconds: 3), onTimeout: () => const <void>[]);

    if (timedOut) {
      throw _SetupCommandException(
        [executable, ...arguments].join(' '),
        exitCode,
        [
          ...recentOutput,
          '命令执行超过 ${timeout.inMinutes} 分钟，已自动停止；请检查网络、Homebrew 或数据库服务状态后重试。',
        ].join('\n'),
      );
    }

    if (!allowFailure && exitCode != 0) {
      throw _SetupCommandException(
        [executable, ...arguments].join(' '),
        exitCode,
        recentOutput.join('\n'),
      );
    }
  }
}
