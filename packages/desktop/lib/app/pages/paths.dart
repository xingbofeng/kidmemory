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
    dataDir: _joinPath(root, 'data'),
    workspaceDir: _joinPath(root, 'workspace'),
    exportDir: _joinPath(root, 'exports'),
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

List<SetupCheckVm> _disconnectedSetupChecks() {
  final paths = _defaultKidMemoryPaths();
  return [
    SetupCheckVm(
      index: '1',
      title: 'PostgreSQL 配置',
      body: 'KidMemory 的本地资料库，保存孩子档案、素材元数据和任务记录。',
      action: '安装与配置',
      state: '需配置',
      ok: false,
    ),
    SetupCheckVm(
      index: '2',
      title: _sidecarSetupTitle,
      body: '负责配置检测、数据库初始化、素材导入和生成任务。PostgreSQL 就绪后会自动启动。',
      action: '启动 Sidecar',
      state: '等待 PG',
      ok: false,
      actionEnabled: false,
    ),
    SetupCheckVm(
      index: '3',
      title: 'pgvector 检测',
      body: 'pgvector 是 PostgreSQL 的独立扩展，用于语义检索和相似内容匹配。',
      action: '安装与配置',
      state: '需配置',
      ok: false,
      actionEnabled: false,
    ),
    SetupCheckVm(
      index: '4',
      title: 'OpenAI-compatible API',
      body:
          '提供文本生成、标签与提示词能力。可配置 OPENAI_API_KEY，或填写兼容 OpenAI 的 Base URL、模型与 Key。',
      action: '配置',
      state: '需配置',
      ok: false,
      actionEnabled: false,
    ),
    SetupCheckVm(
      index: '5',
      title: '本地数据目录',
      body: _localDataDirectoryDescription(paths),
      action: '配置目录',
      secondaryActionLabel: '打开目录',
      secondaryActionPath: paths.dataDir,
      state: '默认目录',
      ok: true,
      actionEnabled: false,
    ),
  ];
}

String _localDataDirectoryDescription(_KidMemoryPathSet paths) {
  return [
    '统一管理向量索引、元数据缓存和导出文件。',
    '数据目录：${paths.dataDir}',
    '工作区：${paths.workspaceDir}',
    '导出目录：${paths.exportDir}',
  ].join('\n');
}
