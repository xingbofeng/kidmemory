part of '../desktop_shell.dart';

extension _DesktopShellReadinessRules on _DesktopShellState {
  String _setupActionForTitle(Object? rawAction, String title) {
    if (title == 'PostgreSQL 配置' ||
        title == _sidecarSetupTitle ||
        title == 'pgvector 检测') {
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
      'OpenAI-compatible API' => '配置',
      '本地数据目录' => '配置目录',
      _ => '查看',
    };
  }

  _SetupDirectoryPaths _extractSetupDirectoryPaths(String body) {
    final lines = body.split('\n');
    final paths = <String>[];
    for (final line in lines) {
      final match = RegExp(
        r'(?:(?:[A-Za-z]:)?[/\\\\][^\\s]+)',
      ).firstMatch(line);
      if (match == null) continue;
      final path = match.group(0) ?? '';
      if (path.isEmpty) continue;
      if (path.startsWith('http://') || path.startsWith('https://')) continue;
      paths.add(path);
    }

    return (
      primary: paths.isNotEmpty ? paths.first : '',
      data: paths.isNotEmpty ? paths[0] : '',
      workspace: paths.length > 1 ? paths[1] : '',
      exportDir: paths.length > 2 ? paths[2] : '',
    );
  }

  String _readableLocalDataBodyFromRaw(String body) {
    final _ = _extractSetupDirectoryPaths(body);
    return '统一管理向量索引、元数据缓存和导出文件。';
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

  bool _deprecatedSetupCheckTitle(String title) {
    return title.contains('Claude Agent SDK') ||
        title.contains('Cloud Agent SDK');
  }
}
