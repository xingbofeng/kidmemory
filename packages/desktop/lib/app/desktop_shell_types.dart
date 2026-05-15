part of 'desktop_shell.dart';

typedef _KidMemoryPathSet = ({
  String dataDir,
  String workspaceDir,
  String exportDir,
});

typedef _SetupDirectoryPaths = ({
  String primary,
  String data,
  String workspace,
  String exportDir,
});

enum _PgLocalStatus { notInstalled, installedNotRunning, running, unknown }

enum _PgvectorLocalStatus { notInstalled, installed, unknown }

enum _StreamKind { stdout, stderr }

const _sidecarDisconnectedMessage = 'Sidecar 未连接';
const _sidecarSetupTitle = 'Sidecar 本地服务';
const _setupCommandTimeout = Duration(minutes: 8);

class _SetupCommandException implements Exception {
  const _SetupCommandException(this.command, this.exitCode, this.output);

  final String command;
  final int exitCode;
  final String output;

  @override
  String toString() {
    final details = output.trim();
    if (details.isEmpty) return '$command failed with exit code $exitCode';
    return '$command failed with exit code $exitCode: $details';
  }
}
