import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  test('SidecarApi logs and throws request failures', () async {
    final messages = <String>[];
    final previousDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = previousDebugPrint);

    final api = SidecarApi(
      baseUrl: 'http://127.0.0.1:9',
      timeout: const Duration(milliseconds: 100),
    );
    await expectLater(
      api.get('/config/status'),
      throwsA(isA<SidecarApiException>()),
    );
    expect(
      messages.any(
        (message) => message.contains(
          'Sidecar GET /config/status failed after 2 attempts',
        ),
      ),
      isTrue,
    );
  });

  group('SidecarApi.resolveBaseUrl', () {
    test('uses KIDMEMORY_SIDECAR_HOST and PORT when both are present', () {
      final baseUrl = SidecarApi.resolveBaseUrl(const {
        'KIDMEMORY_SIDECAR_HOST': '192.168.1.42',
        'KIDMEMORY_SIDECAR_PORT': '5050',
      });
      expect(baseUrl, 'http://192.168.1.42:5050');
    });

    test('respects KIDMEMORY_SIDECAR_BASE_URL when provided', () {
      final baseUrl = SidecarApi.resolveBaseUrl(const {
        'KIDMEMORY_SIDECAR_BASE_URL': 'https://sidecar.example.test',
        'KIDMEMORY_SIDECAR_HOST': 'should-be-ignored',
      });
      expect(baseUrl, 'https://sidecar.example.test');
    });

    test('falls back to 127.0.0.1:4317 when no env hint is provided', () {
      final baseUrl = SidecarApi.resolveBaseUrl(const {});
      expect(baseUrl, 'http://127.0.0.1:4317');
    });

    test('falls back to default port when only the host is configured', () {
      final baseUrl = SidecarApi.resolveBaseUrl(const {
        'KIDMEMORY_SIDECAR_HOST': '127.0.0.1',
      });
      expect(baseUrl, 'http://127.0.0.1:4317');
    });

    test('ignores non-numeric ports', () {
      final baseUrl = SidecarApi.resolveBaseUrl(const {
        'KIDMEMORY_SIDECAR_HOST': '127.0.0.1',
        'KIDMEMORY_SIDECAR_PORT': 'not-a-number',
      });
      expect(baseUrl, 'http://127.0.0.1:4317');
    });
  });

  test(
    'SidecarApi attaches X-KidMemory-Trace-Id header when trace context exists',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async => server.close(force: true));

      String? receivedTraceHeader;
      server.listen((request) async {
        receivedTraceHeader = request.headers.value('x-kidmemory-trace-id');
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'code': 0,
              'msg': 'ok',
              'data': {'ok': true},
            }),
          );
        await request.response.close();
      });

      final api = SidecarApi(
        baseUrl: 'http://${server.address.host}:${server.port}',
        retries: 0,
      );
      api.setRequestContext(
        traceId: 'trc_desktop_trace_header',
        requestId: 'req_desktop_request_header',
      );

      final response = await api.get('/health');
      expect(response['ok'], isTrue);
      expect(receivedTraceHeader, 'trc_desktop_trace_header');
    },
  );
}
