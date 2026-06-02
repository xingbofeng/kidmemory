import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/app/desktop_shell.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';
import 'package:kidmemory_desktop/shared/widgets/chrome.dart';
import 'package:kidmemory_desktop/shared/widgets/layout.dart';

import '../../localized_test_app.dart';

void main() {
  testWidgets(
    'OpenAI setup dialog opens when no default agent config exists',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        localizedTestApp(home: DesktopShell(api: _MissingAgentConfigApi())),
      );
      await tester.pumpAndSettle();
      await _gotoStep(tester, '设置');

      final configureButton = find
          .byWidgetPredicate(
            (widget) => widget is SecondaryButton && widget.label == '修改配置',
          )
          .first;
      await tester.ensureVisible(configureButton);
      await tester.tap(configureButton);
      await tester.pumpAndSettle();

      expect(find.text('配置大模型接口'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    },
  );
}

Future<void> _gotoStep(WidgetTester tester, String label) async {
  await tester.tap(
    find
        .byWidgetPredicate(
          (widget) => widget is NavItem && widget.label == label,
        )
        .first,
  );
  await tester.pumpAndSettle();
}

class _MissingAgentConfigApi extends SidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/ui') {
      return {
        'generate': {
          'templates': ['温暖童趣'],
          'pageSizes': ['A4 竖版  210 × 297 mm'],
          'styles': ['温暖童趣  亲切温暖，适合儿童阅读'],
          'exportTargets': ['PDF 文件  高质量 PDF（打印级别）'],
          'defaults': {
            'template': '温暖童趣',
            'pageSize': 'A4 竖版  210 × 297 mm',
            'style': '温暖童趣  亲切温暖，适合儿童阅读',
            'exportTarget': 'PDF 文件  高质量 PDF（打印级别）',
          },
        },
      };
    }
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '/tmp/kidmemory-exports'},
      };
    }
    if (path == '/api/config/agent-configs/default') {
      throw const SidecarApiException(
        'Default agent config not found',
        statusCode: 404,
        path: '/api/config/agent-configs/default',
      );
    }
    if (path == '/children') {
      return {
        'children': [
          {'id': 'child-1', 'name': '澄澄'},
        ],
      };
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
    if (path.startsWith('/config/check/')) {
      return {'ok': true};
    }
    return {'ok': true};
  }
}
