part of 'desktop_shell.dart';

typedef _KidMemoryPathSet = ({
  String dataDir,
  String workspaceDir,
  String exportDir,
});

enum _PgvectorLocalStatus { notInstalled, installed, unknown }

enum _StreamKind { stdout, stderr }

String _sidecarDisconnectedMessage(BuildContext context) =>
    AppLocalizations.of(context)!.setupSidecarDisconnected;

String _sidecarSetupTitle(BuildContext context) =>
    AppLocalizations.of(context)!.setupAgentServiceTitle;

const _setupCommandTimeout = Duration(minutes: 8);

const String _setupCommandPath =
    '/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin';

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
