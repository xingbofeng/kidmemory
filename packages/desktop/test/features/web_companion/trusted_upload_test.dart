import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';
import 'package:kidmemory_desktop/features/web_companion/trusted_upload/trusted_upload_entry.dart';
import 'package:kidmemory_desktop/features/web_companion/trusted_upload/trusted_upload_controller.dart';

void main() {
  group('TrustedUploadEntryButton', () {
    testWidgets('should display upload label', (tester) async {
      final mockApi = MockSidecarApi();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrustedUploadEntryButton(
              sidecarApi: mockApi,
              childId: 'child_123',
            ),
          ),
        ),
      );

      expect(find.text('扫码上传'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    });

    testWidgets('should be tappable', (tester) async {
      final mockApi = MockSidecarApi();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrustedUploadEntryButton(
              sidecarApi: mockApi,
              childId: 'child_123',
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);

      // 验证按钮可点击
      await tester.tap(button);
      await tester.pump();
    });
  });

  group('TrustedUploadController', () {
    test('should create session with correct parameters', () async {
      final mockApi = MockSidecarApi();
      mockApi.mockPost('/api/web-companion/sessions', {
        'sessionId': 'session_123',
        'token': 'token_123',
        'webUrl':
            'https://example.com/upload?sessionId=session_123&token=token_123',
        'expiresAt': DateTime.now()
            .add(const Duration(hours: 3))
            .toIso8601String(),
        'maxItems': 200,
      });

      final controller = TrustedUploadController(
        sidecarApi: mockApi,
        childId: 'child_123',
      );

      await controller.createSession();

      expect(controller.session, isNotNull);
      expect(controller.session!.sessionId, 'session_123');
      expect(controller.session!.maxItems, 200);
    });

    test('should fetch status', () async {
      final mockApi = MockSidecarApi();
      mockApi.mockPost('/api/web-companion/sessions', {
        'sessionId': 'session_123',
        'token': 'token_123',
        'webUrl': 'https://example.com/upload',
        'expiresAt': DateTime.now()
            .add(const Duration(hours: 3))
            .toIso8601String(),
        'maxItems': 200,
      });

      mockApi.mockGet(
        '/api/web-companion/sessions/session_123/detail?token=token_123',
        {'sessionId': 'session_123', 'items': []},
      );

      final controller = TrustedUploadController(
        sidecarApi: mockApi,
        childId: 'child_123',
      );

      await controller.createSession();
      final status = await controller.fetchStatus();

      expect(status.sessionId, 'session_123');
      expect(status.items, isEmpty);
    });

    test('should close session', () async {
      final mockApi = MockSidecarApi();
      mockApi.mockPost('/api/web-companion/sessions', {
        'sessionId': 'session_123',
        'token': 'token_123',
        'webUrl': 'https://example.com/upload',
        'expiresAt': DateTime.now()
            .add(const Duration(hours: 3))
            .toIso8601String(),
        'maxItems': 200,
      });

      mockApi.mockPost('/api/web-companion/sessions/session_123/close', {});

      final controller = TrustedUploadController(
        sidecarApi: mockApi,
        childId: 'child_123',
      );

      await controller.createSession();
      await controller.closeSession();

      // 验证 close 请求被调用
      expect(mockApi.postCalls.length, 2);
    });

    test('should retry failed item', () async {
      final mockApi = MockSidecarApi();
      mockApi.mockPost('/api/web-companion/sessions', {
        'sessionId': 'session_123',
        'token': 'token_123',
        'webUrl': 'https://example.com/upload',
        'expiresAt': DateTime.now()
            .add(const Duration(hours: 3))
            .toIso8601String(),
        'maxItems': 200,
      });

      mockApi.mockPost(
        '/api/web-companion/sessions/session_123/items/item_123/retry',
        {'uploadItemId': 'item_123', 'status': 'pending'},
      );

      final controller = TrustedUploadController(
        sidecarApi: mockApi,
        childId: 'child_123',
      );

      await controller.createSession();
      await controller.retryItem('item_123');

      // 验证 retry 请求被调用
      expect(mockApi.postCalls.length, 2);
    });
  });
}

/// Mock SidecarApi for testing
class MockSidecarApi implements SidecarApi {
  final Map<String, dynamic> _mockResponses = {};
  final List<String> postCalls = [];
  final List<String> getCalls = [];

  @override
  final String baseUrl = 'http://localhost:4317';

  @override
  final Duration timeout = const Duration(seconds: 30);

  @override
  final int retries = 3;

  void mockPost(String path, Map<String, dynamic> response) {
    _mockResponses['POST:$path'] = response;
  }

  void mockGet(String path, Map<String, dynamic> response) {
    _mockResponses['GET:$path'] = response;
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    postCalls.add(path);
    final key = 'POST:$path';
    if (_mockResponses.containsKey(key)) {
      return _mockResponses[key] as Map<String, dynamic>;
    }
    throw Exception('No mock response for POST $path');
  }

  @override
  Future<Map<String, dynamic>> get(String path) async {
    getCalls.add(path);
    final key = 'GET:$path';
    if (_mockResponses.containsKey(key)) {
      return _mockResponses[key] as Map<String, dynamic>;
    }
    throw Exception('No mock response for GET $path');
  }

  @override
  Future<List<dynamic>> getList(String path) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> put(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> delete(String path) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getStrict(String path) => get(path);

  @override
  Future<Map<String, dynamic>> postStrict(
    String path, [
    Map<String, dynamic> body = const {},
  ]) => post(path, body);

  @override
  Future<Map<String, dynamic>> putStrict(
    String path, [
    Map<String, dynamic> body = const {},
  ]) => put(path, body);

  @override
  Future<Map<String, dynamic>> deleteStrict(String path) => delete(path);
}
