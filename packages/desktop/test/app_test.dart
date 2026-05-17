import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/app/app_step.dart';
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
    await gotoStep(tester, '素材库');
    await tester.pumpAndSettle();
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
    expect(primaryButton('开始生成绘本'), findsOneWidget);
    expect(find.text('Agent 活动'), findsOneWidget);
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

      await tester.pumpWidget(
        MaterialApp(home: DesktopShell(api: _FakeSidecarApi())),
      );
      await tester.pumpAndSettle();

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      expect(find.text('生成儿童绘本'), findsOneWidget);
      expect(find.text('生成成长纪念册'), findsOneWidget);
      expect(find.text('生成回忆录视频'), findsOneWidget);

      await tester.tap(find.text('生成儿童绘本'));
      await tester.pumpAndSettle();

      expect(find.textContaining('将使用免费生图服务生成封面图'), findsOneWidget);
      expect(find.text('继续生成'), findsOneWidget);
      expect(find.text('跳过封面'), findsOneWidget);
    },
  );

  testWidgets(
    'cover failure exposes retry/skip/log actions and skip uses skip cover policy',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = _CoverFailureSidecarApi();
      await tester.pumpWidget(MaterialApp(home: DesktopShell(api: api)));
      await tester.pumpAndSettle();

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      await tester.tap(find.text('生成儿童绘本'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('继续生成'));
      await tester.pumpAndSettle();

      expect(find.text('封面图生成失败'), findsWidgets);
      expect(secondaryButton('重试'), findsOneWidget);
      expect(secondaryButton('跳过封面继续导出'), findsOneWidget);
      expect(secondaryButton('查看日志'), findsOneWidget);
      expect(find.textContaining('Request ID: req_'), findsWidgets);

      await tester.ensureVisible(secondaryButton('跳过封面继续导出'));
      await tester.tap(secondaryButton('跳过封面继续导出'));
      await tester.pumpAndSettle();

      expect(api.lastJobBody?['coverPolicy'], 'skip');
      expect(find.textContaining('生成完成，可预览并导出 PDF'), findsOneWidget);
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

      expect(find.text('大模型接口配置'), findsWidgets);
      expect(find.text('Storage 配置'), findsOneWidget);
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
    expect(find.text('Storage 配置'), findsOneWidget);
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

      expect(find.text('Storage 配置'), findsOneWidget);
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
      expect(find.text('配置 Supabase Storage'), findsOneWidget);
      final fields = find.descendant(
        of: dialog,
        matching: find.byType(TextField),
      );
      expect(fields, findsNWidgets(9));
      expect(find.textContaining('先用 S3 方式最省事'), findsOneWidget);

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

      final s3AccessToggle = find.descendant(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'Access Key ID',
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

      final reopenedAccessToggle = find.descendant(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'Access Key ID',
        ),
        matching: find.byIcon(Icons.visibility_outlined),
      );
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

      await tester.ensureVisible(primaryButton('开始生成绘本'));
      await tester.tap(primaryButton('开始生成绘本'));
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

      await tester.ensureVisible(primaryButton('开始生成绘本'));
      await tester.tap(primaryButton('开始生成绘本'));
      await tester.pumpAndSettle();
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

      expect(api.lastExportBody?['targetPath'], '$expectedRoot/job_123456.pdf');
      expect(
        find.textContaining('PDF 导出成功：$expectedRoot/job_123456.pdf'),
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

      await selectOneAssetForGeneration(tester);
      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();

      await tester.tap(find.text('PDF 文件  高质量 PDF（打印级别）').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('长图 JPG  体积更小').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(primaryButton('开始生成绘本'));
      await tester.tap(primaryButton('开始生成绘本'));
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

    await selectOneAssetForGeneration(tester);
    await gotoStep(tester, '创作台');
    await tester.pumpAndSettle();
    await tester.ensureVisible(primaryButton('开始生成绘本'));
    await tester.tap(primaryButton('开始生成绘本'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(secondaryButton('查看详细日志'));
    await tester.tap(secondaryButton('查看详细日志'));
    await tester.pumpAndSettle();

    expect(find.text('生成日志详情'), findsOneWidget);
    expect(find.textContaining('状态：'), findsWidgets);
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

    expect(find.textContaining('生成完成后，可以导出 PDF、长图或创建分享链接'), findsWidgets);
    expect(secondaryButton('预览全部页面'), findsNothing);

    await tester.ensureVisible(primaryButton('开始生成绘本'));
    await tester.tap(primaryButton('开始生成绘本'));
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
    await tester.ensureVisible(primaryButton('开始生成绘本'));
    await tester.tap(primaryButton('开始生成绘本'));
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

class _FakeSidecarApi extends SidecarApi {
  Map<String, dynamic>? lastExportBody;
  String? lastJobId;
  Map<String, dynamic>? lastJobBody;
  Map<String, dynamic>? lastPathBody;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '/tmp/kidmemory-exports'},
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
      lastJobBody = body;
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
    if (path == '/books/jobs') {
      lastJobBody = body;
      if (body['coverPolicy'] == 'skip') {
        lastJobId = 'job_123456';
        return {'id': lastJobId, 'status': 'generated'};
      }
      return {
        'ok': false,
        'status': 'failed',
        'message': '封面图生成失败：免费生图服务暂时不可用',
      };
    }
    return super.post(path, body);
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
    if (path.startsWith('/books/jobs/') &&
        path.endsWith('/export/long-image')) {
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
        'message': '大模型接口未配置。',
      };
    }
    return super.post(path, body);
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
      if (path == '/config/check/openai') {
        return {
          'ok': false,
          'service': 'openai',
          'blocksGeneration': false,
          'message': '大模型接口未配置。',
        };
      }
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
