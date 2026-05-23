import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/core/logging/desktop_log_cleanup_worker.dart';
import 'package:kidmemory_desktop/core/logging/desktop_logger.dart';
import 'package:kidmemory_desktop/core/logging/desktop_trace_context.dart';

void main() {
  test('DesktopTraceContext creates traceId and requestId', () {
    final trace = DesktopTraceContext();

    trace.beginAction();
    final traceId = trace.traceId;
    final requestId = trace.nextRequestId();

    expect(traceId, isNotEmpty);
    expect(requestId, isNotEmpty);
    expect(requestId.startsWith('req_'), isTrue);
  });

  test('DesktopLogger writes JSONL and redacts sensitive fields', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'desktop-logger-test-',
    );
    addTearDown(() async => tempDir.delete(recursive: true));

    final logger = DesktopLogger(logsDirectoryPath: tempDir.path);
    await logger.append(
      level: DesktopLogLevel.info,
      event: 'desktop.action.generate_book',
      traceId: 'trace_test_1',
      requestId: 'req_test_1',
      data: const {
        'apiKey': 'sk-test-secret',
        'token': 'token-secret',
        'note': 'safe-value',
      },
    );

    final files = tempDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.jsonl'))
        .toList();
    expect(files, isNotEmpty);

    final lines = (await files.first.readAsString())
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    expect(lines, isNotEmpty);

    final row = jsonDecode(lines.first) as Map<String, dynamic>;
    expect(row['event'], 'desktop.action.generate_book');
    expect(row['traceId'], 'trace_test_1');
    expect((row['data'] as Map<String, dynamic>)['apiKey'], '[REDACTED]');
    expect((row['data'] as Map<String, dynamic>)['token'], '[REDACTED]');
    expect((row['data'] as Map<String, dynamic>)['note'], 'safe-value');
  });

  test('DesktopLogCleanupWorker deletes stale JSONL files', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'desktop-log-cleanup-test-',
    );
    addTearDown(() async => tempDir.delete(recursive: true));

    final stale = File('${tempDir.path}/desktop-2020-01-01.jsonl');
    await stale.writeAsString('{"event":"old"}\n');
    await stale.setLastModified(
      DateTime.now().subtract(const Duration(days: 30)),
    );

    final fresh = File('${tempDir.path}/desktop-2099-01-01.jsonl');
    await fresh.writeAsString('{"event":"new"}\n');

    final worker = DesktopLogCleanupWorker(logsDirectoryPath: tempDir.path);
    final result = await worker.cleanup(retainDays: 7);

    expect(result.deleted, greaterThanOrEqualTo(1));
    expect(await stale.exists(), isFalse);
    expect(await fresh.exists(), isTrue);
  });
}
