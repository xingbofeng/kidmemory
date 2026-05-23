import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kidmemory_desktop/app/desktop_shell.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';

import '../../localized_test_app.dart';

void main() {
  testWidgets('child profile shows empty state without fallback data', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(home: DesktopShell(api: _EmptySidecarApi())),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有孩子档案'), findsOneWidget);
    expect(find.text('澄澄'), findsNothing);
    expect(find.text('sample-child-001'), findsNothing);
    expect(find.text('成长统计'), findsNothing);
    expect(find.text('当前档案'), findsNothing);
    expect(find.text('从一份档案开始'), findsOneWidget);
    expect(find.text('查看示例'), findsOneWidget);
    expect(
      tester.getCenter(find.text('从一份档案开始')).dx,
      greaterThan(tester.getCenter(find.text('添加孩子档案')).dx),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('child profile empty state stays usable on shorter windows', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(home: DesktopShell(api: _EmptySidecarApi())),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有孩子档案'), findsOneWidget);
    expect(find.text('添加孩子档案'), findsOneWidget);
    expect(find.text('查看示例'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty child profile opens sample page without importing data', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _EmptySidecarApi();
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看示例'));
    await tester.pumpAndSettle();

    expect(find.text('示例数据集'), findsWidgets);
    expect(find.text('阳光花园'), findsWidgets);
    expect(find.text('导入示例数据集'), findsOneWidget);
    expect(api.importSampleCalls, 0);
  });
}

class _EmptySidecarApi extends SidecarApi {
  int importSampleCalls = 0;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '/tmp/kidmemory-exports'},
      };
    }
    if (path == '/children') {
      return {'children': <Map<String, dynamic>>[]};
    }
    if (path.startsWith('/assets')) {
      return {'assets': <Map<String, dynamic>>[]};
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/sample/import') {
      importSampleCalls += 1;
      return {'ok': true, 'childId': 'sample-child-001', 'assetCount': 0};
    }
    if (path.startsWith('/config/check/') || path == '/schema/init') {
      return {'ok': true};
    }
    return {'ok': true};
  }
}
