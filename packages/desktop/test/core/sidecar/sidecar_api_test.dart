import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/core/sidecar/agent_config_api.dart';
import 'package:kidmemory_desktop/core/sidecar/desktop_sidecar_gateway.dart';
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

  test('AgentConfigApi saves and tests persisted agent configs', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final seen = <String>[];
    addTearDown(() async => server.close(force: true));

    server.listen((request) async {
      final path = request.uri.path;
      seen.add('${request.method} $path');
      final bodyText = await utf8.decoder.bind(request).join();
      final body = bodyText.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(bodyText) as Map<String, dynamic>;

      Object data;
      if (request.method == 'POST' && path == '/api/config/agent-configs') {
        data = {
          'id': 'config_desktop_1',
          'name': body['name'],
          'description': body['description'],
          'provider': body['provider'],
          'model': body['model'],
          'baseUrl': body['baseUrl'],
          'apiKeyConfigured': true,
          'temperature': body['temperature'],
          'maxTokens': body['maxTokens'],
          'toolsEnabled': const <String>[],
          'workspaceConfig': const <String, dynamic>{},
          'isDefault': body['isDefault'],
          'isActive': true,
          'createdAt': '2026-05-20T00:00:00.000Z',
          'updatedAt': '2026-05-20T00:00:00.000Z',
        };
      } else if (request.method == 'POST' &&
          path == '/api/config/agent-configs/config_desktop_1/set-default') {
        data = {'success': true};
      } else if (request.method == 'POST' &&
          path == '/api/config/agent-configs/config_desktop_1/test') {
        data = {
          'success': true,
          'responseTime': 120,
          'modelUsed': 'mimo-v2-pro',
          'tokensUsed': 12,
        };
      } else {
        request.response.statusCode = 404;
        data = {'path': path};
      }

      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'code': 0, 'msg': 'ok', 'data': data}));
      await request.response.close();
    });

    final api = AgentConfigApi(
      SidecarApi(
        baseUrl: 'http://${server.address.host}:${server.port}',
        retries: 0,
      ),
    );

    final config = await api.createAgentConfig(
      CreateAgentConfigInput(
        name: 'Xiaomi MiMo',
        provider: 'custom',
        model: 'mimo-v2-pro',
        baseUrl: 'https://api.xiaomimimo.com/v1',
        apiKey: 'sk-test',
        temperature: 0,
        maxTokens: 4000,
        isDefault: true,
      ),
    );
    final defaultSet = await api.setDefaultAgentConfig(config.id);
    final testResult = await api.testAgentConfigById(config.id);

    expect(defaultSet, isTrue);
    expect(testResult.success, isTrue);
    expect(testResult.modelUsed, 'mimo-v2-pro');
    expect(seen, [
      'POST /api/config/agent-configs',
      'POST /api/config/agent-configs/config_desktop_1/set-default',
      'POST /api/config/agent-configs/config_desktop_1/test',
    ]);
  });

  test('AgentConfigApi treats missing default agent config as empty', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close(force: true));

    server.listen((request) async {
      request.response
        ..statusCode = 404
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'code': 404,
            'msg': 'Default agent config not found',
            'data': null,
          }),
        );
      await request.response.close();
    });

    final api = AgentConfigApi(
      SidecarApi(
        baseUrl: 'http://${server.address.host}:${server.port}',
        retries: 0,
      ),
    );

    expect(await api.getDefaultAgentConfig(), isNull);
  });

  test('DesktopSidecarGateway calls task-first creation routes', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final seen = <String>[];
    var taskBody = <String, dynamic>{};
    addTearDown(() async => server.close(force: true));

    server.listen((request) async {
      final path = request.uri.path;
      seen.add('${request.method} $path');
      final bodyText = await utf8.decoder.bind(request).join();
      final body = bodyText.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(bodyText) as Map<String, dynamic>;
      Object data;
      if (path == '/creation/tasks') {
        taskBody = body;
        data = {
          'taskId': 'task_desktop_1',
          'creationType': body['creationType'],
          'goal': body['goal'],
          'assetIds': body['assetIds'],
          'status': 'ready',
          'currentStepId': 'plan',
          'summary': 'Backend plan summary',
          'skillName': 'KidMemory storybook',
          'steps': const <Map<String, dynamic>>[],
          'requirements': const <String>[],
          'requirementItems': const <String>[],
          'artifacts': const <Map<String, dynamic>>[],
          'error': null,
          'workspacePath': '/tmp/kidmemory/task_desktop_1',
          'createdAt': '2026-05-23T00:00:00.000Z',
          'updatedAt': '2026-05-23T00:00:00.000Z',
        };
      } else if (path == '/creation/tasks/task_desktop_1/generate') {
        data = {
          'taskId': 'task_desktop_1',
          'creationType': 'storybook',
          'goal': 'Make a bedtime story',
          'assetIds': const ['asset_a', 'asset_b'],
          'status': 'succeeded',
          'currentStepId': 'review',
          'summary': 'Backend plan summary',
          'skillName': 'KidMemory storybook',
          'steps': const <Map<String, dynamic>>[],
          'requirements': const <String>[],
          'requirementItems': const <String>[],
          'artifacts': const <Map<String, dynamic>>[],
          'error': null,
          'workspacePath': '/tmp/kidmemory/task_desktop_1',
          'createdAt': '2026-05-23T00:00:00.000Z',
          'updatedAt': '2026-05-23T00:00:00.000Z',
        };
      } else if (path == '/creation/tasks/task_desktop_1/events') {
        data = {'events': const <Map<String, dynamic>>[]};
      } else if (path == '/creation/tasks/task_desktop_1/export') {
        data = {
          'artifactId': 'artifact_desktop_pdf',
          'kind': body['target'],
          'taskId': 'task_desktop_1',
          'localPath': body['targetPath'],
          'createdAt': '2026-05-23T00:00:00.000Z',
        };
      } else if (path == '/creation/tasks/task_desktop_1/share') {
        data = {
          'artifactId': body['artifactId'],
          'taskId': 'task_desktop_1',
          'kind': 'web_share',
          'shareId': 'share_desktop_1',
          'shareUrl': 'http://localhost:3001/share/share_desktop_1',
          'createdAt': '2026-05-23T00:00:00.000Z',
        };
      } else if (path == '/creation/tasks/task_desktop_1') {
        data = {
          'taskId': 'task_desktop_1',
          'creationType': 'storybook',
          'goal': 'Make a bedtime story',
          'assetIds': const ['asset_a', 'asset_b'],
          'status': 'succeeded',
          'currentStepId': 'plan',
          'summary': 'Backend plan summary',
          'skillName': 'KidMemory storybook',
          'steps': const <Map<String, dynamic>>[],
          'requirements': const <String>[],
          'requirementItems': const <String>[],
          'artifacts': const <Map<String, dynamic>>[],
          'error': null,
          'workspacePath': '/tmp/kidmemory/task_desktop_1',
          'createdAt': '2026-05-23T00:00:00.000Z',
          'updatedAt': '2026-05-23T00:00:00.000Z',
        };
      } else {
        request.response.statusCode = 404;
        data = {'path': path};
      }
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'code': 0, 'msg': 'ok', 'data': data}));
      await request.response.close();
    });

    final gateway = DesktopSidecarGateway(
      SidecarApi(
        baseUrl: 'http://${server.address.host}:${server.port}',
        retries: 0,
      ),
    );

    final task = await gateway.createCreationTaskRaw(
      goal: 'Make a bedtime story',
      creationType: 'storybook',
      assetIds: const ['asset_a', 'asset_b'],
      settings: const {'tone': 'warm'},
    );
    final generated = await gateway.generateCreationTaskRaw(
      taskId: task['taskId'] as String,
    );
    final detail = await gateway.getCreationTaskRaw(
      taskId: task['taskId'] as String,
    );
    final events = await gateway.getCreationTaskEventsRaw(
      taskId: task['taskId'] as String,
    );
    final exported = await gateway.exportCreationTaskRaw(
      taskId: task['taskId'] as String,
      target: 'pdf',
      targetPath: '/tmp/kidmemory.pdf',
    );
    final shared = await gateway.shareCreationTaskRaw(
      taskId: task['taskId'] as String,
      artifactId: exported['artifactId'] as String,
    );

    expect(task['taskId'], 'task_desktop_1');
    expect(taskBody['assetIds'], ['asset_a', 'asset_b']);
    expect(taskBody['settings'], {'tone': 'warm'});
    expect(generated['status'], 'succeeded');
    expect(detail['taskId'], 'task_desktop_1');
    expect(events['events'], isA<List<dynamic>>());
    expect(exported['kind'], 'pdf');
    expect(shared['shareUrl'], contains('/share/share_desktop_1'));
    expect(seen, [
      'POST /creation/tasks',
      'POST /creation/tasks/task_desktop_1/generate',
      'GET /creation/tasks/task_desktop_1',
      'GET /creation/tasks/task_desktop_1/events',
      'POST /creation/tasks/task_desktop_1/export',
      'POST /creation/tasks/task_desktop_1/share',
    ]);
  });
}
