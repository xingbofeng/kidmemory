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
    if (await _tryInstallNode(
      executableName: 'volta',
      args: ['install', 'node'],
      action: AppLocalizations.of(context)!.nodeInstallS161,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'fnm',
      args: ['install', 'lts-latest'],
      action: AppLocalizations.of(context)!.nodeInstallS177,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'port',
      args: ['install', 'nodejs18'],
      action: AppLocalizations.of(context)!.nodeInstallS123,
    )) {
      return true;
    }

    final nodenv = _findExecutable('nodenv');
    if (nodenv != null) {
      await _runInstallCommand(nodenv, [
        'install',
        '22.15.0',
      ], AppLocalizations.of(context)!.nodeInstallS180);
      final reloaded = _findExecutable('node');
      if (reloaded != null) return true;
    }

    final brew = _findExecutable('brew');
    if (brew == null) {
      _appendLog(AppLocalizations.of(context)!.nodeInstallS586);
      return false;
    }
    if (!await _runInstallCommand(brew, [
      'install',
      'node',
    ], AppLocalizations.of(context)!.nodeInstallS115)) {
      return false;
    }
    return _findExecutable('node') != null;
  }

  Future<bool> _installNodeWindows() async {
    if (await _tryInstallNode(
      executableName: 'winget',
      args: [
        'install',
        'OpenJS.NodeJS.LTS',
        '--accept-source-agreements',
        '--accept-package-agreements',
        '--silent',
      ],
      action: AppLocalizations.of(context)!.nodeInstallS202,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'choco',
      args: ['install', 'nodejs', '-y'],
      action: AppLocalizations.of(context)!.nodeInstallS111,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'scoop',
      args: ['install', 'nodejs-lts'],
      action: AppLocalizations.of(context)!.nodeInstallS139,
    )) {
      return true;
    }

    _appendLog(AppLocalizations.of(context)!.nodeInstallS594);
    return false;
  }

  Future<bool> _installNodeLinux() async {
    if (await _tryInstallNode(
      executableName: 'apt-get',
      args: ['install', '-y', 'nodejs', 'npm'],
      action: AppLocalizations.of(context)!.nodeInstallS167,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'dnf',
      args: ['install', '-y', 'nodejs'],
      action: AppLocalizations.of(context)!.nodeInstallS176,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'yum',
      args: ['install', '-y', 'nodejs'],
      action: AppLocalizations.of(context)!.nodeInstallS203,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'pacman',
      args: ['-Sy', '--noconfirm', 'nodejs'],
      action: AppLocalizations.of(context)!.nodeInstallS181,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'zypper',
      args: ['--non-interactive', 'in', '-y', 'nodejs'],
      action: AppLocalizations.of(context)!.nodeInstallS204,
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'apk',
      args: ['add', '--no-cache', 'nodejs', 'npm'],
      action: AppLocalizations.of(context)!.nodeInstallS166,
    )) {
      return true;
    }

    _appendLog(AppLocalizations.of(context)!.nodeInstallS593);
    return false;
  }
}
