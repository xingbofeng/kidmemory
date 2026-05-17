part of '../desktop_shell.dart';

extension _DesktopShellReadinessRules on _DesktopShellState {
  String _setupActionForTitle(Object? rawAction, String title) {
    if (title == 'PostgreSQL 配置' ||
        title == _sidecarSetupTitle ||
        title == 'pgvector 检测' ||
        title == '大模型接口配置' ||
        title == '本地数据目录') {
      return _defaultSetupAction(title);
    }
    final resolved = '$rawAction'.trim();
    if (resolved.isEmpty || resolved == 'null') {
      return _defaultSetupAction(title);
    }
    if (_defaultSetupAction(title) == resolved) {
      return resolved;
    }
    return resolved;
  }

  String _defaultSetupAction(String title) {
    return switch (title) {
      'PostgreSQL 配置' => '安装与配置',
      _sidecarSetupTitle => '启动 Sidecar',
      'pgvector 检测' => '安装与配置',
      '大模型接口配置' => '配置',
      '本地数据目录' => '配置目录',
      _ => '查看',
    };
  }

  String _extractSetupPurpose(String body) {
    final lines = body.split('\n');
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line == '用途') return '系统配置项。';
      if (line.startsWith('用途：')) {
        return line.replaceFirst('用途：', '').trim();
      }
      if (line.startsWith('用途:')) {
        return line.replaceFirst('用途:', '').trim();
      }
      if (line.startsWith('用途')) {
        final marker = line.indexOf('：');
        if (marker != -1 && marker + 1 < line.length) {
          return line.substring(marker + 1).trim();
        }
      }
      return line;
    }
    return '系统配置项。';
  }
}
