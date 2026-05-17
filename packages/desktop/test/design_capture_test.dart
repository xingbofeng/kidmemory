import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/app/desktop_shell.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';
import 'package:kidmemory_desktop/shared/widgets/chrome.dart';

void main() {
  Future<void> gotoStep(WidgetTester tester, String label) async {
    await tester.tap(
      find
          .byWidgetPredicate(
            (widget) => widget is NavItem && widget.label == label,
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('capture desktop flow smoke check', (tester) async {
    await tester.binding.setSurfaceSize(const Size(4536, 2946));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: DesktopShell(api: _DesignCaptureFakeSidecarApi())),
    );
    await tester.pumpAndSettle();

    await gotoStep(tester, '设置');
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsWidgets);

    await gotoStep(tester, '孩子档案');
    await tester.tap(find.text('查看示例').first);
    await tester.pumpAndSettle();
    expect(find.text('示例数据集'), findsWidgets);

    await gotoStep(tester, '孩子档案');
    await tester.pumpAndSettle();
    expect(find.text('孩子档案'), findsWidgets);

    await gotoStep(tester, '素材库');
    await tester.pumpAndSettle();
    expect(find.text('素材库'), findsWidgets);

    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();
    expect(find.text('创作台'), findsWidgets);
  });
}

class _DesignCaptureFakeSidecarApi extends SidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') return {'ok': true};
    if (path == '/config/ui') {
      return {
        'setup': {
          'checks': [
            {
              'index': '1',
              'title': 'PostgreSQL 配置',
              'body': '等待 sidecar 返回数据库配置',
              'action': '配置',
              'state': '已检测',
              'ok': true,
            },
            {
              'index': '2',
              'title': 'pgvector 检测',
              'body': '等待 PostgreSQL 扩展检测结果',
              'action': '检测 pgvector',
              'state': '已检测',
              'ok': true,
            },
            {
              'index': '3',
              'title': '大模型接口配置',
              'body': '配置 OPENAI_API_KEY 后即可启用 AI 能力',
              'action': '配置',
              'state': '已检测',
              'ok': true,
            },
            {
              'index': '4',
              'title': '本地数据目录',
              'body': '等待本地数据目录配置',
              'action': '配置目录',
              'state': '待检测',
              'ok': false,
            },
          ],
        },
        'searchTypeOptions': [
          {'value': 'all', 'label': '全部'},
          {'value': 'artwork', 'label': '绘画'},
          {'value': 'photo', 'label': '照片'},
          {'value': 'craft', 'label': '手工'},
        ],
        'generationTemplates': ['温暖童趣', '童话式成长记忆', '简约纪实'],
        'generationPageSizes': [
          'A4 竖版  210 × 297 mm',
          'A4 横版  297 × 210 mm',
          'A3 竖版  297 × 420 mm',
        ],
        'generationStyles': [
          '温暖童趣  亲切温暖，适合儿童阅读',
          '童话叙事  文字更具故事感',
          '纪实风  中性偏学术表达',
        ],
        'generationExportTargets': ['PDF 文件  高质量 PDF（打印级别）', 'PDF 文件  轻量浏览版本'],
        'defaultGenerationTemplate': '温暖童趣',
        'defaultGenerationPageSize': 'A4 竖版  210 × 297 mm',
        'defaultGenerationStyle': '温暖童趣  亲切温暖，适合儿童阅读',
        'defaultGenerationExportTarget': 'PDF 文件  高质量 PDF（打印级别）',
      };
    }
    if (path == '/children') {
      return {
        'children': [
          {'id': 'child-1', 'name': '澄澄'},
        ],
      };
    }
    if (path.startsWith('/assets')) {
      return {
        'assets': [
          {
            'id': 'asset-dino-world',
            'title': '恐龙世界',
            'type': 'artwork',
            'description': '描述',
            'tags': ['恐龙'],
            'capturedAt': '2026-05-12',
          },
        ],
      };
    }
    if (path == '/books/sample') {
      return {
        'book': {'id': 'sample-1', 'title': '样例书籍', 'status': 'ready'},
      };
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/config/check/')) return {'ok': true};
    return {'ok': true};
  }
}
