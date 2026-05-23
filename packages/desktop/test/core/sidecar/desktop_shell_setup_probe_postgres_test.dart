import 'package:flutter_test/flutter_test.dart';

void main() {
  group('desktop shell postgres probe parsing', () {
    test('splitProbeOutputLines trims and drops empty lines', () {
      final lines = splitProbeOutputLines(
        '\n postgresql@16 \n\npostgresql\n  \n',
      );
      expect(lines.toList(), ['postgresql@16', 'postgresql']);
    });

    test('isPostgresFormulaLine recognizes postgres formulas', () {
      expect(isPostgresFormulaLine('postgresql'), true);
      expect(isPostgresFormulaLine('postgresql@16'), true);
      expect(isPostgresFormulaLine('postgresql@15'), true);
      expect(isPostgresFormulaLine('postgresqlite'), false);
      expect(isPostgresFormulaLine('postgresql@abc'), true);
    });

    test(
      'isStartedPostgresServiceLine handles service status lines robustly',
      () {
        expect(isStartedPostgresServiceLine('postgresql started'), true);
        expect(isStartedPostgresServiceLine('postgresql@16 started'), true);
        expect(
          isStartedPostgresServiceLine('postgresql@16   started   5432'),
          true,
        );
        expect(isStartedPostgresServiceLine('postgresql@abc started'), false);
        expect(isStartedPostgresServiceLine('foobar started'), false);
        expect(isStartedPostgresServiceLine('postgresql starting'), false);
      },
    );
  });
}

Iterable<String> splitProbeOutputLines(String output) {
  return output
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty);
}

bool isPostgresFormulaLine(String line) {
  return RegExp(r'^postgresql(@.+)?$').hasMatch(line.trim());
}

bool isStartedPostgresServiceLine(String line) {
  final parts = line.trim().split(RegExp(r'\s+'));
  if (parts.length < 2 || parts[1] != 'started') return false;
  return RegExp(r'^postgresql(@\d+)?$').hasMatch(parts.first);
}
