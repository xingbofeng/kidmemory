part of 'app_test.dart';

void appNavigationSuite() {
  testWidgets('desktop flow starts on child profile and exposes setup later', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(home: DesktopShell(api: _FakeSidecarApi())),
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
      localizedTestApp(home: DesktopShell(api: _FakeSidecarApi())),
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
      await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
      await tester.pumpAndSettle();

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      expect(find.text('生成儿童绘本'), findsWidgets);
      expect(find.text('生成成长纪念册'), findsOneWidget);
      expect(find.text('生成回忆视频'), findsOneWidget);

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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('生成回忆视频'));
    await tester.tap(find.text('生成回忆视频'));
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
      await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
      await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
        localizedTestApp(home: DesktopShell(api: _UnconfiguredSidecarApi())),
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
      localizedTestApp(home: DesktopShell(api: _FakeSidecarApi())),
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
      await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
}
