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
      action: 'Volta 安装 Node.js',
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'fnm',
      args: ['install', 'lts-latest'],
      action: 'fnm 安装 Node.js',
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'port',
      args: ['install', 'nodejs18'],
      action: 'MacPorts 安装 Node.js',
    )) {
      return true;
    }

    final nodenv = _findExecutable('nodenv');
    if (nodenv != null) {
      await _runInstallCommand(nodenv, [
        'install',
        '22.15.0',
      ], 'nodenv 安装 Node.js');
      final reloaded = _findExecutable('node');
      if (reloaded != null) return true;
    }

    final brew = _findExecutable('brew');
    if (brew == null) {
      _appendLog('未找到可用的 macOS Node.js 安装器，请先安装 Node.js 后重试。');
      return false;
    }
    if (!await _runInstallCommand(brew, [
      'install',
      'node',
    ], 'Homebrew 安装 Node.js')) {
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
      action: 'winget 安装 Node.js',
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'choco',
      args: ['install', 'nodejs', '-y'],
      action: 'Chocolatey 安装 Node.js',
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'scoop',
      args: ['install', 'nodejs-lts'],
      action: 'Scoop 安装 Node.js',
    )) {
      return true;
    }

    _appendLog('未检测到可用的 Windows Node.js 安装器。');
    return false;
  }

  Future<bool> _installNodeLinux() async {
    if (await _tryInstallNode(
      executableName: 'apt-get',
      args: ['install', '-y', 'nodejs', 'npm'],
      action: 'apt-get 安装 Node.js',
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'dnf',
      args: ['install', '-y', 'nodejs'],
      action: 'dnf 安装 Node.js',
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'yum',
      args: ['install', '-y', 'nodejs'],
      action: 'yum 安装 Node.js',
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'pacman',
      args: ['-Sy', '--noconfirm', 'nodejs'],
      action: 'pacman 安装 Node.js',
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'zypper',
      args: ['--non-interactive', 'in', '-y', 'nodejs'],
      action: 'zypper 安装 Node.js',
    )) {
      return true;
    }

    if (await _tryInstallNode(
      executableName: 'apk',
      args: ['add', '--no-cache', 'nodejs', 'npm'],
      action: 'apk 安装 Node.js',
    )) {
      return true;
    }

    _appendLog('未检测到可用的 Linux Node.js 安装器。');
    return false;
  }
}
