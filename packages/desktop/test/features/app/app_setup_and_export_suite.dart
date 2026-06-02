part of 'app_test.dart';

void appSetupAndExportSuite() {
  testWidgets(
    'setup page shows disconnected sidecar state with local defaults',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        localizedTestApp(home: DesktopShell(api: _DisconnectedSidecarApi())),
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
      localizedTestApp(home: DesktopShell(api: _FakeSidecarApi())),
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
    'setup local data directory actions stay clickable when OpenAI is not configured',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _UnconfiguredSidecarApi();
      final openedTargets = <String>[];
      await tester.pumpWidget(
        localizedTestApp(
          home: DesktopShell(
            api: api,
            pickDataDirectoryPath: () async => '/tmp/kidmemory-selected-root',
            openExternalTarget: (target) async {
              openedTargets.add(target);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await gotoStep(tester, '设置');
      await tester.pumpAndSettle();

      await tester.ensureVisible(secondaryButton('打开目录').last);
      await tester.tap(secondaryButton('打开目录').last);
      await tester.pumpAndSettle();

      expect(openedTargets, contains(contains('KidMemory/data')));

      await tester.ensureVisible(secondaryButton('配置目录').last);
      await tester.tap(secondaryButton('配置目录').last);
      await tester.pumpAndSettle();

      expect(api.lastPathBody?['dataDir'], '/tmp/kidmemory-selected-root/data');
      expect(
        api.lastPathBody?['workspaceDir'],
        '/tmp/kidmemory-selected-root/workspace',
      );
      expect(
        api.lastPathBody?['exportDir'],
        '/tmp/kidmemory-selected-root/exports',
      );
    },
  );

  testWidgets(
    'setup page manages Supabase Storage without exposing service role key',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _SupabaseStorageSidecarApi();
      await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
        localizedTestApp(
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
      expect(find.text('存储服务商'), findsOneWidget);
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

  testWidgets('setup page can configure COS object storage provider', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SupabaseStorageSidecarApi();
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    final providerDropdown = find.descendant(
      of: dialog,
      matching: find.byType(DropdownButtonFormField<String>),
    );
    expect(providerDropdown, findsOneWidget);

    await tester.tap(providerDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('腾讯云 COS').last);
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: dialog,
      matching: find.byType(TextField),
    );
    expect(fields, findsNWidgets(5));
    expect(find.text('REST 方式（可选）'), findsNothing);

    await tester.enterText(
      fields.at(0),
      'https://cos.ap-guangzhou.myqcloud.com',
    );
    await tester.enterText(fields.at(1), 'ap-guangzhou');
    await tester.enterText(fields.at(2), 'counter-1252496948');
    await tester.enterText(fields.at(3), 'cos-secret-id');
    await tester.enterText(fields.at(4), 'cos-secret-key');

    await tester.tap(find.descendant(of: dialog, matching: find.text('保存')));
    await tester.pumpAndSettle();

    expect(api.lastStorageConfigBody?['provider'], 'cos');
    expect(
      api.lastStorageConfigBody?['s3Endpoint'],
      'https://cos.ap-guangzhou.myqcloud.com',
    );
    expect(api.lastStorageConfigBody?['s3Region'], 'ap-guangzhou');
    expect(api.lastStorageConfigBody?['bucket'], 'counter-1252496948');
    expect(api.lastStorageConfigBody?['s3AccessKeyId'], 'cos-secret-id');
    expect(api.lastStorageConfigBody?['s3SecretAccessKey'], 'cos-secret-key');
  });

  testWidgets(
    'export flow uses configured export directory before calling sidecar export',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _FakeSidecarApi();

      await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

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

  testWidgets(
    'export flow supports JPG long image sync and private share copy',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _SupabaseStorageSidecarApi();
      String? copiedText;
      await tester.pumpWidget(
        localizedTestApp(
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

      await generateStorybookFromPrimary(tester);
      final exportTargetDropdown = find
          .byType(DropdownButtonFormField<String>)
          .last;
      await tester.ensureVisible(exportTargetDropdown);
      await tester.tap(exportTargetDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('长图 JPG').last);
      await tester.pumpAndSettle();
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
      expect(copiedText, isNotNull);
      expect(copiedText, isNot(equals('')));
    },
  );

  testWidgets('export flow exposes exporting phase while sidecar export runs', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SlowExportSidecarApi();
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

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
      await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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

      expect(
        api.lastExportBody?['targetPath'],
        '$expectedRoot/task_123456.pdf',
      );
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

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
      localizedTestApp(
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('生成回忆视频'));
    await tester.tap(find.text('生成回忆视频'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(primaryButton('开始规划'));
    await tester.tap(primaryButton('开始规划'));
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
    await tester.ensureVisible(primaryButton('开始规划'));
    await tester.tap(primaryButton('开始规划'));
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
}
