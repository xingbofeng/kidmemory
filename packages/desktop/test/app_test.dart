import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/app/desktop_shell.dart';
import 'package:kidmemory_desktop/core/sidecar/sidecar_api.dart';
import 'package:kidmemory_desktop/shared/widgets/chrome.dart';
import 'package:kidmemory_desktop/shared/widgets/content.dart';
import 'package:kidmemory_desktop/shared/widgets/layout.dart';

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

    await gotoStep(tester, '示例数据集');
    await tester.pumpAndSettle();
    expect(find.text('示例数据集'), findsWidgets);
    expect(find.text('使用隐私安全的虚拟数据集'), findsOneWidget);
    expect(find.text('导入示例数据集'), findsOneWidget);

    await gotoStep(tester, '孩子档案');
    await tester.pumpAndSettle();
    expect(find.text('成长统计'), findsOneWidget);

    await gotoStep(tester, '素材库');
    await tester.pumpAndSettle();
    expect(find.text('恐龙世界'), findsWidgets);

    await gotoStep(tester, '生成 / 预览');
    await tester.pumpAndSettle();
    expect(primaryButton('开始生成'), findsOneWidget);
    expect(find.text('任务日志'), findsOneWidget);
  });

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

      await tester.tap(find.byType(AssetCard).first);
      await tester.pumpAndSettle();
      await gotoStep(tester, '生成 / 预览');
      await tester.pumpAndSettle();

      expect(find.text('已选择素材（1）'), findsOneWidget);
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
    await tester.enterText(find.byType(TextField), '安安');
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

      expect(find.text('OpenAI-compatible API'), findsOneWidget);
      expect(find.textContaining('OPENAI_API_KEY'), findsOneWidget);
      expect(find.textContaining('未连接'), findsWidgets);
      expect(find.text('本地数据目录'), findsWidgets);
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

    expect(find.text('Claude Agent SDK'), findsNothing);
    expect(find.textContaining('初始化成功'), findsWidgets);
    expect(find.text('正在安装...'), findsNothing);
    expect(find.text('配置目录'), findsOneWidget);
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

      expect(find.text('Supabase Storage'), findsOneWidget);
      expect(find.text('Bucket：kidmemory-exports'), findsOneWidget);
      expect(find.textContaining('Service Role Key：已配置'), findsOneWidget);
      expect(find.textContaining('secret-service-role'), findsNothing);

      await tester.ensureVisible(secondaryButton('测试连接'));
      await tester.tap(secondaryButton('测试连接'));
      await tester.pumpAndSettle();

      expect(api.storageTestCalls, 1);
      expect(find.textContaining('测试通过'), findsWidgets);
    },
  );

  testWidgets(
    'setup page configures Supabase S3 fields and toggles secret visibility',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _SupabaseStorageSidecarApi();
      await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
      await tester.pumpAndSettle();
      await gotoStep(tester, '设置');
      await tester.pumpAndSettle();

      final configureButton = find.byWidgetPredicate(
        (widget) => widget is SecondaryButton && widget.label == '配置存储',
      );
      await tester.ensureVisible(configureButton.first);
      await tester.tap(configureButton.first);
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      final fields = find.descendant(
        of: dialog,
        matching: find.byType(TextField),
      );
      expect(fields, findsNWidgets(9));
      expect(find.textContaining('推荐先用 S3 模式'), findsOneWidget);

      final s3AccessField = fields.at(3);
      final s3SecretField = fields.at(4);
      expect(tester.widget<TextField>(s3AccessField).obscureText, isTrue);
      expect(tester.widget<TextField>(s3SecretField).obscureText, isTrue);

      final s3AccessToggle = find.descendant(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'SUPABASE_S3_ACCESS_KEY_ID',
        ),
        matching: find.byIcon(Icons.visibility_outlined),
      );
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
    },
  );

  testWidgets(
    'setup page explains incomplete Supabase S3 env vars without leaking secrets',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: DesktopShell(api: _IncompleteSupabaseS3SidecarApi())),
      );
      await tester.pumpAndSettle();
      await gotoStep(tester, '设置');
      await tester.pumpAndSettle();

      expect(find.textContaining('检测到 Supabase S3 凭据'), findsOneWidget);
      expect(find.textContaining('SUPABASE_S3_ENDPOINT'), findsOneWidget);
      expect(find.textContaining('legacy-secret-key'), findsNothing);
    },
  );

  testWidgets('setup data directory picker updates local paths', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _PathConfigSidecarApi();
    var pickerCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          api: api,
          pickDataDirectoryPath: () async {
            pickerCalled = true;
            return '/tmp/kidmemory-local';
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await gotoStep(tester, '设置');
    await tester.pumpAndSettle();

    final configureDirectoryButton = find.byWidgetPredicate(
      (widget) => widget is SecondaryButton && widget.label == '配置目录',
    );
    await tester.tap(configureDirectoryButton.first);
    await tester.pumpAndSettle();

    expect(pickerCalled, isTrue);
    expect(api.lastPathBody?['dataDir'], '/tmp/kidmemory-local/data');
    expect(api.lastPathBody?['workspaceDir'], '/tmp/kidmemory-local/workspace');
    expect(api.lastPathBody?['exportDir'], '/tmp/kidmemory-local/exports');
    expect(find.textContaining('/tmp/kidmemory-local/data'), findsOneWidget);
    expect(
      find.textContaining('/tmp/kidmemory-local/workspace'),
      findsOneWidget,
    );
    expect(find.textContaining('本地数据目录已更新'), findsOneWidget);
  });

  testWidgets('setup local directory opens configured folder', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? openedPath;
    final api = _PathConfigSidecarApi();
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          api: api,
          pickDataDirectoryPath: () async => '/tmp/kidmemory-local',
          openExternalTarget: (target) async {
            openedPath = target;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await gotoStep(tester, '设置');
    await tester.pumpAndSettle();

    final configureDirectoryButton = find.byWidgetPredicate(
      (widget) => widget is SecondaryButton && widget.label == '配置目录',
    );
    await tester.tap(configureDirectoryButton.first);
    await tester.pumpAndSettle();

    final openDirectoryButton = find.byWidgetPredicate(
      (widget) => widget is SecondaryButton && widget.label == '打开目录',
    );
    expect(openDirectoryButton, findsOneWidget);
    await tester.ensureVisible(openDirectoryButton.first);
    await tester.tap(openDirectoryButton.first);
    await tester.pumpAndSettle();

    expect(openedPath, '/tmp/kidmemory-local/data');
  });

  testWidgets(
    'export flow uses configured export directory before calling sidecar export',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _FakeSidecarApi();

      await tester.pumpWidget(
        MaterialApp(
          home: DesktopShell(api: api),
        ),
      );

      await gotoStep(tester, '生成 / 预览');
      await tester.pumpAndSettle();

      await tester.tap(primaryButton('开始生成'));
      await tester.pumpAndSettle();
      expect(find.text('导出 PDF'), findsOneWidget);

      await tester.tap(find.text('导出 PDF'));
      await pumpUntil(tester, () => api.lastExportBody != null);
      await tester.pumpAndSettle();

      expect(
        api.lastExportBody?['targetPath'],
        '/tmp/kidmemory-exports/job_123456.pdf',
      );
      expect(find.textContaining('点击导出，准备读取当前导出目录'), findsOneWidget);
      expect(
        find.textContaining('PDF 导出成功：/tmp/kidmemory-exports/job_123456.pdf'),
        findsOneWidget,
      );
      expect(
        find.textContaining('PDF 已导出：/tmp/kidmemory-exports/job_123456.pdf'),
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
        MaterialApp(
          home: DesktopShell(
            api: api,
            copyToClipboard: (text) async {
              copiedText = text;
            },
          ),
        ),
      );

      await gotoStep(tester, '生成 / 预览');
      await tester.pumpAndSettle();

      await tester.tap(find.text('PDF 文件  高质量 PDF（打印级别）').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('长图 JPG  体积更小').last);
      await tester.pumpAndSettle();

      await tester.tap(primaryButton('开始生成'));
      await tester.pumpAndSettle();
      await tester.tap(primaryButton('导出 JPG 长图'));
      await pumpUntil(tester, () => api.lastLongImageExportBody != null);
      await tester.pumpAndSettle();

      expect(
        api.lastLongImageExportBody?['targetPath'],
        '/tmp/kidmemory-exports/job_123456.jpg',
      );
      expect(api.lastLongImageExportBody?['format'], 'jpg');
      expect(api.storageSyncArtifactIds, contains('artifact-job-jpg'));
      expect(api.storageWorkerRuns, 1);
      expect(find.textContaining('长图 JPG 已导出'), findsWidgets);
      expect(find.textContaining('链接有效期：3600 秒'), findsWidgets);

      await tester.ensureVisible(secondaryButton('复制分享文案'));
      await tester.tap(secondaryButton('复制分享文案'));
      await tester.pumpAndSettle();

      expect(copiedText, contains('链接有效期：3600 秒'));
    },
  );

  testWidgets('generate page opens a full log dialog', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: DesktopShell(api: _FakeSidecarApi())),
    );

    await gotoStep(tester, '生成 / 预览');
    await tester.pumpAndSettle();
    await tester.tap(primaryButton('开始生成'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(secondaryButton('查看详细日志'));
    await tester.tap(secondaryButton('查看详细日志'));
    await tester.pumpAndSettle();

    expect(find.text('Claude Agent 日志详情'), findsOneWidget);
    expect(find.textContaining('状态：'), findsOneWidget);
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

    await gotoStep(tester, '生成 / 预览');
    await tester.pumpAndSettle();

    expect(find.text('预览与导出将在生成后解锁'), findsWidgets);
    expect(secondaryButton('预览全部页面'), findsNothing);

    await tester.tap(primaryButton('开始生成'));
    await tester.pumpAndSettle();
    expect(secondaryButton('预览全部页面'), findsOneWidget);
    await tester.tap(secondaryButton('预览全部页面'));
    await tester.pumpAndSettle();
    expect(openedUrl, '${api.baseUrl}/books/jobs/job_123456/preview');
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
    await tester.tap(find.text('编辑资料'));
    await tester.pumpAndSettle();
    final editDialog = find.byType(AlertDialog);
    final dialogTextField = find.descendant(
      of: editDialog,
      matching: find.byType(TextField),
    );
    expect(dialogTextField, findsOneWidget);
    await tester.enterText(dialogTextField, '新名字');
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
      await gotoStep(tester, '示例数据集');
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
    await tester.ensureVisible(find.text('澄澄的画').first);
    await tester.tap(find.text('澄澄的画').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('甜甜').last);
    await tester.pumpAndSettle();

    await gotoStep(tester, '生成 / 预览');
    await tester.pumpAndSettle();
    await tester.tap(primaryButton('开始生成'));
    await tester.pumpAndSettle();

    expect(api.lastJobBody?['childId'], 'child-2');
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
    await tester.ensureVisible(find.text('澄澄的画').first);
    await tester.tap(find.text('澄澄的画').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('甜甜').last);
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

      await gotoStep(tester, '生成 / 预览');
      await tester.pumpAndSettle();
      expect(find.text('已选择素材（0）'), findsOneWidget);
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

  testWidgets('desktop shell stays on setup when schema initialization fails', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _SchemaInitFailureApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('Sidecar 已启动，schema 初始化未完成'), findsOneWidget);
    expect(api.datasetLoaded, isFalse);

    await gotoStep(tester, '孩子档案');
    await tester.pumpAndSettle();
    expect(find.text('Sidecar 已启动，schema 初始化未完成'), findsOneWidget);
  });

  testWidgets('sample dataset import shows success feedback', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FakeSidecarApi();
    await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await gotoStep(tester, '示例数据集');
    await tester.pumpAndSettle();
    await tester.tap(find.text('导入示例数据集'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('示例数据集已导入'), findsOneWidget);
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

    await gotoStep(tester, '示例数据集');
    await tester.pumpAndSettle();
    await tester.tap(find.text('导入示例数据集'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('导入失败'), findsOneWidget);
  });
}

class _FakeSidecarApi extends SidecarApi {
  Map<String, dynamic>? lastExportBody;
  String? lastJobId;
  Map<String, dynamic>? lastPathBody;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {
          'exportDir': '/tmp/kidmemory-exports',
        },
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
    if (path.startsWith('/config/check/')) {
      return {'ok': true};
    }
    if (path == '/books/jobs') {
      lastJobId = 'job_123456';
      return {'id': lastJobId, 'status': 'generated'};
    }
    if (path.startsWith('/books/jobs/') && path.endsWith('/export/pdf')) {
      lastExportBody = body;
      return {
        'exported': {'ok': true, 'path': body['targetPath']},
        'verified': {'ok': true, 'pageCount': 6, 'firstPageRendered': true},
      };
    }
    return {'ok': true};
  }
}

class _SupabaseStorageSidecarApi extends _FakeSidecarApi {
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
        'paths': {
          'exportDir': '/tmp/kidmemory-exports',
        },
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
    if (path == '/storage/export-artifacts/artifact-job-jpg/share') {
      return {
        'ok': true,
        'url': 'https://project.supabase.co/signed/job_123456.jpg',
        'expiresInSeconds': 3600,
        'text':
            'KidMemory 作品集：https://project.supabase.co/signed/job_123456.jpg\n链接有效期：3600 秒',
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
      return {
        'ok': true,
        'message': '测试通过',
        'cleanup': {'ok': true},
      };
    }
    if (path.startsWith('/books/jobs/') && path.endsWith('/export/long-image')) {
      lastLongImageExportBody = body;
      return {
        'exported': {'ok': true, 'path': body['targetPath']},
        'artifact': {
          'id': 'artifact-job-jpg',
          'jobId': lastJobId,
          'kind': 'long_image_jpg',
          'localPath': body['targetPath'],
          'storageProvider': 'local',
          'storageStatus': 'local_only',
        },
      };
    }
    if (path == '/storage/export-artifacts/artifact-job-jpg/sync') {
      storageSyncArtifactIds.add('artifact-job-jpg');
      return {
        'enqueued': true,
        'targetId': 'artifact-job-jpg',
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
    return super.get(path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/config/check/openai') {
      return {
        'ok': false,
        'service': 'openai',
        'blocksGeneration': false,
        'message': 'OpenAI-compatible API is not configured.',
      };
    }
    return super.post(path, body);
  }
}

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
  Map<String, dynamic>? lastJobBody;
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
    if (path == '/books/jobs') {
      lastJobBody = body;
      return {'id': 'job_123456', 'status': 'generated'};
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
