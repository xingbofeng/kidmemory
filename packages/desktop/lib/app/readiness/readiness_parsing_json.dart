part of '../desktop_shell.dart';

Map<String, dynamic> _jsonMapAt(Map<String, dynamic> source, String key) {
  final value = source[key];
  return value is Map<String, dynamic> ? value : const {};
}

List<dynamic> _jsonListAt(Map<String, dynamic> source, String key) {
  final value = source[key];
  return value is List ? value : const [];
}

String _stringAt(Map<String, dynamic> source, String key) {
  return '${source[key] ?? ''}'.trim();
}
