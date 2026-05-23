import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/app/app_step.dart';
import 'package:kidmemory_desktop/app/desktop_shell.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';
import 'package:kidmemory_desktop/shared/widgets/chrome.dart';
import 'package:kidmemory_desktop/shared/widgets/content.dart';
import 'package:kidmemory_desktop/shared/widgets/layout.dart';

const _testPlanSteps = <Map<String, dynamic>>[
  {
    'stepId': 'compose',
    'label': 'Compose selected assets',
    'status': 'pending',
  },
  {
    'stepId': 'plan',
    'label': 'Confirm persisted agent plan',
    'status': 'pending',
  },
  {'stepId': 'generate', 'label': 'Generate PDF draft', 'status': 'pending'},
];

const _testPlanRequirements = <String>[
  'Selected assets',
  'OpenAI Agent SDK configuration',
  'Local export directory',
];

const _testStructuredPlanRequirements = <String, dynamic>{
  'minAssets': 1,
  'recommendedAssets': 6,
  'needsCloudImage': true,
  'needsHyperframes': false,
  'needsFfmpeg': false,
};

void main() {
  Finder primaryButton(String label) => find.byWidgetPredicate(
    (widget) => widget is PrimaryButton && widget.label == label,
  );

  Finder secondaryButton(String label) => find.byWidgetPredicate(
    (widget) => widget is SecondaryButton && widget.label == label,
  );

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

  Future<void> openSampleFromHome(WidgetTester tester) async {
    await gotoStep(tester, '孩子档案');
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看示例').first);
    await tester.pumpAndSettle();
  }

  Future<void> pumpUntil(
    WidgetTester tester,
    bool Function() predicate, {
    int limit = 30,
    Duration step = const Duration(milliseconds: 100),
  }) async {
    for (var i = 0; i < limit && !predicate(); i += 1) {
      await tester.pump(step);
    }
  }

  Future<void> selectOneAssetForGeneration(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await gotoStep(tester, '素材库');
    await tester.pumpAndSettle();
    await pumpUntil(tester, () => find.byType(AssetCard).evaluate().isNotEmpty);
    final firstAsset = find.byType(AssetCard).first;
    await tester.ensureVisible(firstAsset);
    final center = tester.getCenter(firstAsset);
    await tester.tapAt(center);
    await tester.pumpAndSettle();
  }

  Future<void> tapAssetCardByTitle(WidgetTester tester, String title) async {
    final card = find
        .ancestor(of: find.text(title).first, matching: find.byType(AssetCard))
        .first;
    await tester.ensureVisible(card);
    final center = tester.getCenter(card);
    await tester.tapAt(center);
    await tester.pumpAndSettle();
  }

  Future<void> confirmReadyCreationPlan(WidgetTester tester) async {
    final confirmButton = primaryButton('确认计划并开始生成').last;
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();
  }

  Future<void> generateStorybookFromPrimary(WidgetTester tester) async {
    await tester.ensureVisible(primaryButton('开始规划'));
    await tester.tap(primaryButton('开始规划'));
    await tester.pumpAndSettle();
    await confirmReadyCreationPlan(tester);
  }

  Future<void> generateMemoryVideoFromCard(WidgetTester tester) async {
    await tester.ensureVisible(find.text('生成回忆录视频'));
    await tester.tap(find.text('生成回忆录视频'));
    await tester.pumpAndSettle();
    await confirmReadyCreationPlan(tester);
  }

  testWidgets('desktop flow starts on child profile and exposes setup later', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: DesktopShell(api: _FakeSidecarApi())),
    );
    await tester.pumpAndSettle();

    expect(find.text('孩子档案'), findsWidgets);
    expect(find.text('成长统计'), findsOneWidget);

    expect(
      find.byWidgetPredicate(
        (widget) => widget is NavItem && widget.label == '示例数据集',
      ),
      findsNothing,
    );

    await openSampleFromHome(tester);
    await tester.pumpAndSettle();
    expect(find.text('示例数据集'), findsWidgets);
    expect(find.textContaining('使用隐私安全的虚拟素材'), findsOneWidget);
    expect(find.text('导入示例数据集'), findsOneWidget);
    expect(find.text('恐龙世界'), findsWidgets);

    await tester.tap(find.byTooltip('返回孩子档案'));
    await tester.pumpAndSettle();
    expect(find.text('成长统计'), findsOneWidget);

    await gotoStep(tester, '孩子档案');
    await tester.pumpAndSettle();
    expect(find.text('成长统计'), findsOneWidget);

    await gotoStep(tester, '素材库');
    await tester.pumpAndSettle();
    expect(find.text('恐龙世界'), findsWidgets);

    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();
    expect(primaryButton('开始规划'), findsOneWidget);
    expect(find.text('Agent 活动'), findsNothing);
  });

  testWidgets('sample dataset is a child profile subpage with shared back', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: DesktopShell(api: _FakeSidecarApi())),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is NavItem && widget.label == '示例数据集',
      ),
      findsNothing,
    );
    expect(find.text('成长统计'), findsOneWidget);

    await tester.tap(find.text('查看示例').first);
    await tester.pumpAndSettle();

    expect(find.text('示例数据集'), findsWidgets);
    expect(find.byType(PageBackButton), findsOneWidget);
    expect(find.byTooltip('返回孩子档案'), findsOneWidget);

    await tester.tap(find.byType(PageBackButton));
    await tester.pumpAndSettle();

    expect(find.text('孩子档案'), findsWidgets);
    expect(find.text('成长统计'), findsOneWidget);
    expect(find.text('示例数据集'), findsNothing);
  });

  testWidgets(
    'generate page shows smart actions and free image confirm dialog',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _FakeSidecarApi();
      await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
      await tester.pumpAndSettle();

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      expect(find.text('生成儿童绘本'), findsWidgets);
      expect(find.text('生成成长纪念册'), findsOneWidget);
      expect(find.text('生成回忆录视频'), findsOneWidget);

      await tester.tap(find.text('生成儿童绘本').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('将使用免费生图服务生成封面图'), findsNothing);
      expect(api.lastTaskBody?['creationType'], 'storybook');
      expect(api.lastGenerateBody, isNull);
      expect(find.text('确认创作计划'), findsOneWidget);
      expect(find.text('KidMemory storybook'), findsOneWidget);
      expect(find.text('Compose selected assets'), findsOneWidget);
      expect(find.text('Selected assets'), findsOneWidget);
      expect(find.text('OpenAI Agent SDK configuration'), findsOneWidget);
      expect(find.text('确认计划并开始生成'), findsWidgets);
      await confirmReadyCreationPlan(tester);
      expect(api.lastGenerateBody?['taskId'], 'task_123456');
    },
  );

  testWidgets('memory album action sends memory_book creation type', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FakeSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('生成成长纪念册'));
    await tester.tap(find.text('生成成长纪念册'));
    await tester.pumpAndSettle();

    expect(api.lastTaskBody?['creationType'], 'memory_book');
    expect(find.text('确认创作计划'), findsOneWidget);
  });

  testWidgets('generation exposes planning and creating job workflow states', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SlowCreationSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await tester.tap(find.text('生成儿童绘本').first);
    await tester.pump();

    expect(find.text('规划中'), findsWidgets);
    expect(find.textContaining('正在分析素材'), findsWidgets);
    expect(find.text('分析素材'), findsWidgets);
    expect(find.text('选择 Skill'), findsWidgets);
    expect(find.text('生成计划'), findsWidgets);
    expect(find.textContaining('正在读取 1 张素材'), findsWidgets);
    expect(find.textContaining('正在匹配绘本'), findsWidgets);
    expect(find.textContaining('正在组织故事结构'), findsWidgets);

    api.completePlan();
    await tester.pump();
    await tester.pump();

    expect(find.text('计划待确认'), findsWidgets);
    expect(find.text('确认创作计划'), findsOneWidget);
    expect(api.lastGenerateBody, isNull);

    final confirmButton = primaryButton('确认计划并开始生成').last;
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pump();

    expect(find.text('创建任务中'), findsWidgets);
    expect(find.textContaining('正在创建生成任务'), findsWidgets);
    expect(api.lastGenerateBody?['taskId'], 'task_slow');

    api.completeJob();
    await tester.pumpAndSettle();

    expect(find.textContaining('生成完成，可预览并导出 PDF'), findsWidgets);
  });

  testWidgets('changing selected assets invalidates the previous plan id', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SequencedPlanSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateStorybookFromPrimary(tester);

    expect(api.createdTaskIds, ['task_1']);
    expect(api.generatedTaskIds, ['task_1']);
    expect(find.textContaining('生成完成，可预览并导出 PDF'), findsWidgets);

    await gotoStep(tester, '素材库');
    await tester.pumpAndSettle();
    await tapAssetCardByTitle(tester, '恐龙世界');
    await tester.pumpAndSettle();
    await tapAssetCardByTitle(tester, '恐龙世界');
    await tester.pumpAndSettle();

    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();
    expect(primaryButton('开始规划'), findsOneWidget);

    await generateStorybookFromPrimary(tester);

    expect(api.createdTaskIds, ['task_1', 'task_2']);
    expect(api.generatedTaskIds, ['task_1', 'task_2']);
    expect(api.lastTaskBody?['assetIds'], ['asset-dino-world']);
  });

  testWidgets('plan failure exposes retry edit and log actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _PlanFailureSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await tester.ensureVisible(primaryButton('开始规划'));
    await tester.tap(primaryButton('开始规划'));
    await tester.pumpAndSettle();

    expect(api.taskAttempts, 1);
    expect(find.text('生成失败'), findsWidgets);
    expect(find.textContaining('规划服务暂时不可用'), findsWidgets);
    expect(secondaryButton('重试'), findsOneWidget);
    expect(secondaryButton('修改需求'), findsOneWidget);
    expect(secondaryButton('查看日志'), findsWidgets);

    await tester.ensureVisible(secondaryButton('查看日志'));
    await tester.tap(secondaryButton('查看日志').first);
    await tester.pumpAndSettle();

    expect(find.text('生成日志详情'), findsOneWidget);
    expect(find.textContaining('requestId: req_'), findsWidgets);

    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    await tester.tap(secondaryButton('重试'));
    await tester.pumpAndSettle();

    expect(api.taskAttempts, 2);

    await tester.ensureVisible(secondaryButton('修改需求'));
    await tester.tap(secondaryButton('修改需求'));
    await tester.pumpAndSettle();

    expect(find.text('素材库'), findsWidgets);
  });

  testWidgets('generation failure exposes failed step reason log and replan', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FailedCreationJobSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateStorybookFromPrimary(tester);

    expect(api.taskAttempts, 1);
    expect(api.generateAttempts, 1);
    expect(find.text('生成失败'), findsWidgets);
    expect(find.textContaining('Skill runtime crashed'), findsWidgets);
    expect(find.text('失败步骤：Generate PDF draft'), findsOneWidget);
    expect(find.text('错误代码：E_SKILL_RUNTIME'), findsOneWidget);
    expect(secondaryButton('重新规划'), findsOneWidget);
    expect(secondaryButton('修改需求'), findsOneWidget);
    expect(secondaryButton('查看日志'), findsWidgets);

    await tester.ensureVisible(secondaryButton('查看日志'));
    await tester.tap(secondaryButton('查看日志').first);
    await tester.pumpAndSettle();

    expect(find.text('生成日志详情'), findsOneWidget);
    expect(find.textContaining('E_SKILL_RUNTIME'), findsWidgets);
    expect(find.textContaining('Skill runtime crashed'), findsWidgets);
    expect(find.textContaining('requestId: req_'), findsWidgets);
    expect(find.textContaining('taskId: task_failed_1'), findsWidgets);

    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(secondaryButton('重新规划'));
    await tester.tap(secondaryButton('重新规划'));
    await tester.pumpAndSettle();

    expect(api.taskAttempts, 2);
    expect(find.text('确认创作计划'), findsOneWidget);
    expect(find.text('生成失败'), findsNothing);

    await tester.ensureVisible(secondaryButton('修改需求'));
    await tester.tap(secondaryButton('修改需求'));
    await tester.pumpAndSettle();

    expect(find.text('素材库'), findsWidgets);
  });

  testWidgets('memoir video failure exposes MP4 reason log and regenerate', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FailedMemoirVideoCreationJobSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateMemoryVideoFromCard(tester);

    expect(api.taskAttempts, 1);
    expect(api.generateAttempts, 1);
    expect(api.lastTaskBody?['creationType'], 'memoir_video');
    expect(find.text('生成失败'), findsWidgets);
    expect(find.textContaining('Hyperframes 未能成功生成 MP4'), findsWidgets);
    expect(find.text('失败步骤：生成 MP4 视频'), findsOneWidget);
    expect(find.text('错误代码：E_HYPERFRAMES_RENDER'), findsOneWidget);
    expect(secondaryButton('重新生成'), findsOneWidget);
    expect(secondaryButton('查看日志'), findsWidgets);

    await tester.ensureVisible(secondaryButton('查看日志'));
    await tester.tap(secondaryButton('查看日志').first);
    await tester.pumpAndSettle();

    expect(find.text('生成日志详情'), findsOneWidget);
    expect(find.textContaining('E_HYPERFRAMES_RENDER'), findsWidgets);
    expect(find.textContaining('taskId: task_video_failed_1'), findsWidgets);

    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(secondaryButton('重新生成'));
    await tester.tap(secondaryButton('重新生成'));
    await tester.pumpAndSettle();

    expect(api.taskAttempts, 2);
    expect(api.lastTaskBody?['creationType'], 'memoir_video');
    expect(find.text('确认创作计划'), findsOneWidget);
  });

  testWidgets('memoir video creation shows video environment preparation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SlowMemoirVideoCreationJobSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('生成回忆录视频'));
    await tester.tap(find.text('生成回忆录视频'));
    await tester.pumpAndSettle();

    final confirmButton = primaryButton('确认计划并开始生成').last;
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pump();
    await tester.pump();

    expect(api.lastTaskBody?['creationType'], 'memoir_video');
    expect(api.lastGenerateBody?['taskId'], 'task_video_slow');
    expect(find.text('准备视频环境'), findsWidgets);
    expect(find.textContaining('正在准备视频生成环境'), findsWidgets);

    api.completeJob();
    await tester.pumpAndSettle();

    expect(find.text('打开视频预览'), findsOneWidget);
  });

  testWidgets(
    'creation task polls detail until completion and renders backend steps',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _PollingCreationSidecarApi();
      await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
      await tester.pumpAndSettle();

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      await tester.ensureVisible(primaryButton('开始规划'));
      await tester.tap(primaryButton('开始规划'));
      await tester.pumpAndSettle();
      final confirmButton = primaryButton('确认计划并开始生成').last;
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pump();
      await tester.pump();

      expect(api.pollCount, 0);
      expect(find.text('Generate PDF draft'), findsWidgets);
      expect(find.text('Running skill workspace'), findsOneWidget);
      expect(find.text('生成中'), findsWidgets);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(api.pollCount, 1);
      expect(find.text('Validate final artifact'), findsWidgets);
      expect(find.text('Ready for review'), findsOneWidget);
      expect(find.textContaining('生成完成，可预览并导出 PDF'), findsWidgets);
    },
  );

  testWidgets('creation task polling stops when leaving the generate page', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _RunningCreationSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await tester.ensureVisible(primaryButton('开始规划'));
    await tester.tap(primaryButton('开始规划'));
    await tester.pumpAndSettle();
    final confirmButton = primaryButton('确认计划并开始生成').last;
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pump();
    await tester.pump();

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(api.pollCount, 1);

    await gotoStep(tester, '素材库');
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(api.pollCount, 1);
  });

  testWidgets(
    'cover failure exposes retry/log actions without skip cover policy',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _CoverFailureSidecarApi();
      await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
      await tester.pumpAndSettle();

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      await tester.tap(find.text('生成儿童绘本').first);
      await tester.pumpAndSettle();

      expect(find.text('封面图生成失败'), findsWidgets);
      expect(secondaryButton('重试'), findsOneWidget);
      expect(secondaryButton('跳过封面继续导出'), findsNothing);
      expect(find.text('跳过封面'), findsNothing);
      expect(secondaryButton('查看日志'), findsOneWidget);
      expect(find.textContaining('Request ID: req_'), findsNothing);

      await tester.ensureVisible(secondaryButton('查看日志'));
      await tester.tap(secondaryButton('查看日志'));
      await tester.pumpAndSettle();
      expect(find.text('生成日志详情'), findsOneWidget);
      expect(find.textContaining('requestId: req_'), findsWidgets);
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(secondaryButton('重试'));
      await tester.tap(secondaryButton('重试'));
      await tester.pumpAndSettle();

      expect(
        (api.lastTaskBody?['settings'] as Map?)?.containsKey('coverPolicy') ??
            false,
        false,
      );
      expect(find.text('封面图生成失败'), findsWidgets);
    },
  );

  testWidgets(
    'desktop flow keeps navigation open when only optional OpenAI is missing',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: DesktopShell(api: _UnconfiguredSidecarApi())),
      );
      await tester.pumpAndSettle();

      final setupTitleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == '设置' &&
            widget.style?.fontSize == 31,
      );

      expect(setupTitleFinder, findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is NavItem && widget.label == '孩子档案',
        ),
        findsOneWidget,
      );
      expect(find.text('成长统计'), findsOneWidget);

      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is NavItem && widget.label == '设置',
            )
            .first,
      );
      await tester.pumpAndSettle();

      expect(setupTitleFinder, findsOneWidget);
      expect(find.textContaining('Base URL、模型与 API Key'), findsOneWidget);
    },
  );

  testWidgets('asset library replaces the standalone search navigation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: DesktopShell(api: _FakeSidecarApi())),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is NavItem && widget.label == '搜图',
      ),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is NavItem && widget.label == '素材库',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'asset library runs semantic search inline and selects results for generation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _MergedSearchSidecarApi();
      await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
      await tester.pumpAndSettle();

      await gotoStep(tester, '素材库');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '太阳');
      await tester.tap(find.text('搜索'));
      await tester.pumpAndSettle();

      expect(api.lastSearchBody?['query'], '太阳');
      expect(find.text('太阳画'), findsWidgets);
      expect(find.textContaining('标签匹配：太阳'), findsWidgets);
    },
  );

  testWidgets('empty child profile shows add action before profile content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _NoChildrenSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('还没有孩子档案'), findsOneWidget);
    expect(find.text('添加孩子档案'), findsOneWidget);
    expect(find.text('成长统计'), findsNothing);

    await tester.tap(find.text('添加孩子档案'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '安安');
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();

    expect(api.lastChildrenName, '安安');
    expect(find.text('安安'), findsWidgets);
    expect(find.text('成长统计'), findsOneWidget);
  });

  testWidgets(
    'setup page shows disconnected sidecar state with local defaults',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: DesktopShell(api: _DisconnectedSidecarApi())),
      );
      await tester.pump();
      await gotoStep(tester, '设置');
      await tester.pumpAndSettle();

      expect(find.text('大模型接口配置'), findsWidgets);
      expect(find.text('云端分享设置'), findsOneWidget);
      expect(find.text('Storage 配置'), findsNothing);
      expect(find.textContaining('Sidecar'), findsNothing);
      expect(find.textContaining('未连接'), findsWidgets);
    },
  );

  test(
    'startup gate unlocks to child when readiness becomes available without a selected child',
    () {
      expect(
        resolveStartupConfigurationStep(
          needsConfiguration: false,
          wasRequired: true,
          currentStep: AppStep.setup,
          selectedChildId: null,
        ),
        AppStep.child,
      );
    },
  );

  testWidgets('setup readiness only requires the OpenAI key path', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: DesktopShell(api: _FakeSidecarApi())),
    );
    await tester.pumpAndSettle();
    await gotoStep(tester, '设置');
    await tester.pumpAndSettle();

    expect(find.text('大模型接口配置'), findsOneWidget);
    expect(find.text('云端分享设置'), findsOneWidget);
    expect(find.text('Storage 配置'), findsNothing);
    expect(find.textContaining('初始化成功'), findsWidgets);
    expect(find.text('正在安装...'), findsNothing);
    expect(find.text('请完成配置后开始使用KidMemory'), findsNothing);
  });

  testWidgets(
    'setup page manages Supabase Storage without exposing service role key',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _SupabaseStorageSidecarApi();
      await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
      await tester.pumpAndSettle();
      await gotoStep(tester, '设置');
      await tester.pumpAndSettle();

      expect(find.text('云端分享设置'), findsOneWidget);
      expect(find.text('Storage 配置'), findsNothing);
      expect(find.text('已配置'), findsWidgets);
      expect(find.text('修改配置'), findsWidgets);
      expect(find.text('测试连接'), findsWidgets);
      expect(find.textContaining('secret-service-role'), findsNothing);

      await tester.ensureVisible(secondaryButton('测试连接').last);
      await tester.tap(secondaryButton('测试连接').last);
      await tester.pumpAndSettle();

      expect(api.storageTestCalls, 1);
      expect(find.textContaining('测试通过'), findsWidgets);
    },
  );

  testWidgets('setup page storage test failure uses product language', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SupabaseStorageSidecarApi(failStorageTest: true);
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();
    await gotoStep(tester, '设置');
    await tester.pumpAndSettle();

    await tester.ensureVisible(secondaryButton('测试连接').last);
    await tester.tap(secondaryButton('测试连接').last);
    await tester.pumpAndSettle();

    expect(api.storageTestCalls, 1);
    expect(find.textContaining('测试连接失败'), findsWidgets);
    expect(find.textContaining('云端分享连接不可用'), findsWidgets);
    expect(find.textContaining('Supabase Storage'), findsNothing);
  });

  testWidgets(
    'setup page configures Supabase S3 fields and toggles secret visibility',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _SupabaseStorageSidecarApi();
      String? openedUrl;
      await tester.pumpWidget(
        MaterialApp(
          home: DesktopShell(
            api: api,
            openExternalTarget: (url) async {
              openedUrl = url;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await gotoStep(tester, '设置');
      await tester.pumpAndSettle();

      final configureButton = find
          .byWidgetPredicate(
            (widget) => widget is SecondaryButton && widget.label == '修改配置',
          )
          .last;
      await tester.ensureVisible(configureButton);
      await tester.tap(configureButton);
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(find.text('配置云端分享'), findsOneWidget);
      final fields = find.descendant(
        of: dialog,
        matching: find.byType(TextField),
      );
      expect(fields, findsNWidgets(9));
      expect(find.textContaining('推荐使用云端私有存储'), findsOneWidget);

      await tester.tap(find.byTooltip('打开 Supabase S3 官方说明'));
      await tester.pumpAndSettle();
      expect(
        openedUrl,
        'https://supabase.com/docs/guides/storage/s3/authentication/',
      );

      final s3AccessField = fields.at(3);
      final s3SecretField = fields.at(4);
      expect(tester.widget<TextField>(s3AccessField).obscureText, isTrue);
      expect(tester.widget<TextField>(s3SecretField).obscureText, isTrue);

      final s3AccessToggle = find.byTooltip('显示').first;
      expect(s3AccessToggle, findsOneWidget);
      await tester.tap(s3AccessToggle);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(s3AccessField).obscureText, isFalse);

      await tester.enterText(
        fields.at(0),
        'https://project-ref.storage.supabase.co/storage/v1/s3',
      );
      await tester.enterText(fields.at(1), 'auto');
      await tester.enterText(fields.at(2), 'kidmemory');
      await tester.enterText(fields.at(3), 's3-access-key');
      await tester.enterText(fields.at(4), 's3-secret-key');

      await tester.tap(find.descendant(of: dialog, matching: find.text('保存')));
      await tester.pumpAndSettle();

      expect(api.lastStorageConfigBody?['bucket'], 'kidmemory');
      expect(
        api.lastStorageConfigBody?['s3Endpoint'],
        contains('/storage/v1/s3'),
      );
      expect(api.lastStorageConfigBody?['s3Region'], 'auto');
      expect(api.lastStorageConfigBody?['s3AccessKeyId'], 's3-access-key');
      expect(api.lastStorageConfigBody?['s3SecretAccessKey'], 's3-secret-key');

      await tester.tap(configureButton);
      await tester.pumpAndSettle();

      final reopenedDialog = find.byType(AlertDialog);
      final reopenedFields = find.descendant(
        of: reopenedDialog,
        matching: find.byType(TextField),
      );
      final reopenedAccessField = reopenedFields.at(3);
      final reopenedSecretField = reopenedFields.at(4);
      expect(
        tester.widget<TextField>(reopenedAccessField).controller?.text,
        's3-access-key',
      );
      expect(
        tester.widget<TextField>(reopenedSecretField).controller?.text,
        's3-secret-key',
      );
      expect(tester.widget<TextField>(reopenedAccessField).obscureText, isTrue);
      expect(tester.widget<TextField>(reopenedSecretField).obscureText, isTrue);

      final reopenedAccessToggle = find.byTooltip('显示').first;
      await tester.tap(reopenedAccessToggle);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(reopenedAccessField).obscureText,
        isFalse,
      );
    },
  );

  testWidgets(
    'export flow uses configured export directory before calling sidecar export',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _FakeSidecarApi();

      await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      await generateStorybookFromPrimary(tester);
      expect(find.text('导出 PDF'), findsOneWidget);

      await tester.tap(find.text('导出 PDF'));
      await pumpUntil(tester, () => api.lastExportBody != null);
      await tester.pumpAndSettle();

      expect(
        api.lastExportBody?['targetPath'],
        '/tmp/kidmemory-exports/task_123456.pdf',
      );
      expect(find.textContaining('点击导出，准备读取当前导出目录'), findsOneWidget);
      expect(
        find.textContaining('PDF 导出成功：/tmp/kidmemory-exports/task_123456.pdf'),
        findsOneWidget,
      );
      expect(
        find.textContaining('PDF 已导出：/tmp/kidmemory-exports/task_123456.pdf'),
        findsOneWidget,
      );
    },
  );

  testWidgets('export flow exposes exporting phase while sidecar export runs', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SlowExportSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateStorybookFromPrimary(tester);

    await tester.tap(find.text('导出 PDF'));
    await pumpUntil(tester, () => api.lastExportBody != null);
    await tester.pump();

    expect(find.text('正在导出到本地'), findsWidgets);
    expect(
      find.textContaining('正在导出到 /tmp/kidmemory-exports/task_123456.pdf'),
      findsWidgets,
    );

    api.completeExport();
    await tester.pumpAndSettle();

    expect(
      find.textContaining('PDF 已导出：/tmp/kidmemory-exports/task_123456.pdf'),
      findsOneWidget,
    );
  });

  testWidgets(
    'export flow normalizes relative export directories before export',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _RelativePathSidecarApi();
      await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
      await tester.pumpAndSettle();

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      await generateStorybookFromPrimary(tester);
      await tester.tap(find.text('导出 PDF'));
      await pumpUntil(tester, () => api.lastExportBody != null);
      await tester.pumpAndSettle();

      final home =
          Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '.';
      final expectedRoot = Platform.isMacOS
          ? '$home/Library/Application Support/KidMemory/exports'
          : Platform.isWindows
          ? '${Platform.environment['APPDATA'] ?? home}/KidMemory/exports'
          : '$home/.local/share/KidMemory/exports';

      expect(api.lastExportBody?['targetPath'], '$expectedRoot/task_123456.pdf');
      expect(
        find.textContaining('PDF 导出成功：$expectedRoot/task_123456.pdf'),
        findsOneWidget,
      );
    },
  );

  testWidgets('memoir video export uses MP4 target in export directory', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FakeSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateMemoryVideoFromCard(tester);
    expect(api.lastTaskBody?['creationType'], 'memoir_video');
    expect(find.text('导出 MP4'), findsOneWidget);

    await tester.tap(find.text('导出 MP4'));
    await pumpUntil(tester, () => api.lastExportBody != null);
    await tester.pumpAndSettle();

    expect(api.lastExportBody?['target'], 'mp4');
    expect(
      api.lastExportBody?['targetPath'],
      '/tmp/kidmemory-exports/task_123456.mp4',
    );
    expect(
      find.textContaining('MP4 已导出：/tmp/kidmemory-exports/task_123456.mp4'),
      findsOneWidget,
    );
  });

  testWidgets('memoir video preview opens generated MP4 artifact', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SuccessfulMemoirVideoCreationJobSidecarApi();
    String? openedTarget;
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          api: api,
          openExternalTarget: (target) async {
            openedTarget = target;
          },
        ),
      ),
    );

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateMemoryVideoFromCard(tester);

    expect(api.lastTaskBody?['creationType'], 'memoir_video');
    expect(find.text('打开视频预览'), findsOneWidget);
    expect(find.text('预览全部页面'), findsNothing);

    await tester.ensureVisible(secondaryButton('打开视频预览'));
    await tester.tap(secondaryButton('打开视频预览'));
    await tester.pumpAndSettle();

    expect(openedTarget, '/tmp/kidmemory-exports/task_video_success.mp4');
  });

  testWidgets('switching back to storybook restores PDF export target', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FakeSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('生成回忆录视频'));
    await tester.tap(find.text('生成回忆录视频'));
    await tester.pumpAndSettle();
    expect(api.lastTaskBody?['creationType'], 'memoir_video');

    await tester.ensureVisible(secondaryButton('修改需求'));
    await tester.tap(secondaryButton('修改需求'));
    await tester.pumpAndSettle();
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('生成儿童绘本').first);
    await tester.tap(find.text('生成儿童绘本').first);
    await tester.pumpAndSettle();
    await confirmReadyCreationPlan(tester);

    expect(api.lastTaskBody?['creationType'], 'storybook');
    expect(find.text('导出 PDF'), findsOneWidget);

    await tester.tap(find.text('导出 PDF'));
    await pumpUntil(tester, () => api.lastExportBody != null);
    await tester.pumpAndSettle();

    expect(api.lastExportBody?['target'], 'pdf');
    expect(
      api.lastExportBody?['targetPath'],
      '/tmp/kidmemory-exports/task_123456.pdf',
    );
  });

  testWidgets(
    'export flow supports JPG long image sync and private share copy',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _SupabaseStorageSidecarApi();
      String? copiedText;
      await tester.pumpWidget(
        MaterialApp(
          home: DesktopShell(
            api: api,
            copyToClipboard: (text) async {
              copiedText = text;
            },
          ),
        ),
      );

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      await tester.tap(find.text('PDF 文件 高质量 PDF（打印级别）').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('长图 JPG 体积更小').last);
      await tester.pumpAndSettle();

      await generateStorybookFromPrimary(tester);
      await tester.tap(primaryButton('导出 JPG 长图'));
      await pumpUntil(tester, () => api.lastLongImageExportBody != null);
      await tester.pumpAndSettle();

      expect(
        api.lastLongImageExportBody?['targetPath'],
        '/tmp/kidmemory-exports/task_123456.jpg',
      );
      expect(api.lastLongImageExportBody?['target'], 'long_image_jpg');
      expect(api.storageSyncArtifactIds, contains('artifact-task-jpg'));
      expect(api.storageWorkerRuns, 1);
      expect(find.textContaining('长图 JPG 已导出'), findsWidgets);
      expect(find.textContaining('链接有效期：3600 秒'), findsWidgets);

      await tester.ensureVisible(secondaryButton('复制分享文案'));
      await tester.tap(secondaryButton('复制分享文案'));
      await tester.pumpAndSettle();

      expect(copiedText, contains('链接有效期：3600 秒'));
    },
  );

  testWidgets('pdf share flow confirms before creating a web share link', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SlowShareSidecarApi();
    final openedTargets = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          api: api,
          openExternalTarget: (target) async {
            openedTargets.add(target);
          },
        ),
      ),
    );

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateStorybookFromPrimary(tester);
    await tester.tap(find.text('导出 PDF'));
    await pumpUntil(tester, () => api.lastExportBody != null);
    await tester.pumpAndSettle();

    await tester.ensureVisible(secondaryButton('创建分享链接'));
    await tester.tap(secondaryButton('创建分享链接'));
    await tester.pumpAndSettle();

    expect(find.text('创建 Web 分享链接'), findsOneWidget);
    expect(find.text('这会将导出作品上传到云端，用于生成 Web 分享链接。'), findsOneWidget);
    expect(api.shareRequests, 0);

    await tester.tap(find.text('创建分享链接').last);
    await pumpUntil(tester, () => api.lastShareBody != null);
    await tester.pump();

    expect(api.shareRequests, 1);
    expect(api.lastShareBody?['artifactId'], 'artifact-task-pdf');
    expect(find.text('正在创建 Web 分享链接...'), findsWidgets);

    api.completeShare();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Web 分享链接已创建'), findsWidgets);
    expect(
      find.textContaining('http://localhost:3001/share/share_task_123456'),
      findsWidgets,
    );

    await tester.ensureVisible(secondaryButton('打开链接'));
    await tester.tap(secondaryButton('打开链接'));
    await tester.pumpAndSettle();

    expect(openedTargets, ['http://localhost:3001/share/share_task_123456']);
  });

  testWidgets('pdf share failure exposes retry and log actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FailingShareSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateStorybookFromPrimary(tester);
    await tester.tap(find.text('导出 PDF'));
    await pumpUntil(tester, () => api.lastExportBody != null);
    await tester.pumpAndSettle();

    await tester.ensureVisible(secondaryButton('创建分享链接'));
    await tester.tap(secondaryButton('创建分享链接'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建分享链接').last);
    await pumpUntil(tester, () => api.shareRequests == 1);
    await tester.pumpAndSettle();

    expect(api.lastShareBody?['artifactId'], 'artifact-task-pdf');
    expect(find.textContaining('分享链接创建失败'), findsWidgets);
    expect(find.textContaining('分享服务暂时不可用'), findsWidgets);
    expect(secondaryButton('重试创建'), findsOneWidget);
    expect(secondaryButton('查看日志'), findsWidgets);

    await tester.ensureVisible(secondaryButton('查看日志').last);
    await tester.tap(secondaryButton('查看日志').last);
    await tester.pumpAndSettle();

    expect(find.text('生成日志详情'), findsOneWidget);
    expect(find.textContaining('分享服务暂时不可用'), findsWidgets);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(secondaryButton('重试创建'));
    await tester.tap(secondaryButton('重试创建'));
    await tester.pumpAndSettle();

    expect(api.shareRequests, 1);
    expect(find.text('创建 Web 分享链接'), findsOneWidget);
    await tester.tap(find.text('创建分享链接').last);
    await pumpUntil(tester, () => api.shareRequests == 2);
    await tester.pumpAndSettle();

    expect(find.textContaining('分享链接创建失败'), findsWidgets);
  });

  testWidgets('pdf export failure exposes reason log and retry action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FailingExportSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateStorybookFromPrimary(tester);
    await tester.tap(find.text('导出 PDF'));
    await pumpUntil(tester, () => api.exportRequests == 1);
    await tester.pumpAndSettle();

    expect(find.textContaining('PDF 导出异常'), findsWidgets);
    expect(find.textContaining('导出服务暂时不可用'), findsWidgets);
    expect(secondaryButton('查看日志'), findsWidgets);
    expect(find.text('导出 PDF'), findsWidgets);

    await tester.ensureVisible(secondaryButton('查看日志').last);
    await tester.tap(secondaryButton('查看日志').last);
    await tester.pumpAndSettle();

    expect(find.text('生成日志详情'), findsOneWidget);
    expect(find.textContaining('导出服务暂时不可用'), findsWidgets);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('导出 PDF'));
    await pumpUntil(tester, () => api.exportRequests == 2);
    await tester.pumpAndSettle();

    expect(find.textContaining('PDF 导出异常'), findsWidgets);
  });

  testWidgets('generate page opens a full log dialog', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: DesktopShell(api: _FakeSidecarApi())),
    );

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();
    await generateStorybookFromPrimary(tester);
    expect(find.textContaining('Request ID:'), findsNothing);
    expect(find.textContaining('taskId:'), findsNothing);
    await tester.ensureVisible(secondaryButton('查看详细日志'));
    await tester.tap(secondaryButton('查看详细日志'));
    await tester.pumpAndSettle();

    expect(find.text('生成日志详情'), findsOneWidget);
    expect(find.textContaining('状态：'), findsWidgets);
    expect(find.textContaining('requestId: req_'), findsWidgets);
    expect(find.textContaining('taskId: task_123456'), findsWidgets);
  });

  testWidgets('preview all pages opens after generated job ready', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FakeSidecarApi();
    String? openedUrl;
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          api: api,
          openExternalTarget: (url) async {
            openedUrl = url;
          },
        ),
      ),
    );

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    expect(find.textContaining('生成完成后，可以导出 PDF、长图或创建分享链接'), findsNothing);
    expect(secondaryButton('预览全部页面'), findsNothing);

    await generateStorybookFromPrimary(tester);
    expect(secondaryButton('预览全部页面'), findsOneWidget);
    await tester.ensureVisible(secondaryButton('预览全部页面'));
    await tester.tap(secondaryButton('预览全部页面'));
    await tester.pumpAndSettle();
    expect(openedUrl, '${api.baseUrl}/creation/tasks/task_123456/preview');
  });

  testWidgets('pdf preview failure exposes reason folder and log actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FakeSidecarApi();
    final openedTargets = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          api: api,
          openExternalTarget: (target) async {
            if (target.endsWith('/preview')) {
              throw StateError('preview route unavailable');
            }
            openedTargets.add(target);
          },
        ),
      ),
    );

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await generateStorybookFromPrimary(tester);
    await tester.ensureVisible(secondaryButton('预览全部页面'));
    await tester.tap(secondaryButton('预览全部页面'));
    await tester.pumpAndSettle();

    expect(find.text('PDF 预览失败'), findsOneWidget);
    expect(find.textContaining('preview route unavailable'), findsWidgets);
    expect(secondaryButton('打开导出文件夹'), findsWidgets);
    expect(secondaryButton('查看日志'), findsWidgets);

    await tester.ensureVisible(secondaryButton('打开导出文件夹').first);
    await tester.tap(secondaryButton('打开导出文件夹').first);
    await tester.pumpAndSettle();
    expect(openedTargets, ['/tmp/kidmemory-exports']);

    await tester.ensureVisible(secondaryButton('查看日志').first);
    await tester.tap(secondaryButton('查看日志').first);
    await tester.pumpAndSettle();
    expect(find.text('生成日志详情'), findsOneWidget);
    expect(find.textContaining('PDF 预览失败'), findsWidgets);
  });

  testWidgets('editing child profile posts updated name to children api', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _MultiChildSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await gotoStep(tester, '孩子档案');
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    final editDialog = find.byType(AlertDialog);
    final dialogTextFields = find.descendant(
      of: editDialog,
      matching: find.byType(TextField),
    );
    expect(dialogTextFields, findsNWidgets(3));
    await tester.enterText(dialogTextFields.at(0), '新名字');
    await tester.tap(
      find.descendant(of: editDialog, matching: find.text('保存')),
    );
    await tester.pumpAndSettle();

    expect(api.lastChildrenName, '新名字');
  });

  testWidgets(
    'sample dataset page has no overflow on 1280x720 desktop window',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: DesktopShell(api: _FakeSidecarApi())),
      );
      await tester.pumpAndSettle();
      await openSampleFromHome(tester);
      await tester.pumpAndSettle();

      expect(find.text('示例数据集'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('generation request includes the selected child id', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _MultiChildSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await gotoStep(tester, '素材库');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('甜甜').last);
    await tester.pumpAndSettle();
    await pumpUntil(tester, () => find.byType(AssetCard).evaluate().isNotEmpty);
    await tester.pumpAndSettle();

    if (find.text('甜甜的画').evaluate().isNotEmpty) {
      await tapAssetCardByTitle(tester, '甜甜的画');
    } else {
      final firstAsset = find.byType(AssetCard).first;
      await tester.ensureVisible(firstAsset);
      await tester.tapAt(tester.getCenter(firstAsset));
      await tester.pumpAndSettle();
    }

    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();
    await generateStorybookFromPrimary(tester);

    expect((api.lastGenerateBody?['settings'] as Map?)?['childId'], 'child-2');
  });

  testWidgets('bulk delete ignores assets hidden by the current child filter', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _MultiChildSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await gotoStep(tester, '素材库');
    await tester.pumpAndSettle();
    await tapAssetCardByTitle(tester, '澄澄的画');
    await tester.pumpAndSettle();
    final childDropdown = find.byType(DropdownButtonFormField<String>).first;
    await tester.ensureVisible(childDropdown);
    await tester.tap(childDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('甜甜').last);
    await tester.pumpAndSettle();
    await pumpUntil(tester, () => find.text('甜甜的画').evaluate().isNotEmpty);
    await tester.pumpAndSettle();

    expect(find.text('批量删除已选'), findsNothing);
    expect(api.deletedAssetIds, isNot(contains('asset-dino-world')));
  });

  testWidgets(
    'desktop shell starts without a hardcoded selected sample asset and uses sidecar child data',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: DesktopShell(api: _FakeSidecarApi())),
      );
      await tester.pumpAndSettle();

      await gotoStep(tester, '孩子档案');
      await tester.pumpAndSettle();
      expect(find.text('澄澄'), findsWidgets);

      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();
      expect(find.text('素材'), findsOneWidget);
    },
  );

  testWidgets('desktop shell initializes the schema before loading dataset', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _MultiChildSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    expect(api.calls, contains('POST /schema/init'));
    expect(
      api.calls.indexOf('POST /schema/init'),
      lessThan(api.calls.indexOf('GET /children')),
    );
  });

  test('startup gate keeps setup active when schema initialization fails', () {
    expect(
      resolveStartupConfigurationStep(
        needsConfiguration: true,
        wasRequired: true,
        currentStep: AppStep.child,
        selectedChildId: null,
      ),
      AppStep.setup,
    );
  });

  testWidgets('sample dataset import shows success feedback', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SampleFlowSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await openSampleFromHome(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('导入示例数据集'));
    await tester.pumpAndSettle();

    expect(find.text('示例数据已导入'), findsOneWidget);
  });

  testWidgets('imported sample dataset exposes follow-up actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SampleFlowSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await openSampleFromHome(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('导入示例数据集'));
    await tester.pumpAndSettle();

    expect(find.text('示例数据已导入'), findsOneWidget);
    expect(find.text('你可以继续浏览示例素材，或体验生成流程。'), findsOneWidget);
    expect(find.text('浏览示例素材'), findsOneWidget);
    expect(find.text('生成示例绘本'), findsOneWidget);
    expect(find.text('查看示例 PDF'), findsOneWidget);
    expect(find.text('重置数据'), findsOneWidget);
    expect(find.text('已导入示例数据集'), findsNothing);

    await tester.tap(find.text('浏览示例素材'));
    await tester.pumpAndSettle();

    expect(find.text('素材库'), findsWidgets);
    expect(find.text('阳光花园'), findsWidgets);
  });

  testWidgets('sample dataset reset asks for confirmation before resetting', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SampleFlowSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await openSampleFromHome(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('导入示例数据集'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('重置数据'));
    await tester.tap(find.text('重置数据'));
    await tester.pumpAndSettle();

    expect(find.text('确定要重置示例数据吗？'), findsOneWidget);
    expect(api.resetSampleCalls, 0);

    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('取消')),
    );
    await tester.pumpAndSettle();
    expect(api.resetSampleCalls, 0);

    await tester.ensureVisible(find.text('重置数据'));
    await tester.tap(find.text('重置数据'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('重置数据'),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.resetSampleCalls, 1);
  });

  testWidgets('sample dataset import reports empty sidecar response', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: DesktopShell(api: _SampleImportFailureApi())),
    );
    await tester.pumpAndSettle();

    await openSampleFromHome(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('导入示例数据集'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('导入失败'), findsOneWidget);
  });
}

String _taskIdFromTaskRoute(String path) {
  final parts = path.split('/');
  final index = parts.indexOf('tasks');
  if (index >= 0 && index + 1 < parts.length) {
    return Uri.decodeComponent(parts[index + 1]);
  }
  return '';
}

class _FakeSidecarApi extends SidecarApi {
  Map<String, dynamic>? lastExportBody;
  String? lastTaskId;
  Map<String, dynamic>? lastGenerateBody;
  Map<String, dynamic>? lastTaskBody;
  Map<String, dynamic>? lastPathBody;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '/tmp/kidmemory-exports'},
      };
    }
    if (path == '/api/config/agent-configs/default') {
      return {
        'id': 'agent-config-default',
        'name': 'Default Agent',
        'provider': 'custom',
        'model': 'mimo-v2-pro',
        'baseUrl': 'https://api.xiaomimimo.com/v1',
        'apiKeyConfigured': true,
        'temperature': 0.7,
        'maxTokens': 4096,
        'toolsEnabled': <String>[],
        'workspaceConfig': <String, dynamic>{},
        'isDefault': true,
        'isActive': true,
        'createdAt': '2026-05-20T00:00:00.000Z',
        'updatedAt': '2026-05-20T00:00:00.000Z',
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
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/api/config/agent-configs/agent-config-default/test') {
      return {
        'success': true,
        'responseTime': 42,
        'modelUsed': 'mimo-v2-pro',
      };
    }
    if (path.startsWith('/config/check/')) {
      return {'ok': true};
    }
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      return {
        'taskId': 'task_123456',
        'creationType': body['creationType'] ?? 'storybook',
        'summary': 'Create a PDF from selected assets',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testStructuredPlanRequirements,
        'requirementItems': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId.isEmpty ? 'task_123456' : taskId;
      lastGenerateBody = {...body, 'taskId': lastTaskId};
      return {
        'taskId': lastTaskId,
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'publish',
        'steps': const <Map<String, dynamic>>[],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/export')) {
      lastExportBody = body;
      return {
        'artifactId': 'artifact-task-pdf',
        'kind': body['target'] ?? 'pdf',
        'taskId': lastTaskId,
        'localPath': body['targetPath'],
      };
    }
    return {'ok': true};
  }
}

class _SlowCreationSidecarApi extends _FakeSidecarApi {
  final planCompleter = Completer<Map<String, dynamic>>();
  final jobCompleter = Completer<Map<String, dynamic>>();

  void completePlan() {
    if (!planCompleter.isCompleted) {
      planCompleter.complete({
        'taskId': 'task_slow',
        'creationType': 'storybook',
        'summary': 'Slow creation plan is ready',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testPlanRequirements,
      });
    }
  }

  void completeJob() {
    if (!jobCompleter.isCompleted) {
      lastTaskId = 'task_slow';
      jobCompleter.complete({
        'taskId': lastTaskId,
        'taskId': lastGenerateBody?['taskId'],
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'publish',
        'steps': const <Map<String, dynamic>>[],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      });
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      return planCompleter.future;
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId;
      lastGenerateBody = {...body, 'taskId': taskId};
      return jobCompleter.future;
    }
    return super.post(path, body);
  }
}

class _PlanFailureSidecarApi extends _FakeSidecarApi {
  int taskAttempts = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      taskAttempts += 1;
      lastTaskBody = body;
      throw const SidecarApiException('计划失败：规划服务暂时不可用');
    }
    return super.post(path, body);
  }
}

class _FailedCreationJobSidecarApi extends _FakeSidecarApi {
  int taskAttempts = 0;
  int generateAttempts = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      taskAttempts += 1;
      lastTaskBody = body;
      return {
        'taskId': 'task_failed_$taskAttempts',
        'creationType': body['creationType'] ?? 'storybook',
        'summary': 'Create a PDF from selected assets',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      generateAttempts += 1;
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId.isEmpty ? 'task_failed_$generateAttempts' : taskId;
      lastGenerateBody = {...body, 'taskId': lastTaskId};
      return {
        'taskId': lastTaskId,
        'creationType': 'storybook',
        'status': 'failed',
        'currentStepId': 'generate',
        'steps': const <Map<String, dynamic>>[
          {
            'stepId': 'compose',
            'label': 'Compose selected assets',
            'status': 'succeeded',
          },
          {
            'stepId': 'plan',
            'label': 'Confirm persisted agent plan',
            'status': 'succeeded',
          },
          {
            'stepId': 'generate',
            'label': 'Generate PDF draft',
            'status': 'failed',
            'detail': 'Skill runtime crashed',
          },
        ],
        'artifacts': const <Map<String, dynamic>>[],
        'error': const {
          'category': 'skill',
          'message': 'Skill runtime crashed',
          'stepId': 'generate',
          'code': 'E_SKILL_RUNTIME',
        },
      };
    }
    return super.post(path, body);
  }
}

class _FailedMemoirVideoCreationJobSidecarApi extends _FakeSidecarApi {
  int taskAttempts = 0;
  int generateAttempts = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      taskAttempts += 1;
      lastTaskBody = body;
      return {
        'taskId': 'task_video_failed_$taskAttempts',
        'creationType': body['creationType'] ?? 'memoir_video',
        'summary': 'Create a memory video from selected assets',
        'skillName': 'KidMemory Hyperframes memoir video',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'pending'},
          {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'pending'},
        ],
        'requirements': const [
          {'label': 'Hyperframes runtime', 'required': true},
          {'label': 'FFmpeg available or auto-repaired', 'required': true},
        ],
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      generateAttempts += 1;
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId.isEmpty ? 'task_video_failed_$generateAttempts' : taskId;
      lastGenerateBody = {...body, 'taskId': lastTaskId};
      return {
        'taskId': lastTaskId,
        'creationType': 'memoir_video',
        'status': 'failed',
        'currentStepId': 'generate',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'succeeded'},
          {
            'stepId': 'generate',
            'label': '生成 MP4 视频',
            'status': 'failed',
            'detail': 'Hyperframes render exited before writing MP4',
          },
        ],
        'artifacts': const <Map<String, dynamic>>[],
        'error': const {
          'category': 'hyperframes',
          'message': 'Hyperframes 未能成功生成 MP4。',
          'stepId': 'generate',
          'code': 'E_HYPERFRAMES_RENDER',
        },
      };
    }
    return super.post(path, body);
  }
}

class _SuccessfulMemoirVideoCreationJobSidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      return {
        'taskId': 'task_video_success',
        'creationType': body['creationType'] ?? 'memoir_video',
        'summary': 'Create a memory video from selected assets',
        'skillName': 'KidMemory Hyperframes memoir video',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'pending'},
          {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'pending'},
        ],
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId.isEmpty ? 'task_video_success' : taskId;
      lastGenerateBody = {...body, 'taskId': lastTaskId};
      return {
        'taskId': lastTaskId,
        'creationType': 'memoir_video',
        'status': 'succeeded',
        'currentStepId': 'review',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'succeeded'},
          {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'succeeded'},
          {'stepId': 'review', 'label': '视频预览', 'status': 'succeeded'},
        ],
        'artifacts': const <Map<String, dynamic>>[
          {
            'artifactId': 'artifact-video-success',
            'kind': 'mp4',
            'localPath': '/tmp/kidmemory-exports/task_video_success.mp4',
          },
        ],
        'error': null,
      };
    }
    return super.post(path, body);
  }
}

class _SlowMemoirVideoCreationJobSidecarApi extends _FakeSidecarApi {
  final jobCompleter = Completer<Map<String, dynamic>>();

  void completeJob() {
    if (jobCompleter.isCompleted) return;
    jobCompleter.complete({
      'taskId': lastGenerateBody?['taskId'] ?? 'task_video_slow',
      'creationType': 'memoir_video',
      'status': 'succeeded',
      'currentStepId': 'review',
      'steps': const <Map<String, dynamic>>[
        {'stepId': 'compose', 'label': '准备视频素材', 'status': 'succeeded'},
        {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'succeeded'},
        {'stepId': 'review', 'label': '视频预览', 'status': 'succeeded'},
      ],
      'artifacts': const <Map<String, dynamic>>[
        {
          'artifactId': 'artifact-video-slow',
          'kind': 'mp4',
          'localPath': '/tmp/kidmemory-exports/task_video_slow.mp4',
        },
      ],
      'error': null,
    });
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      return {
        'taskId': 'task_video_slow',
        'creationType': body['creationType'] ?? 'memoir_video',
        'summary': 'Create a memory video from selected assets',
        'skillName': 'KidMemory Hyperframes memoir video',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'pending'},
          {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'pending'},
        ],
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId;
      lastGenerateBody = {...body, 'taskId': taskId};
      return jobCompleter.future;
    }
    return super.post(path, body);
  }
}

class _RunningCreationSidecarApi extends _FakeSidecarApi {
  int pollCount = 0;

  Map<String, dynamic> runningJob({String detail = 'Running skill workspace'}) {
    return {
      'taskId': lastGenerateBody?['taskId'] ?? 'task_polling',
      'creationType': 'storybook',
      'status': 'running',
      'currentStepId': 'generate',
      'steps': [
        const {
          'stepId': 'compose',
          'label': 'Compose selected assets',
          'status': 'succeeded',
        },
        const {
          'stepId': 'plan',
          'label': 'Confirm persisted agent plan',
          'status': 'succeeded',
        },
        {
          'stepId': 'generate',
          'label': 'Generate PDF draft',
          'status': 'running',
          'detail': detail,
        },
      ],
      'artifacts': const <Map<String, dynamic>>[],
      'error': null,
    };
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      lastGenerateBody = body;
      lastTaskId = 'task_polling';
      return runningJob();
    }
    return super.post(path, body);
  }

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/creation/tasks/task_polling') {
      pollCount += 1;
      return runningJob(detail: 'Still generating');
    }
    return super.get(path);
  }
}

class _PollingCreationSidecarApi extends _RunningCreationSidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/creation/tasks/task_polling') {
      pollCount += 1;
      return {
        'taskId': lastGenerateBody?['taskId'] ?? 'task_polling',
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'review',
        'steps': const <Map<String, dynamic>>[
          {
            'stepId': 'compose',
            'label': 'Compose selected assets',
            'status': 'succeeded',
          },
          {
            'stepId': 'generate',
            'label': 'Generate PDF draft',
            'status': 'succeeded',
            'detail': 'Draft generated',
          },
          {
            'stepId': 'review',
            'label': 'Validate final artifact',
            'status': 'succeeded',
            'detail': 'Ready for review',
          },
        ],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      };
    }
    return super.get(path);
  }
}

class _SequencedPlanSidecarApi extends _FakeSidecarApi {
  int _nextPlanNumber = 1;
  final createdTaskIds = <String>[];
  final generatedTaskIds = <String>[];

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      final nextTaskId = 'task_${_nextPlanNumber++}';
      createdTaskIds.add(nextTaskId);
      return {
        'taskId': nextTaskId,
        'creationType': body['creationType'] ?? 'storybook',
        'summary': 'Create a PDF from selected assets',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId;
      lastGenerateBody = {...body, 'taskId': taskId};
      generatedTaskIds.add(taskId);
      return {
        'taskId': taskId,
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'publish',
        'steps': const <Map<String, dynamic>>[],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      };
    }
    return super.post(path, body);
  }
}

class _SlowExportSidecarApi extends _FakeSidecarApi {
  final exportCompleter = Completer<Map<String, dynamic>>();

  void completeExport() {
    if (!exportCompleter.isCompleted) {
      exportCompleter.complete({
        'artifactId': 'artifact-task-pdf',
        'kind': lastExportBody?['target'] ?? 'pdf',
        'taskId': lastTaskId,
        'localPath': lastExportBody?['targetPath'],
      });
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/export')) {
      lastExportBody = body;
      return exportCompleter.future;
    }
    return super.post(path, body);
  }
}

class _FailingExportSidecarApi extends _FakeSidecarApi {
  int exportRequests = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/export')) {
      exportRequests += 1;
      lastExportBody = body;
      throw const SidecarApiException('导出服务暂时不可用');
    }
    return super.post(path, body);
  }
}

class _SlowShareSidecarApi extends _FakeSidecarApi {
  final shareCompleter = Completer<Map<String, dynamic>>();
  Map<String, dynamic>? lastShareBody;
  int shareRequests = 0;

  void completeShare() {
    if (!shareCompleter.isCompleted) {
      shareCompleter.complete({
        'shareId': 'share_task_123456',
        'shareUrl': 'http://localhost:3001/share/share_task_123456',
        'artifactId': lastShareBody?['artifactId'],
      });
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/share')) {
      shareRequests += 1;
      lastShareBody = body;
      return shareCompleter.future;
    }
    return super.post(path, body);
  }
}

class _FailingShareSidecarApi extends _FakeSidecarApi {
  Map<String, dynamic>? lastShareBody;
  int shareRequests = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/share')) {
      shareRequests += 1;
      lastShareBody = body;
      throw const SidecarApiException('分享服务暂时不可用');
    }
    return super.post(path, body);
  }
}

class _SampleFlowSidecarApi extends _FakeSidecarApi {
  bool sampleImported = false;
  int resetSampleCalls = 0;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/children') {
      return {
        'children': [
          {'id': 'child-1', 'name': '澄澄'},
          if (sampleImported) {'id': 'sample-child-001', 'name': '小朋友'},
        ],
      };
    }
    if (path.startsWith('/assets')) {
      return {
        'assets': [
          {
            'id': sampleImported ? 'sample-asset-1' : 'asset-dino-world',
            'title': sampleImported ? '阳光花园' : '恐龙世界',
            'type': 'artwork',
            'description': sampleImported ? '示例素材库' : '描述',
            'tags': [sampleImported ? '示例' : '恐龙'],
            'capturedAt': '2026-05-12',
          },
        ],
      };
    }
    return super.get(path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/sample/import') {
      sampleImported = true;
      return {'ok': true, 'childId': 'sample-child-001', 'assetCount': 1};
    }
    if (path == '/sample/reset') {
      resetSampleCalls += 1;
      sampleImported = false;
      return {'ok': true, 'deletedAssets': 1};
    }
    return super.post(path, body);
  }
}

class _CoverFailureSidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      throw const SidecarApiException('封面图生成失败：免费生图服务暂时不可用');
    }
    return super.post(path, body);
  }
}

class _SupabaseStorageSidecarApi extends _FakeSidecarApi {
  _SupabaseStorageSidecarApi({this.failStorageTest = false});

  final bool failStorageTest;
  Map<String, dynamic>? lastLongImageExportBody;
  Map<String, dynamic>? lastStorageConfigBody;
  final storageSyncArtifactIds = <String>[];
  int storageWorkerRuns = 0;
  int storageTestCalls = 0;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '/tmp/kidmemory-exports'},
        'supabaseStorage': {
          'provider': 'supabase',
          'url': 'https://project.supabase.co',
          'bucket': 'kidmemory-exports',
          'serviceRoleKeyConfigured': true,
          'serviceRoleKey': 'secret-service-role',
          'publicBaseUrl': '',
          'signedUrlTtlSeconds': 3600,
          's3': {
            'endpoint': 'https://project.supabase.co/storage/v1/s3',
            'region': 'auto',
            'accessKeyIdConfigured': false,
            'secretAccessKeyConfigured': false,
            'configured': false,
          },
          'configured': true,
          'authMode': 'rest',
        },
      };
    }
    if (path == '/storage/export-artifacts/artifact-task-jpg/share') {
      return {
        'ok': true,
        'url': 'https://project.supabase.co/signed/task_123456.jpg',
        'expiresInSeconds': 3600,
        'text':
            'KidMemory 作品集：https://project.supabase.co/signed/task_123456.jpg\n链接有效期：3600 秒',
      };
    }
    return super.get(path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/config/supabase-storage') {
      lastStorageConfigBody = body;
      return {
        'ok': true,
        'config': {
          'provider': 'supabase',
          'url': body['url'] ?? 'https://project.supabase.co',
          'bucket': body['bucket'] ?? 'kidmemory-exports',
          'serviceRoleKeyConfigured': body['serviceRoleKey'] != null,
          'publicBaseUrl': body['publicBaseUrl'] ?? '',
          'signedUrlTtlSeconds': body['signedUrlTtlSeconds'] ?? 3600,
          'configured': true,
          'authMode': body['serviceRoleKey'] != null ? 'rest' : 's3',
          's3CredentialsDetected': true,
          's3': {
            'endpoint':
                body['s3Endpoint'] ??
                'https://project-ref.storage.supabase.co/storage/v1/s3',
            'region': body['s3Region'] ?? 'auto',
            'accessKeyIdConfigured': body['s3AccessKeyId'] != null,
            'secretAccessKeyConfigured': body['s3SecretAccessKey'] != null,
            'configured': true,
          },
        },
      };
    }
    if (path == '/config/supabase-storage/test') {
      storageTestCalls += 1;
      if (failStorageTest) {
        return {
          'ok': false,
          'message': '云端分享连接不可用',
          'cleanup': {'ok': true},
        };
      }
      return {
        'ok': true,
        'message': '测试通过',
        'cleanup': {'ok': true},
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/export')) {
      lastLongImageExportBody = body;
      return {
        'artifactId': 'artifact-task-jpg',
        'taskId': lastTaskId,
        'kind': body['target'] ?? 'long_image_jpg',
        'localPath': body['targetPath'],
        'storageProvider': 'local',
        'storageStatus': 'local_only',
      };
    }
    if (path == '/storage/export-artifacts/artifact-task-jpg/sync') {
      storageSyncArtifactIds.add('artifact-task-jpg');
      return {
        'enqueued': true,
        'targetId': 'artifact-task-jpg',
        'status': 'pending',
      };
    }
    if (path == '/storage/sync/run') {
      storageWorkerRuns += 1;
      return {
        'processed': 1,
        'succeeded': 1,
        'retried': 0,
        'failed': 0,
        'skipped': 0,
      };
    }
    return super.post(path, body);
  }
}

class _RelativePathSidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '.kidmemory/exports'},
      };
    }
    return super.get(path);
  }
}

// ignore: unused_element
class _IncompleteSupabaseS3SidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'supabaseStorage': {
          'provider': 'supabase',
          'url': '',
          'bucket': '',
          'serviceRoleKeyConfigured': false,
          'publicBaseUrl': '',
          'signedUrlTtlSeconds': 3600,
          'configured': false,
          'authMode': 'none',
          's3CredentialsDetected': true,
          's3': {
            'endpoint': '',
            'region': 'auto',
            'accessKeyIdConfigured': true,
            'secretAccessKeyConfigured': true,
            'configured': false,
          },
          'diagnosticMessage':
              '检测到 Supabase S3 凭据。S3 模式还需要 SUPABASE_S3_ENDPOINT 和 SUPABASE_STORAGE_BUCKET（或 SUPABASE_S3_BUCKET）；region 默认 auto，可用 SUPABASE_S3_REGION 覆盖。',
          'legacySecret': 'legacy-secret-key',
        },
      };
    }
    return super.get(path);
  }
}

class _UnconfiguredSidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'openai': {'baseUrl': '', 'model': '', 'apiKeyConfigured': false},
      };
    }
    if (path == '/api/config/agent-configs/default') {
      return {};
    }
    return super.get(path);
  }
}

// ignore: unused_element
class _SchemaInitFailureApi extends _FakeSidecarApi {
  bool datasetLoaded = false;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/children' || path.startsWith('/assets')) {
      datasetLoaded = true;
    }
    return super.get(path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/schema/init') {
      return {
        'ok': false,
        'service': 'schema',
        'message': 'Schema initialization failed',
      };
    }
    return super.post(path, body);
  }
}

// ignore: unused_element
class _ToggleReadySidecarApi extends SidecarApi {
  bool ready = false;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '/tmp/kidmemory-exports'},
      };
    }
    if (path == '/children') return {'children': []};
    if (path.startsWith('/assets')) return {'assets': []};
    if (path == '/config/ui') {
      return {
        'setup': {
          'checks': [
            {
              'index': '1',
              'title': 'PostgreSQL 配置',
              'purpose': '为 KidMemory 提供核心数据库连接，保存孩子资料、素材和生成历史。',
              'body': '为 KidMemory 提供核心数据库连接，保存孩子资料、素材和生成历史。',
              'action': '配置',
              'state': '待检测',
            },
            {
              'index': '2',
              'title': 'pgvector 检测',
              'purpose': 'pgvector 是 PostgreSQL 的独立扩展，用于语义检索与相似素材匹配。',
              'body': 'pgvector 是 PostgreSQL 的独立扩展，需单独安装并在数据库中启用。',
              'action': '检测 pgvector',
              'state': '待检测',
            },
            {
              'index': '3',
              'title': '大模型接口配置',
              'purpose': '提供文本生成、讲故事和提示词能力。',
              'body': '提供文本生成、讲故事和提示词能力。',
              'action': '配置',
              'state': '待检测',
            },
            {
              'index': '4',
              'title': '本地数据目录',
              'purpose': '统一管理向量索引、元数据缓存和导出文件。',
              'body':
                  '统一管理向量索引、元数据缓存和导出文件。\n数据目录：.kidmemory/data\nWorkspace：.kidmemory/workspace\n导出目录：.kidmemory/exports',
              'action': '配置目录',
              'state': '已配置',
              'ok': true,
            },
          ],
        },
        'search': {
          'typeOptions': [
            {'value': 'all', 'label': '全部'},
          ],
        },
        'assetLibrary': {
          'typeOptions': [
            {'value': 'all', 'label': '全部'},
          ],
        },
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
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/schema/init') {
      return {
        'ok': ready,
        'service': 'schema',
        'message': ready
            ? 'Schema initialized'
            : 'Schema initialization pending',
      };
    }
    if (path.startsWith('/config/check/')) {
      return {'ok': true};
    }
    return {'ok': true};
  }
}

class _DisconnectedSidecarApi extends SidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async => {};

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    return {};
  }
}

// ignore: unused_element
class _PathConfigSidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      final paths = lastPathBody == null
          ? null
          : {
              'paths': lastPathBody,
              'postgres': {
                'host': 'localhost',
                'port': 5432,
                'database': 'kidmemory',
                'user': 'postgres',
              },
              'openai': {
                'baseUrl': '',
                'model': '',
                'apiKeyConfigured': true,
                'apiKey': 'fake',
              },
            };
      return paths == null
          ? super.get('/config/status')
          : {
              'ok': true,
              'paths': paths['paths'],
              'postgres': paths['postgres'],
              'openai': paths['openai'],
            };
    }
    return super.get(path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/config/paths') {
      lastPathBody = body;
      return {'ok': true, 'paths': body};
    }
    return super.post(path, body);
  }
}

class _NoChildrenSidecarApi extends SidecarApi {
  final children = <Map<String, String>>[];
  String? lastChildrenName;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') return {'ok': true};
    if (path == '/children') return {'children': children};
    if (path.startsWith('/assets')) return {'assets': []};
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/config/check/') || path == '/schema/init') {
      return {'ok': true};
    }
    if (path == '/children') {
      final child = {'id': '${body['id']}', 'name': '${body['name']}'};
      children.add(child);
      lastChildrenName = child['name'];
      return {'child': child};
    }
    return {'ok': true};
  }
}

class _SampleImportFailureApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/sample/import') return {};
    return super.post(path, body);
  }
}

class _MergedSearchSidecarApi extends _FakeSidecarApi {
  Map<String, dynamic>? lastSearchBody;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path.startsWith('/search/indexing-status')) {
      return {
        'pending': 1,
        'running': 1,
        'retryWait': 0,
        'failed': 0,
        'searchable': 24,
      };
    }
    return super.get(path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/search/query') {
      lastSearchBody = body;
      return {
        'total': 1,
        'items': [
          {
            'asset': {
              'id': 'asset-sun',
              'title': '太阳画',
              'type': 'artwork',
              'description': '画了太阳和户外花朵',
              'tags': ['太阳', '户外'],
              'capturedAt': '2026-05-12',
              'previewUrl': 'http://127.0.0.1:4317/assets/asset-sun/preview',
            },
            'reasons': ['标签匹配：太阳 / 户外'],
          },
        ],
      };
    }
    return super.post(path, body);
  }
}

class _MultiChildSidecarApi extends SidecarApi {
  Map<String, dynamic>? lastGenerateBody;
  final deletedAssetIds = <String>[];
  final calls = <String>[];
  String? lastChildrenName;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    calls.add('GET $path');
    if (path == '/config/status') return {'ok': true};
    if (path == '/children') {
      return {
        'children': [
          {'id': 'child-1', 'name': '澄澄'},
          {'id': 'child-2', 'name': '甜甜'},
        ],
      };
    }
    if (path == '/assets?childId=child-2') {
      return {
        'assets': [
          {
            'id': 'asset-child-2',
            'title': '甜甜的画',
            'type': 'artwork',
            'description': '描述',
            'tags': ['甜甜'],
            'capturedAt': '2026-05-12',
          },
        ],
      };
    }
    if (path.startsWith('/assets')) {
      return {
        'assets': [
          {
            'id': 'asset-dino-world',
            'title': '澄澄的画',
            'type': 'artwork',
            'description': '描述',
            'tags': ['澄澄'],
            'capturedAt': '2026-05-12',
          },
        ],
      };
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    calls.add('POST $path');
    if (path.startsWith('/config/check/')) {
      return {'ok': true};
    }
    if (path == '/schema/init') {
      return {'ok': true};
    }
    if (path == '/children') {
      lastChildrenName = '${body['name']}';
      return {
        'child': {'id': body['id'], 'name': body['name'], 'metadata': {}},
      };
    }
    if (path == '/creation/tasks') {
      lastGenerateBody = {
        ...body,
        if (!body.containsKey('settings'))
          'settings': {'childId': 'child-2'},
      };
      return {
        'taskId': 'task_123456',
        'creationType': body['creationType'] ?? 'storybook',
        'summary': 'Create a PDF from selected assets',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      return {
        'taskId': 'task_123456',
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'publish',
        'steps': const <Map<String, dynamic>>[],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      };
    }
    return {'ok': true};
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    calls.add('PATCH $path');
    if (path.startsWith('/children/')) {
      lastChildrenName = '${body['name']}';
      return {
        'child': {
          'id': path.split('/').last,
          'name': body['name'],
          'birthday': body['birthday'],
          'notes': body['notes'],
        },
      };
    }
    return {'ok': true};
  }

  @override
  Future<Map<String, dynamic>> delete(String path) async {
    calls.add('DELETE $path');
    deletedAssetIds.add(path.split('/').last);
    return {'ok': true};
  }
}
