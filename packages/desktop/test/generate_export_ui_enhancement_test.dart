import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/features/generate_export/generate_export_page.dart';

void main() {
  testWidgets('generate export page shows smart actions and request id', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 980));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenerateExportPage(
            selectedCount: 12,
            generated: true,
            generating: false,
            exported: false,
            statusMessage: '正在生成封面图',
            requestId: 'req_24fc',
            logLines: const ['10:21:15  已选择 12 张素材'],
            templateOptions: const ['温暖童趣'],
            pageSizeOptions: const ['A4 竖版  210 × 297 mm'],
            styleOptions: const ['温暖童趣  亲切温暖，适合儿童阅读'],
            exportTargetOptions: const ['PDF 文件  高质量 PDF（打印级别）'],
            selectedTemplate: '温暖童趣',
            selectedPageSize: 'A4 竖版  210 × 297 mm',
            selectedStyle: '温暖童趣  亲切温暖，适合儿童阅读',
            selectedExportTarget: 'PDF 文件  高质量 PDF（打印级别）',
            onGenerate: () {},
            onGenerateSkipCover: () {},
            onExport: () {},
            onExportTargetChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('生成儿童绘本'), findsOneWidget);
    expect(find.text('生成成长纪念册'), findsOneWidget);
    expect(find.text('生成回忆录视频'), findsOneWidget);
    expect(find.text('Request ID: req_24fc'), findsOneWidget);
  });

  testWidgets('picture book action opens free-image confirm dialog', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 980));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenerateExportPage(
            selectedCount: 8,
            generated: false,
            generating: false,
            exported: false,
            statusMessage: '等待生成',
            requestId: '',
            logLines: const [],
            templateOptions: const ['温暖童趣'],
            pageSizeOptions: const ['A4 竖版  210 × 297 mm'],
            styleOptions: const ['温暖童趣  亲切温暖，适合儿童阅读'],
            exportTargetOptions: const ['PDF 文件  高质量 PDF（打印级别）'],
            selectedTemplate: '温暖童趣',
            selectedPageSize: 'A4 竖版  210 × 297 mm',
            selectedStyle: '温暖童趣  亲切温暖，适合儿童阅读',
            selectedExportTarget: 'PDF 文件  高质量 PDF（打印级别）',
            onGenerate: () {},
            onGenerateSkipCover: () {},
            onExport: () {},
            onExportTargetChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('生成儿童绘本'));
    await tester.pumpAndSettle();

    expect(find.text('确认：调用免费生图'), findsOneWidget);
    expect(find.text('继续生成'), findsOneWidget);
    expect(find.text('跳过封面'), findsOneWidget);
  });

  testWidgets('cover failure panel exposes retry/skip/view-log actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 980));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenerateExportPage(
            selectedCount: 8,
            generated: false,
            generating: false,
            exported: false,
            statusMessage: '封面图生成失败：免费生图服务暂时不可用',
            requestId: 'req_cover_failed_1',
            logLines: const [],
            templateOptions: const ['温暖童趣'],
            pageSizeOptions: const ['A4 竖版  210 × 297 mm'],
            styleOptions: const ['温暖童趣  亲切温暖，适合儿童阅读'],
            exportTargetOptions: const ['PDF 文件  高质量 PDF（打印级别）'],
            selectedTemplate: '温暖童趣',
            selectedPageSize: 'A4 竖版  210 × 297 mm',
            selectedStyle: '温暖童趣  亲切温暖，适合儿童阅读',
            selectedExportTarget: 'PDF 文件  高质量 PDF（打印级别）',
            onGenerate: () {},
            onGenerateSkipCover: () {},
            onExport: () {},
            onExportTargetChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('封面图生成失败'), findsWidgets);
    expect(find.text('重试'), findsWidgets);
    expect(find.text('跳过封面继续导出'), findsWidgets);
    expect(find.text('查看日志'), findsWidgets);
    expect(find.text('Request ID: req_cover_failed_1'), findsWidgets);
  });
}
