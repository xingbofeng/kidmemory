import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class SidecarApiException implements Exception {
  const SidecarApiException(
    this.message, {
    this.statusCode,
    this.path,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? path;
  final int? code;

  @override
  String toString() {
    final httpCode = statusCode == null ? '' : ' (HTTP $statusCode)';
    final apiCode = code == null ? '' : ' [API Code: $code]';
    final target = path == null ? '' : ' [$path]';
    return '$message$httpCode$apiCode$target';
  }
}

/// Unified API response format: { code, msg, data }
class ApiEnvelope {
  const ApiEnvelope({
    required this.code,
    required this.msg,
    required this.data,
  });

  final int code;
  final String msg;
  final Object? data;

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) {
    return ApiEnvelope(
      code: json['code'] as int? ?? 0,
      msg: json['msg'] as String? ?? '',
      data: json['data'],
    );
  }

  bool get isSuccess => code == 0;
}

class SidecarApi {
  SidecarApi({
    String? baseUrl,
    // Book generation and export can legitimately take longer than a short
    // interactive request, so keep the default timeout generous enough to avoid
    // false negatives on long-running local jobs.
    this.timeout = const Duration(seconds: 60),
    this.retries = 1,
    this.traceIdProvider,
    this.requestIdProvider,
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
  final String? Function()? traceIdProvider;
  final String? Function()? requestIdProvider;
  String? _activeTraceId;
  String? _activeRequestId;

  static String newTraceId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final entropy = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return 'trace_${now}_$entropy';
  }

  static String newRequestId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final entropy = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return 'req_${now}_$entropy';
  }

  void setRequestContext({String? traceId, String? requestId}) {
    _activeTraceId = _normalizeHeaderValue(traceId);
    _activeRequestId = _normalizeHeaderValue(requestId);
  }

  void clearRequestContext() {
    _activeTraceId = null;
    _activeRequestId = null;
  }

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

  Future<Map<String, dynamic>> patch(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    return _send('PATCH', path, body);
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
    throw SidecarApiException(
      'Sidecar request returned empty payload',
      path: path,
    );
  }

  Future<Map<String, dynamic>> postStrict(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    final response = await post(path, body);
    if (response.isNotEmpty) return response;
    throw SidecarApiException(
      'Sidecar request returned empty payload',
      path: path,
    );
  }

  Future<Map<String, dynamic>> putStrict(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    final response = await put(path, body);
    if (response.isNotEmpty) return response;
    throw SidecarApiException(
      'Sidecar request returned empty payload',
      path: path,
    );
  }

  Future<Map<String, dynamic>> patchStrict(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    final response = await patch(path, body);
    if (response.isNotEmpty) return response;
    throw SidecarApiException(
      'Sidecar request returned empty payload',
      path: path,
    );
  }

  Future<Map<String, dynamic>> deleteStrict(String path) async {
    final response = await delete(path);
    if (response.isNotEmpty) return response;
    throw SidecarApiException(
      'Sidecar request returned empty payload',
      path: path,
    );
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    final context = _resolveRequestContext();
    Object? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final json = await _sendOnce(method, path, body, context);
        return _unwrapApiResponse(json);
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
    debugPrint(
      'Sidecar $method $path failed after ${retries + 1} attempts: $lastError',
    );
    if (lastError is SidecarApiException) {
      throw lastError;
    }
    throw SidecarApiException(
      'Sidecar request failed after ${retries + 1} attempts',
      path: path,
    );
  }

  Future<List<dynamic>> _sendList(String method, String path) async {
    final context = _resolveRequestContext();
    Object? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final json = await _sendOnce(method, path, const {}, context);
        final unwrapped = _unwrapApiResponse(json);
        if (unwrapped is List<dynamic>) return unwrapped;
        return const [];
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
    debugPrint(
      'Sidecar $method $path failed after ${retries + 1} attempts: $lastError',
    );
    if (lastError is SidecarApiException) {
      throw lastError;
    }
    throw SidecarApiException(
      'Sidecar request failed after ${retries + 1} attempts',
      path: path,
    );
  }

  /// Unwraps unified API response format { code, msg, data }
  /// Returns the data field if code == 0, otherwise throws SidecarApiException
  dynamic _unwrapApiResponse(Object? json) {
    if (json is Map<String, dynamic> &&
        json.containsKey('code') &&
        json.containsKey('msg') &&
        json.containsKey('data')) {
      final apiResponse = ApiEnvelope.fromJson(json);

      if (!apiResponse.isSuccess) {
        throw SidecarApiException(apiResponse.msg, code: apiResponse.code);
      }

      final data = apiResponse.data;
      if (data is Map<String, dynamic>) return data;
      if (data is List<dynamic>) return data;
      return data ?? {};
    }

    if (json is Map<String, dynamic>) return json;
    if (json is List<dynamic>) return json;
    return {};
  }

  Future<Object?> _sendOnce(
    String method,
    String path, [
    Map<String, dynamic> body = const {},
    _SidecarRequestContext? context,
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
      final effectiveContext = context ?? _resolveRequestContext();
      request.headers.set('X-KidMemory-Trace-Id', effectiveContext.traceId);
      request.headers.set('X-KidMemory-Request-Id', effectiveContext.requestId);
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
        if (text.isNotEmpty) {
          try {
            final json = jsonDecode(text);
            if (json is Map<String, dynamic> &&
                json.containsKey('code') &&
                json.containsKey('msg')) {
              throw SidecarApiException(
                json['msg'] as String,
                statusCode: response.statusCode,
                path: path,
                code: json['code'] as int?,
              );
            }
          } catch (e) {
            if (e is SidecarApiException) rethrow;
          }
        }

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

  _SidecarRequestContext _resolveRequestContext() {
    final providedTraceId = _normalizeHeaderValue(traceIdProvider?.call());
    final providedRequestId = _normalizeHeaderValue(requestIdProvider?.call());
    return _SidecarRequestContext(
      traceId: _activeTraceId ?? providedTraceId ?? newTraceId(),
      requestId: _activeRequestId ?? providedRequestId ?? newRequestId(),
    );
  }

  String? _normalizeHeaderValue(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}

class _SidecarRequestContext {
  const _SidecarRequestContext({
    required this.traceId,
    required this.requestId,
  });

  final String traceId;
  final String requestId;
}
