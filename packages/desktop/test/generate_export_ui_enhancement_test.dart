import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/features/generate_export/generate_export_page.dart';

import 'localized_test_app.dart';

void main() {
  testWidgets('prepare stage shows five-step flow without generated panels', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 980));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: GenerateExportPage(
            selectedCount: 8,
            generated: false,
            generating: false,
            exported: false,
            creationPhase: CreationWorkflowPhase.preparing,
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
            onConfirmPlan: () {},
            onExport: () {},
            onExportTargetChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('准备创作'), findsOneWidget);
    expect(find.text('计划确认'), findsOneWidget);
    expect(find.text('生成中'), findsOneWidget);
    expect(find.text('结果预览'), findsOneWidget);
    expect(find.text('导出分享'), findsOneWidget);
    expect(find.text('开始规划'), findsOneWidget);
    expect(find.text('Agent 执行计划'), findsNothing);
    expect(find.text('Agent 活动'), findsNothing);
    expect(find.text('页面预览'), findsNothing);
    expect(find.textContaining('生成完成后，可以导出 PDF、长图或创建分享链接'), findsNothing);
  });

  testWidgets('prepare stage disables planning when assets are missing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 980));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var generateCalls = 0;
    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: GenerateExportPage(
            selectedCount: 0,
            generated: false,
            generating: false,
            exported: false,
            creationPhase: CreationWorkflowPhase.preparing,
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
            onGenerate: () {
              generateCalls += 1;
            },
            onConfirmPlan: () {},
            onExport: () {},
            onExportTargetChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('等待选择素材'), findsWidgets);
    expect(find.text('AI 帮我挑素材'), findsWidgets);
    expect(find.text('开始规划'), findsOneWidget);

    await tester.tap(find.text('开始规划'));
    await tester.pumpAndSettle();

    expect(generateCalls, 0);
  });

  testWidgets('generating stage shows backend steps without fake percent', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 980));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: GenerateExportPage(
            selectedCount: 8,
            generated: false,
            generating: true,
            exported: false,
            creationPhase: CreationWorkflowPhase.generating,
            statusMessage: '生成中...',
            requestId: '',
            logLines: const ['15:31:00  正在生成内容'],
            templateOptions: const ['温暖童趣'],
            pageSizeOptions: const ['A4 竖版  210 × 297 mm'],
            styleOptions: const ['温暖童趣  亲切温暖，适合儿童阅读'],
            exportTargetOptions: const ['PDF 文件  高质量 PDF（打印级别）'],
            selectedTemplate: '温暖童趣',
            selectedPageSize: 'A4 竖版  210 × 297 mm',
            selectedStyle: '温暖童趣  亲切温暖，适合儿童阅读',
            selectedExportTarget: 'PDF 文件  高质量 PDF（打印级别）',
            creationJobSteps: const [
              CreationPlanStepVm(
                stepId: 'compose',
                label: 'Compose selected assets',
                status: 'succeeded',
                detail: 'Assets validated',
              ),
              CreationPlanStepVm(
                stepId: 'generate',
                label: 'Generate PDF draft',
                status: 'running',
                detail: 'Running skill workspace',
              ),
              CreationPlanStepVm(
                stepId: 'review',
                label: 'Review generated artifact',
                status: 'pending',
                detail: 'Waiting for generated output',
              ),
            ],
            onGenerate: () {},
            onConfirmPlan: () {},
            onExport: () {},
            onExportTargetChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('生成步骤'), findsOneWidget);
    expect(find.text('Generate PDF draft'), findsOneWidget);
    expect(find.text('Running skill workspace'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('100'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('页面预览'), findsNothing);
  });

  testWidgets('local progress fallback stays aligned to five-step design', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(
        home: const Scaffold(
          body: GenerationFlowProgress(
            selectedCount: 8,
            generated: false,
            generating: true,
            exported: false,
            creationPhase: CreationWorkflowPhase.generating,
            exportLabel: 'PDF',
          ),
        ),
      ),
    );

    expect(find.text('创作进度'), findsOneWidget);
    expect(find.text('准备创作'), findsOneWidget);
    expect(find.text('计划确认'), findsOneWidget);
    expect(find.text('生成中'), findsOneWidget);
    expect(find.text('结果预览'), findsOneWidget);
    expect(find.text('导出分享'), findsOneWidget);
    expect(find.text('保存 / 分享'), findsNothing);
    expect(find.text('导出作品'), findsNothing);
    expect(find.text('渲染预览'), findsNothing);
  });

  testWidgets('generate export page shows smart actions without request id', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 980));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: GenerateExportPage(
            selectedCount: 12,
            generated: true,
            generating: false,
            exported: false,
            creationPhase: CreationWorkflowPhase.reviewing,
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
            onConfirmPlan: () {},
            onExport: () {},
            onExportTargetChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('生成儿童绘本'), findsWidgets);
    expect(find.text('生成成长纪念册'), findsOneWidget);
    expect(find.text('生成回忆录视频'), findsOneWidget);
    expect(find.text('Request ID: req_24fc'), findsNothing);
  });

  testWidgets('ordinary activity timeline hides technical labels', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 980));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: GenerateExportPage(
            selectedCount: 8,
            generated: true,
            generating: false,
            exported: true,
            creationPhase: CreationWorkflowPhase.published,
            statusMessage: '生成失败，请检查 sidecar 日志',
            requestId: 'req_24fc',
            logLines: const [
              '10:20:55  pg_ctl start: Examine the log output.',
              '10:20:56  pg_ctl: could not start server',
              '10:20:57  内置 PostgreSQL 将使用端口 54095',
              '10:21:03  生成完成，已获得 jobId: job_123456',
              '10:21:18  Supabase Storage 同步完成',
              '10:21:20  sidecar 已更新状态',
            ],
            templateOptions: const ['温暖童趣'],
            pageSizeOptions: const ['A4 竖版  210 × 297 mm'],
            styleOptions: const ['温暖童趣  亲切温暖，适合儿童阅读'],
            exportTargetOptions: const ['PDF 文件  高质量 PDF（打印级别）'],
            selectedTemplate: '温暖童趣',
            selectedPageSize: 'A4 竖版  210 × 297 mm',
            selectedStyle: '温暖童趣  亲切温暖，适合儿童阅读',
            selectedExportTarget: 'PDF 文件  高质量 PDF（打印级别）',
            onGenerate: () {},
            onConfirmPlan: () {},
            onExport: () {},
            onExportTargetChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Request ID'), findsNothing);
    expect(find.textContaining('jobId'), findsNothing);
    expect(find.textContaining('Supabase'), findsNothing);
    expect(find.textContaining('sidecar'), findsNothing);
    expect(find.textContaining('pg_ctl'), findsNothing);
    expect(find.textContaining('PostgreSQL'), findsNothing);
    expect(find.textContaining('端口 54095'), findsNothing);
    expect(find.textContaining('云端存储'), findsWidgets);
    expect(find.textContaining('本地服务'), findsWidgets);
    expect(find.textContaining('本地服务准备中'), findsWidgets);
  });

  testWidgets('picture book action starts without free-image confirmation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 980));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var generateCalls = 0;
    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: GenerateExportPage(
            selectedCount: 8,
            generated: false,
            generating: false,
            exported: false,
            creationPhase: CreationWorkflowPhase.preparing,
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
            onGenerate: () {
              generateCalls += 1;
            },
            onConfirmPlan: () {},
            onExport: () {},
            onExportTargetChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('生成儿童绘本').first);
    await tester.pumpAndSettle();

    expect(generateCalls, 1);
    expect(find.text('确认：调用免费生图'), findsNothing);
    expect(find.text('继续生成'), findsNothing);
    expect(find.text('跳过封面'), findsNothing);
  });

  testWidgets(
    'cover failure panel exposes retry and view-log actions without skip cover',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 980));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        localizedTestApp(
          home: Scaffold(
            body: GenerateExportPage(
              selectedCount: 8,
              generated: false,
              generating: false,
              exported: false,
              creationPhase: CreationWorkflowPhase.failed,
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
              onConfirmPlan: () {},
              onExport: () {},
              onExportTargetChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('封面图生成失败'), findsWidgets);
      expect(find.text('重试'), findsWidgets);
      expect(find.text('跳过封面继续导出'), findsNothing);
      expect(find.text('跳过封面'), findsNothing);
      expect(find.text('查看日志'), findsWidgets);
      expect(find.text('Request ID: req_cover_failed_1'), findsNothing);
    },
  );
}
