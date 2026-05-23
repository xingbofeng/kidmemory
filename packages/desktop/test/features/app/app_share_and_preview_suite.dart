part of 'app_test.dart';

void appShareAndPreviewSuite() {
  testWidgets('pdf share flow confirms before creating a web share link', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SlowShareSidecarApi();
    final openedTargets = <String>[];
    await tester.pumpWidget(
      localizedTestApp(
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

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
      localizedTestApp(home: DesktopShell(api: _FakeSidecarApi())),
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
      localizedTestApp(
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
      localizedTestApp(
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
}
