import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/app/desktop_shell.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';
import 'package:kidmemory_desktop/features/generate_export/generate_export_page.dart';
import 'package:kidmemory_desktop/shared/widgets/chrome.dart';

import 'localized_test_app.dart';

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

  Future<void> pumpCreationPage(
    WidgetTester tester, {
    required Size size,
  }) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      localizedTestApp(home: Scaffold(body: _issue2CreationPage())),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 250));
  }

  Future<void> captureEvidence(
    WidgetTester tester, {
    required String fileName,
  }) async {
    await expectLater(
      find.byType(GenerateExportPage),
      matchesGoldenFile('goldens/issue2-$fileName'),
    );
    final source = File('test/goldens/issue2-$fileName');
    if (source.existsSync()) {
      final target = File('../../docs/issue-2/desktop-states/$fileName');
      target.parent.createSync(recursive: true);
      source.copySync(target.path);
    }
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

  testWidgets('capture issue 2 responsive creation page evidence', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const widthCases = <({String fileName, Size size})>[
      (fileName: 'layout-1280.png', size: Size(1280, 900)),
      (fileName: 'layout-1440.png', size: Size(1440, 900)),
      (fileName: 'layout-1728.png', size: Size(1728, 900)),
    ];

    for (final widthCase in widthCases) {
      await pumpCreationPage(tester, size: widthCase.size);

      expect(find.text('创作台'), findsWidgets);
      expect(tester.takeException(), isNull);

      await captureEvidence(tester, fileName: widthCase.fileName);
    }

    await pumpCreationPage(tester, size: const Size(1280, 640));

    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -360));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('创作台'), findsWidgets);
    expect(tester.takeException(), isNull);

    await captureEvidence(tester, fileName: 'layout-low-height-scroll.png');
  });

  testWidgets('capture issue 2 eleven creation state evidence', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final stateCase in _issue2StateCases) {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        localizedTestApp(home: Scaffold(body: _issue2CreationPage(stateCase))),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('创作台'), findsWidgets);
      expect(find.text('创作流程'), findsOneWidget);
      expect(find.text('准备创作'), findsWidgets);
      expect(find.text('计划确认'), findsWidgets);
      expect(find.text('生成中'), findsWidgets);
      expect(find.text('结果预览'), findsWidgets);
      expect(find.text('导出分享'), findsWidgets);
      expect(tester.takeException(), isNull);

      await captureEvidence(tester, fileName: stateCase.fileName);
    }
  });
}

Widget _issue2CreationPage([_Issue2StateCase stateCase = _prepareState]) {
  return GenerateExportPage(
    selectedCount: stateCase.selectedCount,
    generated: stateCase.generated,
    generating: stateCase.generating,
    exported: stateCase.exported,
    creationPhase: stateCase.phase,
    statusMessage: stateCase.statusMessage,
    requestId: stateCase.requestId,
    logLines: stateCase.logLines,
    templateOptions: const ['温暖童趣', '童话式成长记忆', '简约纪实'],
    pageSizeOptions: const ['A4 竖版  210 × 297 mm', 'A4 横版  297 × 210 mm'],
    styleOptions: const ['温暖童趣  亲切温暖，适合儿童阅读'],
    exportTargetOptions: const [
      'PDF 文件  高质量 PDF（打印级别）',
      '长图 PNG 适合分享',
      'MP4 视频  回忆录视频',
    ],
    selectedTemplate: '温暖童趣',
    selectedPageSize: 'A4 竖版  210 × 297 mm',
    selectedStyle: '温暖童趣  亲切温暖，适合儿童阅读',
    selectedExportTarget: stateCase.exportTarget,
    onGenerate: () {},
    onConfirmPlan: () {},
    onExport: () {},
    onExportTargetChanged: (_) {},
    creationPlan: stateCase.plan,
    creationFailure: stateCase.failure,
    creationJobSteps: stateCase.steps,
    exportResult: stateCase.exportResult,
    shareCreating: stateCase.shareCreating,
    onOpenExportFolder: () {},
    onCreateShareLink: () {},
    onCopyShareText: () {},
    onOpenShareLink: () {},
    onCopyLongImage: () {},
    onViewSelectedAssets: () {},
    onPreviewAllPages: () {},
    onViewLogDetails: () {},
    onEditCreationRequest: () {},
  );
}

const _prepareState = _Issue2StateCase(
  fileName: '01-prepare.png',
  phase: CreationWorkflowPhase.preparing,
  statusMessage: '准备创作',
  selectedCount: 0,
);

final _issue2StateCases = <_Issue2StateCase>[
  _prepareState,
  const _Issue2StateCase(
    fileName: '02-planning.png',
    phase: CreationWorkflowPhase.planning,
    statusMessage: '正在分析素材、选择 Skill 并生成计划',
    generating: true,
    logLines: ['14:00:00 正在分析素材', '14:00:01 正在选择合适的 Skill'],
  ),
  const _Issue2StateCase(
    fileName: '03-plan-ready.png',
    phase: CreationWorkflowPhase.planReady,
    statusMessage: '创作计划已生成，请确认后开始生成。',
    plan: CreationPlanPreviewVm(
      summary: '使用 6 张素材生成一本 8 页温暖童趣绘本。',
      skillName: 'storybook_pdf',
      steps: [
        CreationPlanStepVm(
          stepId: 'analyze-assets',
          label: '分析素材',
          status: 'succeeded',
          detail: '识别照片、画作和故事线索',
        ),
        CreationPlanStepVm(
          stepId: 'draft-story',
          label: '生成绘本文案',
          status: 'pending',
          detail: '形成 8 页故事脚本',
        ),
      ],
      requirements: ['至少 1 张素材', '建议 6 张以上', 'PDF 输出'],
    ),
  ),
  const _Issue2StateCase(
    fileName: '04-starting-job.png',
    phase: CreationWorkflowPhase.creatingJob,
    statusMessage: '正在创建生成任务',
    generating: true,
    logLines: ['14:01:00 正在创建生成任务'],
  ),
  const _Issue2StateCase(
    fileName: '05-generating.png',
    phase: CreationWorkflowPhase.generating,
    statusMessage: '生成中...',
    generating: true,
    requestId: 'req_design_generating',
    steps: [
      CreationPlanStepVm(
        stepId: 'draft',
        label: '生成绘本文案',
        status: 'succeeded',
        detail: '故事脚本已完成',
      ),
      CreationPlanStepVm(
        stepId: 'render',
        label: '渲染 PDF 预览',
        status: 'running',
        detail: '正在生成页面和封面',
      ),
      CreationPlanStepVm(
        stepId: 'validate',
        label: '检查导出文件',
        status: 'pending',
        detail: '等待渲染完成',
      ),
    ],
    logLines: ['14:02:00 故事脚本已完成', '14:02:03 正在生成页面和封面'],
  ),
  const _Issue2StateCase(
    fileName: '06-job-failed.png',
    phase: CreationWorkflowPhase.failed,
    statusMessage: '生成失败：渲染 PDF 预览 未能完成。素材文件暂时不可读',
    failure: CreationFailureVm(
      stepLabel: '渲染 PDF 预览',
      reason: '素材文件暂时不可读',
      code: 'E_ASSET_UNAVAILABLE',
      category: 'asset',
      detail: '请重新选择素材或稍后重试',
    ),
    steps: [
      CreationPlanStepVm(
        stepId: 'draft',
        label: '生成绘本文案',
        status: 'succeeded',
        detail: '故事脚本已完成',
      ),
      CreationPlanStepVm(
        stepId: 'render',
        label: '渲染 PDF 预览',
        status: 'failed',
        detail: '素材文件暂时不可读',
      ),
    ],
    logLines: ['14:03:00 生成失败：素材文件暂时不可读'],
  ),
  const _Issue2StateCase(
    fileName: '07-preview-pdf.png',
    phase: CreationWorkflowPhase.reviewing,
    statusMessage: '生成完成，可预览并导出 PDF',
    generated: true,
    requestId: 'req_design_pdf',
    logLines: ['14:04:00 生成完成，可预览并导出 PDF'],
  ),
  const _Issue2StateCase(
    fileName: '08-preview-mp4.png',
    phase: CreationWorkflowPhase.reviewing,
    statusMessage: '回忆录视频已生成，可打开 MP4 预览',
    generated: true,
    exportTarget: 'MP4 视频  回忆录视频',
    requestId: 'req_design_mp4',
    logLines: ['14:05:00 回忆录视频已生成，可打开 MP4 预览'],
  ),
  const _Issue2StateCase(
    fileName: '09-exporting.png',
    phase: CreationWorkflowPhase.exporting,
    statusMessage: '正在导出到 /tmp/kidmemory-exports/job_123456.pdf',
    generated: true,
    generating: true,
    requestId: 'req_design_exporting',
    logLines: ['14:06:00 正在导出到 /tmp/kidmemory-exports/job_123456.pdf'],
  ),
  const _Issue2StateCase(
    fileName: '10-share-confirming.png',
    phase: CreationWorkflowPhase.published,
    statusMessage: 'PDF 导出成功，等待创建 Web 分享链接',
    generated: true,
    exported: true,
    exportResult: ExportResultVm(
      kind: 'pdf',
      localPath: '/tmp/kidmemory-exports/job_123456.pdf',
      storageStatus: 'local_ready',
      artifactId: 'artifact-job-pdf',
    ),
    logLines: ['14:07:00 PDF 导出成功，等待创建 Web 分享链接'],
  ),
  const _Issue2StateCase(
    fileName: '11-shared.png',
    phase: CreationWorkflowPhase.published,
    statusMessage: 'Web 分享链接已创建',
    generated: true,
    exported: true,
    exportResult: ExportResultVm(
      kind: 'pdf',
      localPath: '/tmp/kidmemory-exports/job_123456.pdf',
      storageStatus: 'synced',
      artifactId: 'artifact-job-pdf',
      remoteUrl: 'https://kidmemory.local/share/share_job_123456',
      shareText: '澄澄的成长绘本已经生成，可以通过分享链接查看。',
    ),
    logLines: ['14:08:00 Web 分享链接已创建'],
  ),
];

class _Issue2StateCase {
  const _Issue2StateCase({
    required this.fileName,
    required this.phase,
    required this.statusMessage,
    this.selectedCount = 6,
    this.generated = false,
    this.generating = false,
    this.exported = false,
    this.requestId = '',
    this.logLines = const [],
    this.exportTarget = 'PDF 文件  高质量 PDF（打印级别）',
    this.plan,
    this.failure,
    this.steps = const [],
    this.exportResult,
  });

  final String fileName;
  final CreationWorkflowPhase phase;
  final String statusMessage;
  final int selectedCount;
  final bool generated;
  final bool generating;
  final bool exported;
  final String requestId;
  final List<String> logLines;
  final String exportTarget;
  final CreationPlanPreviewVm? plan;
  final CreationFailureVm? failure;
  final List<CreationPlanStepVm> steps;
  final ExportResultVm? exportResult;
  bool get shareCreating => fileName == '10-share-confirming.png';
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
              'title': '本地资料库',
              'body': '等待本地服务返回资料库配置',
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
