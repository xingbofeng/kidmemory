import 'dart:io';

class DesktopLogCleanupResult {
  const DesktopLogCleanupResult({required this.deleted, required this.retainedDays});

  final int deleted;
  final int retainedDays;
}

class DesktopLogCleanupWorker {
  DesktopLogCleanupWorker({required this.logsDirectoryPath});

  final String logsDirectoryPath;

  Future<DesktopLogCleanupResult> cleanup({int retainDays = 14}) async {
    final normalizedRetainDays = retainDays <= 0 ? 1 : retainDays;
    final directory = Directory(logsDirectoryPath);
    await directory.create(recursive: true);

    final now = DateTime.now();
    final entries = await directory.list().toList();

    var deleted = 0;
    for (final entry in entries) {
      if (entry is! File || !entry.path.endsWith('.jsonl')) {
        continue;
      }

      final modified = await entry.lastModified();
      final age = now.difference(modified).inDays;
      if (age > normalizedRetainDays) {
        await entry.delete();
        deleted += 1;
      }
    }

    return DesktopLogCleanupResult(
      deleted: deleted,
      retainedDays: normalizedRetainDays,
    );
  }
}
