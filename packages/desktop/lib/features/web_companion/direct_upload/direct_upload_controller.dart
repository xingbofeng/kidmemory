import '../../../core/sidecar/sidecar_api.dart';
import 'direct_upload_models.dart';

/// Thin typed wrapper around [SidecarApi] for the Direct Upload flow.
///
/// Keeps widgets decoupled from the raw HTTP plumbing so widget tests can
/// inject fakes without touching the real network layer.
class DirectUploadController {
  DirectUploadController({required this.api});

  final SidecarApi api;

  static const _basePath = '/api/web-companion/direct-upload/sessions';

  Future<DirectUploadConfig> createSession(String childId) async {
    final response = await api.post(_basePath, {'childId': childId});
    _throwIfSidecarError(response);
    _requireFields(response, const [
      'sessionId',
      'childId',
      'bucket',
      'sessionPath',
      'supabaseUrl',
      'anonKey',
      'publicUrl',
    ]);
    return DirectUploadConfig.fromJson(response);
  }

  Future<DirectUploadStatusSnapshot> fetchStatus(String sessionId) async {
    final response = await api.get('$_basePath/$sessionId/status');
    return DirectUploadStatusSnapshot.fromJson(response);
  }

  Future<DirectUploadStatusSnapshot> triggerPullback(
    String sessionId, {
    List<String>? objectKeys,
  }) async {
    final body = <String, dynamic>{};
    if (objectKeys != null) {
      body['objectKeys'] = objectKeys;
    }
    final response = await api.post('$_basePath/$sessionId/pullback', body);
    _throwIfSidecarError(response);
    return DirectUploadStatusSnapshot.fromJson(response);
  }

  void _throwIfSidecarError(Map<String, dynamic> response) {
    if (response['ok'] == false) {
      final message = response['message'];
      final code = response['code'];
      if (message is String && message.trim().isNotEmpty) {
        throw StateError(message);
      }
      if (code is String && code.trim().isNotEmpty) {
        throw StateError('Sidecar 返回错误：$code');
      }
      throw StateError('Sidecar 返回错误，无法继续 Direct Upload');
    }
  }

  void _requireFields(Map<String, dynamic> response, List<String> keys) {
    final missing = keys
        .where((key) {
          final value = response[key];
          return value == null || (value is String && value.trim().isEmpty);
        })
        .toList(growable: false);
    if (missing.isNotEmpty) {
      throw StateError('Direct Upload 会话响应缺少字段：${missing.join(', ')}');
    }
  }
}
