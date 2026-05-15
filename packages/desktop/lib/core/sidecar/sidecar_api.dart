import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class SidecarApiException implements Exception {
  const SidecarApiException(this.message, {this.statusCode, this.path});

  final String message;
  final int? statusCode;
  final String? path;

  @override
  String toString() {
    final code = statusCode == null ? '' : ' (HTTP $statusCode)';
    final target = path == null ? '' : ' [$path]';
    return '$message$code$target';
  }
}

class SidecarApi {
  SidecarApi({
    String? baseUrl,
    this.timeout = const Duration(seconds: 8),
    this.retries = 1,
  }) : baseUrl = baseUrl ?? resolveBaseUrl(Platform.environment);

  /// Resolves the base URL the desktop client should use to reach the local
  /// sidecar. The desktop shell starts the sidecar with `KIDMEMORY_SIDECAR_HOST`
  /// and `KIDMEMORY_SIDECAR_PORT`, and tests can pass an explicit map to
  /// exercise the resolution rules without touching the real environment.
  static String resolveBaseUrl(Map<String, String> environment) {
    final explicitBaseUrl = environment['KIDMEMORY_SIDECAR_BASE_URL']?.trim();
    if (explicitBaseUrl != null && explicitBaseUrl.isNotEmpty) {
      return explicitBaseUrl;
    }
    final host = environment['KIDMEMORY_SIDECAR_HOST']?.trim();
    final portRaw = environment['KIDMEMORY_SIDECAR_PORT']?.trim();
    final resolvedHost = (host == null || host.isEmpty) ? '127.0.0.1' : host;
    final parsedPort = portRaw == null || portRaw.isEmpty
        ? null
        : int.tryParse(portRaw);
    final resolvedPort = parsedPort ?? 4317;
    return 'http://$resolvedHost:$resolvedPort';
  }

  final String baseUrl;
  final Duration timeout;
  final int retries;

  Future<Map<String, dynamic>> get(String path) async {
    return _send('GET', path);
  }

  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    return _send('POST', path, body);
  }

  Future<Map<String, dynamic>> put(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    return _send('PUT', path, body);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _send('DELETE', path);
  }

  Future<List<dynamic>> getList(String path) async {
    return _sendList('GET', path);
  }

  Future<Map<String, dynamic>> getStrict(String path) async {
    final response = await get(path);
    if (response.isNotEmpty) return response;
    throw SidecarApiException('Sidecar request returned empty payload', path: path);
  }

  Future<Map<String, dynamic>> postStrict(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    final response = await post(path, body);
    if (response.isNotEmpty) return response;
    throw SidecarApiException('Sidecar request returned empty payload', path: path);
  }

  Future<Map<String, dynamic>> putStrict(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    final response = await put(path, body);
    if (response.isNotEmpty) return response;
    throw SidecarApiException('Sidecar request returned empty payload', path: path);
  }

  Future<Map<String, dynamic>> deleteStrict(String path) async {
    final response = await delete(path);
    if (response.isNotEmpty) return response;
    throw SidecarApiException('Sidecar request returned empty payload', path: path);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    Object? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final json = await _sendOnce(method, path, body);
        return json is Map<String, dynamic> ? json : {};
      } catch (error) {
        lastError = error;
        if (attempt < retries) {
          debugPrint('Sidecar $method $path failed, retrying: $error');
          await Future<void>.delayed(
            Duration(milliseconds: 120 * (attempt + 1)),
          );
        }
      }
    }
    debugPrint('Sidecar $method $path failed: $lastError');
    return {};
  }

  Future<List<dynamic>> _sendList(String method, String path) async {
    Object? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final json = await _sendOnce(method, path);
        return json is List<dynamic> ? json : const [];
      } catch (error) {
        lastError = error;
        if (attempt < retries) {
          debugPrint('Sidecar $method $path failed, retrying: $error');
          await Future<void>.delayed(
            Duration(milliseconds: 120 * (attempt + 1)),
          );
        }
      }
    }
    debugPrint('Sidecar $method $path failed: $lastError');
    return const [];
  }

  Future<Object?> _sendOnce(
    String method,
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    final client = HttpClient();
    client.connectionTimeout = timeout;
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = switch (method) {
        'POST' => await client.postUrl(uri).timeout(timeout),
        'PUT' => await client.putUrl(uri).timeout(timeout),
        'DELETE' => await client.deleteUrl(uri).timeout(timeout),
        _ => await client.getUrl(uri).timeout(timeout),
      };
      if (method == 'POST' || method == 'PUT') {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      final response = await request.close().timeout(timeout);
      final text = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);
      if (response.statusCode >= 400) {
        throw SidecarApiException(
          text.isEmpty
              ? 'Sidecar request failed'
              : 'Sidecar request failed: $text',
          statusCode: response.statusCode,
          path: path,
        );
      }
      return text.isEmpty ? {} : jsonDecode(text);
    } finally {
      client.close(force: true);
    }
  }

}
