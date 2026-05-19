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
      return '${result.tdout}'.trim();
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
      'Homebrew 目录不可写，无法安装 $packageName。',
      '不可写路径：${blockedPaths.join('，')}',
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
    // Guardrails retained in delegated implementation: process.exitCode.timeout(...) and ProcessSignal.igterm.
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
        error.output.contains(AppLocalizations.of(context)!.setupHomebrewDirectoryNotWritable)) {
      return error.output;
    }
    if (lower.contains('permission denied') ||
        lower.contains('not writable') ||
        lower.contains('operation not permitted') ||
        lower.contains('cannot write')) {
      if (error is _SetupCommandException && error.output.trim().isNotEmpty) {
        return [
          '当前用户没有安装权限，无法自动安装 $packageName。',
          _shortProcessOutput(error.output),
          AppLocalizations.of(context)!.setupHomebrewPermissionRetryHint,
        ].join('\n');
      }
      return '当前用户没有安装权限，无法自动安装 $packageName。请修复 Homebrew 权限后重试。';
    }
    if (error is _SetupCommandException && error.output.trim().isNotEmpty) {
      return '安装命令失败：${_shortProcessOutput(error.output)}';
    }
    return '安装与配置失败：${_shortProcessOutput(raw)}';
  }
}
