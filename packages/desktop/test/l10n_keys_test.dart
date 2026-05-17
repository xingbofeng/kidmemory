import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readArb(String path) {
  final content = File(path).readAsStringSync();
  return jsonDecode(content) as Map<String, dynamic>;
}

Set<String> _messageKeys(Map<String, dynamic> arb) {
  return arb.keys.where((key) => !key.startsWith('@')).toSet();
}

void main() {
  test('zh and en ARB files keep identical message keys', () {
    final zhArb = _readArb('lib/l10n/app_zh.arb');
    final enArb = _readArb('lib/l10n/app_en.arb');

    final zhKeys = _messageKeys(zhArb);
    final enKeys = _messageKeys(enArb);

    expect(zhKeys, equals(enKeys));
  });
}
