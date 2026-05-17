part of '../desktop_shell.dart';

_KidMemoryPathSet _defaultKidMemoryPaths() {
  final separator = Platform.pathSeparator;
  final home =
      Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE'] ??
      '~';
  final appRoot = Platform.isMacOS
      ? [home, 'Library', 'Application Support', 'KidMemory'].join(separator)
      : Platform.isWindows
      ? [Platform.environment['APPDATA'] ?? home, 'KidMemory'].join(separator)
      : [home, '.local', 'share', 'KidMemory'].join(separator);
  return (
    dataDir: [appRoot, 'data'].join(separator),
    workspaceDir: [appRoot, 'workspace'].join(separator),
    exportDir: [appRoot, 'exports'].join(separator),
  );
}

_KidMemoryPathSet _pathsForDataRoot(String rootPath) {
  final root = _trimTrailingPathSeparator(rootPath.trim());
  return (
    dataDir: _resolveConfiguredPath(
      _joinPath(root, 'data'),
      _defaultKidMemoryPaths().dataDir,
    ),
    workspaceDir: _resolveConfiguredPath(
      _joinPath(root, 'workspace'),
      _defaultKidMemoryPaths().workspaceDir,
    ),
    exportDir: _resolveConfiguredPath(
      _joinPath(root, 'exports'),
      _defaultKidMemoryPaths().exportDir,
    ),
  );
}

String _joinPath(String left, String right) {
  if (left.isEmpty) return right;
  return '$left${Platform.pathSeparator}$right';
}

String _trimTrailingPathSeparator(String value) {
  var output = value;
  while (output.length > 1 && output.endsWith(Platform.pathSeparator)) {
    output = output.substring(0, output.length - 1);
  }
  return output;
}

bool _isAbsolutePath(String value) {
  if (value.startsWith('/') || value.startsWith(r'\\')) return true;
  return RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value);
}

String _resolveConfiguredPath(String configured, String fallbackAbsolute) {
  final trimmed = configured.trim();
  if (trimmed.isEmpty) return fallbackAbsolute;
  if (_isAbsolutePath(trimmed)) return _trimTrailingPathSeparator(trimmed);

  final appRoot = Directory(fallbackAbsolute).parent.path;
  final normalized = trimmed.replaceAll('\\', '/');
  if (normalized == '.kidmemory') return appRoot;
  if (normalized.startsWith('.kidmemory/')) {
    final suffix = normalized.substring('.kidmemory/'.length);
    if (suffix.isEmpty) return appRoot;
    final segments = suffix.split('/').where((part) => part.isNotEmpty);
    return _trimTrailingPathSeparator(
      segments.fold<String>(appRoot, (left, right) => _joinPath(left, right)),
    );
  }
  final relative = normalized.startsWith('./')
      ? normalized.substring(2)
      : normalized;
  final segments = relative.split('/').where((part) => part.isNotEmpty);
  return _trimTrailingPathSeparator(
    segments.fold<String>(appRoot, (left, right) => _joinPath(left, right)),
  );
}

List<SetupCheckVm> _disconnectedSetupChecks() {
  final paths = _defaultKidMemoryPaths();
  return [
    SetupCheckVm(
      index: '1',
      title: '大模型接口配置',
      body: '提供文本生成、标签与提示词能力。请配置 Base URL、模型与 API Key。',
      action: '测试连接',
      secondaryActionLabel: '修改配置',
      secondaryActionPath: '__action__:配置',
      state: '需配置',
      ok: false,
      actionEnabled: false,
    ),
    SetupCheckVm(
      index: '2',
      title: '本地数据目录',
      body: _localDataDirectoryDescription(paths),
      action: '配置目录',
      secondaryActionLabel: '打开目录',
      secondaryActionPath: paths.dataDir,
      state: '已配置',
      ok: true,
      actionEnabled: true,
    ),
  ];
}

String _localDataDirectoryDescription(_KidMemoryPathSet paths) {
  return '为 KidMemory 提供核心数据库连接，保存孩子资料、素材和生成历史。';
}
