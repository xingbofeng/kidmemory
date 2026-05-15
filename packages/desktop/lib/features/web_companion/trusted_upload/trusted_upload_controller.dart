import '../../../core/sidecar/sidecar_api.dart';
import 'trusted_upload_models.dart';

/// Trusted Upload controller.
///
/// 负责：
/// 1. 创建上传会话
/// 2. 查询会话状态
/// 3. 关闭会话
/// 4. 重试失败项
class TrustedUploadController {
  TrustedUploadController({
    required this.sidecarApi,
    required this.childId,
  });

  final SidecarApi sidecarApi;
  final String childId;

  TrustedUploadSession? _session;
  TrustedUploadSession? get session => _session;

  /// 创建上传会话
  Future<void> createSession() async {
    final response = await sidecarApi.post(
      '/api/web-companion/sessions',
      {
        'childId': childId,
        'expiresInMinutes': 180, // 3 小时
        'maxItems': 200,
        'preferredProviders': ['supabase'],
      },
    );

    _session = TrustedUploadSession.fromJson(response);
  }

  /// 查询会话状态
  Future<TrustedUploadStatus> fetchStatus() async {
    if (_session == null) {
      throw StateError('Session not created');
    }

    final response = await sidecarApi.get(
      '/api/web-companion/sessions/${_session!.sessionId}/detail?token=${Uri.encodeComponent(_session!.token)}',
    );

    return TrustedUploadStatus.fromJson(response);
  }

  /// 关闭会话
  Future<void> closeSession() async {
    if (_session == null) return;

    await sidecarApi.post(
      '/api/web-companion/sessions/${_session!.sessionId}/close',
      {
        'token': _session!.token,
      },
    );
  }

  /// 重试失败项
  Future<void> retryItem(String uploadItemId) async {
    if (_session == null) {
      throw StateError('Session not created');
    }

    await sidecarApi.post(
      '/api/web-companion/sessions/${_session!.sessionId}/items/$uploadItemId/retry',
      {
        'token': _session!.token,
      },
    );
  }
}
