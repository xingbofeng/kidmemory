import 'dart:convert';
import 'dart:io';

enum DesktopLogLevel { debug, info, warn, error }

class DesktopLogger {
  DesktopLogger({String? logsDirectoryPath})
    : logsDirectoryPath = logsDirectoryPath ?? _defaultLogsDirectoryPath();

  final String logsDirectoryPath;

  Future<void> append({
    required DesktopLogLevel level,
    required String event,
    String? traceId,
    String? requestId,
    Map<String, dynamic>? data,
  }) async {
    final directory = Directory(logsDirectoryPath);
    await directory.create(recursive: true);

    final row = <String, dynamic>{
      'ts': DateTime.now().toUtc().toIso8601String(),
      'level': level.name,
      'source': 'desktop',
      'event': event,
      if (traceId != null && traceId.trim().isNotEmpty) 'traceId': traceId.trim(),
      if (requestId != null && requestId.trim().isNotEmpty) 'requestId': requestId.trim(),
      if (data != null && data.isNotEmpty) 'data': _redactSensitive(data),
    };

    final file = File(_currentLogFilePath(directory.path));
    await file.writeAsString('${jsonEncode(row)}\n', mode: FileMode.append, flush: true);
  }

  static String _defaultLogsDirectoryPath() {
    final env = Platform.environment;
    final customRoot = env['KIDMEMORY_ROOT_DIR']?.trim();
    if (customRoot != null && customRoot.isNotEmpty) {
      return '$customRoot/logs/desktop';
    }

    final home = env['HOME'] ?? env['USERPROFILE'] ?? Directory.current.path;
    if (Platform.isMacOS) {
      return '$home/Library/Application Support/KidMemory/logs/desktop';
    }
    if (Platform.isWindows) {
      final appData = env['APPDATA'] ?? home;
      return '$appData/KidMemory/logs/desktop';
    }
    return '$home/.local/share/KidMemory/logs/desktop';
  }

  static String _currentLogFilePath(String directoryPath) {
    final now = DateTime.now().toUtc();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$directoryPath/desktop-$y-$m-$d.jsonl';
  }
}

Map<String, dynamic> _redactSensitive(Map<String, dynamic> source) {
  const sensitive = [
    'api_key',
    'apikey',
    'token',
    'password',
    'secret',
    'authorization',
    'cookie',
  ];

  final result = <String, dynamic>{};
  source.forEach((key, value) {
    final lower = key.toLowerCase();
    final shouldMask = sensitive.any((pattern) => lower.contains(pattern));
    if (shouldMask) {
      result[key] = '[REDACTED]';
      return;
    }

    if (value is Map<String, dynamic>) {
      result[key] = _redactSensitive(value);
      return;
    }

    if (value is List) {
      result[key] = value
          .map((item) => item is Map<String, dynamic> ? _redactSensitive(item) : item)
          .toList();
      return;
    }

    result[key] = value;
  });

  return result;
}
