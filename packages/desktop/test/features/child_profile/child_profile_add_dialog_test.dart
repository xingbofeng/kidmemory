import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kidmemory_desktop/app/desktop_shell.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';

import '../../localized_test_app.dart';

void main() {
  testWidgets('child profile add dialog accepts text input', (
    WidgetTester tester,
  ) async {
    final today = DateTime.now();
    final dayLabel = '${today.day}';
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _DialogInputFakeSidecarApi();
    await tester.pumpWidget(
      localizedTestApp(
        home: DesktopShell(api: api, localReadinessDetectionEnabled: false),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('添加孩子档案'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3));

    await tester.enterText(fields.at(0), '澄澄');
    await tester.tap(fields.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text(dayLabel).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(2), '喜欢绘画');
    await tester.pump();

    await tester.ensureVisible(find.text('添加').last);
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();

    expect(find.text('澄澄'), findsWidgets);
    expect(api.children.single['name'], '澄澄');
    expect(api.children.single['birthday'], isNotEmpty);
    expect(api.children.single['notes'], '喜欢绘画');
  });
}

class _DialogInputFakeSidecarApi extends SidecarApi {
  _DialogInputFakeSidecarApi()
    : super(baseUrl: 'http://127.0.0.1:0', retries: 0);

  final List<Map<String, dynamic>> children = [];

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/ui') {
      return {'ok': true, 'data': {}};
    }
    if (path == '/config/status') {
      return {
        'postgres': {
          'host': 'localhost',
          'port': 5432,
          'database': 'kidmemory',
          'user': 'postgres',
        },
        'openai': {
          'baseUrl': 'http://localhost:3000',
          'model': 'gpt-4o-mini',
          'apiKeyConfigured': true,
        },
        'paths': {'exportDir': '/tmp/kidmemory-exports'},
      };
    }
    if (path == '/children') {
      return {'children': children};
    }
    if (path.startsWith('/assets')) {
      return {'assets': <Map<String, dynamic>>[]};
    }
    if (path == '/api/config/agent-configs/default') {
      return {};
    }
    return {'ok': true, 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/schema/init' ||
        path == '/config/check/postgres' ||
        path == '/config/check/pgvector') {
      return {'ok': true, 'message': 'ok'};
    }
    if (path == '/children') {
      final child = <String, dynamic>{
        'id': body['id'] as String? ?? 'child-${children.length + 1}',
        'name': body['name'] as String? ?? '',
        if ((body['birthday'] as String? ?? '').isNotEmpty)
          'birthday': body['birthday'],
        if ((body['notes'] as String? ?? '').isNotEmpty) 'notes': body['notes'],
      };
      children.add(child);
      return {'child': child};
    }
    return {'ok': true, 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    return {'ok': true, 'data': {}};
  }
}
