import '../../../core/sidecar/sidecar_api.dart';
import 'direct_upload_models.dart';

/// Thin typed wrapper around [SidecarApi] for the QR upload flow.
///
/// Keeps widgets decoupled from the raw HTTP plumbing so widget tests can
/// inject fakes without touching the real network layer.
class DirectUploadController {
  DirectUploadController({
    required this.api,
    this.serviceUnavailableMessage =
        'QR upload is temporarily unavailable. Please try again later.',
    this.sessionIncompleteMessage =
        'QR upload session could not be created. Check upload settings and try again.',
    this.configIncompleteMessage =
        'QR upload settings are incomplete. Check upload settings and try again.',
  });

  final SidecarApi api;
  final String serviceUnavailableMessage;
  final String sessionIncompleteMessage;
  final String configIncompleteMessage;

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
    required String token,
    List<String>? objectKeys,
  }) async {
    final body = <String, dynamic>{'token': token};
    if (objectKeys != null) {
      body['objectKeys'] = objectKeys;
    }
    final response = await api.post('$_basePath/$sessionId/pullback', body);
    _throwIfSidecarError(response);
    return fetchStatus(sessionId);
  }

  void _throwIfSidecarError(Map<String, dynamic> response) {
    if (response['ok'] == false) {
      final message = response['message'];
      final code = response['code'];
      if (message is String && message.trim().isNotEmpty) {
        throw StateError(_ordinaryErrorMessage(message));
      }
      if (code is String && code.trim().isNotEmpty) {
        throw StateError(_ordinaryErrorMessage(code));
      }
      throw StateError(serviceUnavailableMessage);
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
      throw StateError(sessionIncompleteMessage);
    }
  }

  String _ordinaryErrorMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('supabase') ||
        lower.contains('sidecar') ||
        lower.contains('requestid') ||
        lower.contains('jobid') ||
        lower.contains('anon_key') ||
        lower.contains('service_role')) {
      return configIncompleteMessage;
    }
    return message;
  }
}
