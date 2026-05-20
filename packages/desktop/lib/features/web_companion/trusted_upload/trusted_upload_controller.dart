import '../../../core/sidecar/sidecar_api.dart';
import 'trusted_upload_models.dart';

/// Trusted Upload controller.
///
/// Creates sessions, polls status, closes sessions, and retries failed items.
class TrustedUploadController {
  TrustedUploadController({required this.sidecarApi, required this.childId});

  final SidecarApi sidecarApi;
  final String childId;

  TrustedUploadSession? _session;
  TrustedUploadSession? get session => _session;

  /// Creates an upload session.
  Future<void> createSession() async {
    final response = await sidecarApi.post('/api/web-companion/sessions', {
      'childId': childId,
      'expiresInMinutes': 180,
      'maxItems': 200,
      'preferredProviders': ['supabase'],
    });

    _session = TrustedUploadSession.fromJson(response);
  }

  /// Fetches session status.
  Future<TrustedUploadStatus> fetchStatus() async {
    if (_session == null) {
      throw StateError('Session not created');
    }

    final response = await sidecarApi.get(
      '/api/web-companion/sessions/${_session!.sessionId}/detail?token=${Uri.encodeComponent(_session!.token)}',
    );

    return TrustedUploadStatus.fromJson(response);
  }

  /// Closes the session.
  Future<void> closeSession() async {
    if (_session == null) return;

    await sidecarApi.post(
      '/api/web-companion/sessions/${_session!.sessionId}/close',
      {'token': _session!.token},
    );
  }

  /// Retries a failed upload item.
  Future<void> retryItem(String uploadItemId) async {
    if (_session == null) {
      throw StateError('Session not created');
    }

    await sidecarApi.post(
      '/api/web-companion/sessions/${_session!.sessionId}/items/$uploadItemId/retry',
      {'token': _session!.token},
    );
  }
}
