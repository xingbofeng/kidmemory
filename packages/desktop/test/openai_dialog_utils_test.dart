import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/app/setup/dialogs/openai_dialog_utils.dart';

void main() {
  test('prefers explicit apiKey from config status', () {
    final value = resolveOpenAiApiKeyForEditor(
      {'apiKey': 'sk-live-123', 'apiKeyConfigured': true},
      cachedApiKey: 'sk-cache-999',
    );
    expect(value, 'sk-live-123');
  });

  test('falls back to cached key when config status omits apiKey', () {
    final value = resolveOpenAiApiKeyForEditor(
      {'apiKeyConfigured': true},
      cachedApiKey: 'sk-cache-999',
    );
    expect(value, 'sk-cache-999');
  });
}
