import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';
import 'package:kidmemory_desktop/features/web_companion/direct_upload/direct_upload_controller.dart';

class _FakeSidecarApi extends SidecarApi {
  _FakeSidecarApi({this.postResponse = const <String, dynamic>{}})
    : super(baseUrl: 'http://127.0.0.1:0');

  final Map<String, dynamic> postResponse;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    return postResponse;
  }
}

void main() {
  test('createSession rejects sidecar error envelopes', () async {
    final controller = DirectUploadController(
      api: _FakeSidecarApi(
        postResponse: const {
          'ok': false,
          'code': 'web_companion_direct_upload_config_missing',
          'message': '缺少 SUPABASE_ANON_KEY',
        },
      ),
    );

    expect(
      () => controller.createSession('child-1'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('SUPABASE_ANON_KEY'),
        ),
      ),
    );
  });

  test('createSession rejects incomplete success-like payloads', () async {
    final controller = DirectUploadController(
      api: _FakeSidecarApi(
        postResponse: const {'sessionId': 'session-1', 'childId': 'child-1'},
      ),
    );

    expect(
      () => controller.createSession('child-1'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('publicUrl'),
        ),
      ),
    );
  });
}
