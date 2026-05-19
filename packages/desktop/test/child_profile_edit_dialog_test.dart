import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kidmemory_desktop/app/desktop_shell.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';

void main() {
  testWidgets('child profile edit saves name and can clear birthday', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _EditDialogFakeSidecarApi(
      initialChildren: [
        {
          'id': 'child-1',
          'name': '澄澄',
          'birthday': '2020-03-15',
          'notes': '喜欢绘画',
        },
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          api: api,
          localReadinessDetectionEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('编辑').first);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3));
    expect(find.text('清空生日'), findsOneWidget);

    await tester.enterText(fields.at(0), '澄澄-新名字');
    await tester.tap(find.text('清空生日'));
    await tester.pump();

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('澄澄-新名字'), findsWidgets);
    expect(api.lastPatchedBirthday, '');
    expect(api.children.single['birthday'], '');
  });

  testWidgets('sample child keeps explicit name after refresh', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _EditDialogFakeSidecarApi(
      initialChildren: [
        {'id': 'sample-child-001', 'name': '可可', 'birthday': '', 'notes': ''},
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          api: api,
          localReadinessDetectionEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('可可'), findsWidgets);
    expect(find.text('小朋友'), findsNothing);
  });
}

class _EditDialogFakeSidecarApi extends SidecarApi {
  _EditDialogFakeSidecarApi({required List<Map<String, dynamic>> initialChildren})
    : children = initialChildren,
      super(baseUrl: 'http://127.0.0.1:0', retries: 0);

  final List<Map<String, dynamic>> children;
  String? lastPatchedBirthday;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/ui') {
      return {
        'ok': true,
        'data': {},
      };
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
    return {'ok': true, 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/schema/init' ||
        path == '/config/check/postgres' ||
        path == '/config/check/pgvector' ||
        path == '/config/check/openai') {
      return {'ok': true, 'message': 'ok'};
    }
    return {'ok': true, 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/children/')) {
      final id = path.split('/').last;
      final index = children.indexWhere((child) => child['id'] == id);
      if (index >= 0) {
        children[index] = {
          ...children[index],
          if (body.containsKey('name')) 'name': body['name'],
          if (body.containsKey('birthday')) 'birthday': body['birthday'],
          if (body.containsKey('notes')) 'notes': body['notes'],
        };
      }
      lastPatchedBirthday = body['birthday'] as String?;
      return {'child': children[index]};
    }
    return {'ok': true, 'data': {}};
  }
}
