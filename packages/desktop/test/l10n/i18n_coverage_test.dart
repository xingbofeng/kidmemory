// @dart=3.5
import 'dart:io';

import 'package:test/test.dart';

/// Files/directories that are allowed to have Chinese strings (l10n infra).
const _allowedPrefixes = <String>[
  'lib/l10n',
  '.dart_tool',
];

const _exactFileNames = <String>{
  '/l10n_keys_test.dart',
  '/i18n_coverage_test.dart',
};

/// Check if a line appears to be a hardcoded Chinese UI string in Dart.
bool _isHardcodedChineseUiString(String line) {
  final trimmed = line.trimLeft();
  // Skip comments, imports, annotations, doc comments
  if (trimmed.startsWith('//') ||
      trimmed.startsWith('import ') ||
      trimmed.startsWith('@') ||
      trimmed.startsWith('///')) {
    return false;
  }

  // Look for any Chinese characters in the line
  for (var i = 0; i < line.length; i++) {
    final code = line.codeUnitAt(i);
    if (code >= 0x4E00 && code <= 0x9FFF) {
      // Don't count the l10n_keys_test.dart pattern itself
      if (trimmed.contains('0x4E00') && trimmed.contains('0x9FFF')) continue;
      return true;
    }
  }

  return false;
}

Set<String> _findHardcodedStrings(Directory dir) {
  final results = <String>{};
  final entities = dir.listSync(recursive: true);
  for (final entity in entities) {
    if (entity is! File) continue;
    final path = entity.path.replaceAll('\\', '/');

    if (_allowedPrefixes.any((p) => path.contains(p))) continue;
    if (_exactFileNames.any((s) => path.endsWith(s))) continue;
    if (!path.endsWith('.dart')) continue;

    final lines = File(entity.path).readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (_isHardcodedChineseUiString(lines[i])) {
        results.add(
          '  ${path.replaceAll('${dir.path}/', '')}:${i + 1}: ${lines[i].trim()}',
        );
      }
    }
  }
  return results;
}

void main() {
  test('lib/ has zero hardcoded Chinese UI strings (use AppLocalizations)', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue);

    final violations = _findHardcodedStrings(libDir);
    if (violations.isNotEmpty) {
      stdout.writeln('\nFound ${violations.length} hardcoded Chinese strings:');
      final sorted = violations.toList()..sort();
      for (final v in sorted.take(30)) {
        stdout.writeln(v);
      }
      if (sorted.length > 30) {
        stdout.writeln('  ... and ${sorted.length - 30} more');
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Found ${violations.length} hardcoded Chinese strings in lib/. '
          'All UI strings must use AppLocalizations.of(context) instead.\n'
          'Run: dart test test/l10n/i18n_coverage_test.dart',
    );
  });
}
