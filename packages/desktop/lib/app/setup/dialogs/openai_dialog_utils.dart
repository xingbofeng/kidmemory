String resolveOpenAiApiKeyForEditor(
  Map<String, dynamic> openai, {
  String cachedApiKey = '',
}) {
  final direct = openai['apiKey'];
  if (direct is String && direct.trim().isNotEmpty) {
    return direct.trim();
  }
  return cachedApiKey.trim();
}
