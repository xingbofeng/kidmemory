part of '../desktop_shell.dart';

extension _DesktopShellNodeInstall on _DesktopShellState {
  Future<bool> _tryInstallNode({
    required String executableName,
    required List<String> args,
    required String action,
  }) async {
    final executable = _findExecutable(executableName);
    if (executable == null) return false;
    if (!await _runInstallCommand(executable, args, action)) return false;
    return _findExecutable('node') != null;
  }

  Future<bool> _installNodeMacOS() async {
    final l10n = AppLocalizations.of(context)!;
    if (await _tryInstallNode(
      executableName: 'volta',
      args: ['install', 'node'],
      action: l10n.nodeInstallS161,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'fnm',
      args: ['install', 'lts-latest'],
      action: l10n.nodeInstallS177,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'port',
      args: ['install', 'nodejs18'],
      action: l10n.nodeInstallS123,
    )) {
      return true;
    }

    final nodenv = _findExecutable('nodenv');
    if (nodenv != null) {
      await _runInstallCommand(nodenv, [
        'install',
        '22.15.0',
      ], l10n.nodeInstallS180);
      final reloaded = _findExecutable('node');
      if (reloaded != null) return true;
    }

    final brew = _findExecutable('brew');
    if (brew == null) {
      _appendLog(l10n.nodeInstallS586);
      return false;
    }
    if (!await _runInstallCommand(brew, [
      'install',
      'node',
    ], l10n.nodeInstallS115)) {
      return false;
    }
    return _findExecutable('node') != null;
  }

  Future<bool> _installNodeWindows() async {
    final l10n = AppLocalizations.of(context)!;
    if (await _tryInstallNode(
      executableName: 'winget',
      args: [
        'install',
        'OpenJS.NodeJS.LTS',
        '--accept-source-agreements',
        '--accept-package-agreements',
        '--silent',
      ],
      action: l10n.nodeInstallS202,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'choco',
      args: ['install', 'nodejs', '-y'],
      action: l10n.nodeInstallS111,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'scoop',
      args: ['install', 'nodejs-lts'],
      action: l10n.nodeInstallS139,
    )) {
      return true;
    }

    _appendLog(l10n.nodeInstallS594);
    return false;
  }

  Future<bool> _installNodeLinux() async {
    final l10n = AppLocalizations.of(context)!;
    if (await _tryInstallNode(
      executableName: 'apt-get',
      args: ['install', '-y', 'nodejs', 'npm'],
      action: l10n.nodeInstallS167,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'dnf',
      args: ['install', '-y', 'nodejs'],
      action: l10n.nodeInstallS176,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'yum',
      args: ['install', '-y', 'nodejs'],
      action: l10n.nodeInstallS203,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'pacman',
      args: ['-Sy', '--noconfirm', 'nodejs'],
      action: l10n.nodeInstallS181,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'zypper',
      args: ['--non-interactive', 'in', '-y', 'nodejs'],
      action: l10n.nodeInstallS204,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'apk',
      args: ['add', '--no-cache', 'nodejs', 'npm'],
      action: l10n.nodeInstallS166,
    )) {
      return true;
    }

    _appendLog(l10n.nodeInstallS593);
    return false;
  }
}
