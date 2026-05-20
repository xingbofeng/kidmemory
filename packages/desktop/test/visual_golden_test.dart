import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/features/asset_library/asset_library_page.dart';
import 'package:kidmemory_desktop/shared/models/library_models.dart';
import 'package:kidmemory_desktop/features/generate_export/generate_export_page.dart';
import 'package:kidmemory_desktop/features/setup/setup_page.dart';

import 'localized_test_app.dart';

void main() {
  Future<void> setDesktopSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('storage setup unconfigured golden', (tester) async {
    await setDesktopSurface(tester);
    await tester.pumpWidget(
      _pageHarness(
        SetupPage(
          readinessMessage: '初始化成功，已完成 3 / 3 项 readiness 检测',
          checks: _readyChecks,
          supabaseStorage: SupabaseStorageVm.empty,
          onSetupAction: (_) {},
          onRefreshReadiness: () {},
          onOpenDirectory: (_) {},
          onConfigureSupabaseStorage: () {},
          onTestSupabaseStorage: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SetupPage),
      matchesGoldenFile('goldens/storage_setup_unconfigured.png'),
    );
  });

  testWidgets('storage setup configured golden', (tester) async {
    await setDesktopSurface(tester);
    await tester.pumpWidget(
      _pageHarness(
        SetupPage(
          readinessMessage: '初始化成功，已完成 3 / 3 项 readiness 检测',
          checks: _readyChecks,
          supabaseStorage: const SupabaseStorageVm(
            configured: true,
            url: 'https://project.supabase.co',
            bucket: 'kidmemory-exports',
            serviceRoleKeyConfigured: true,
            publicBaseUrl: '',
            signedUrlTtlSeconds: 3600,
            testMessage: '测试通过',
          ),
          onSetupAction: (_) {},
          onRefreshReadiness: () {},
          onOpenDirectory: (_) {},
          onConfigureSupabaseStorage: () {},
          onTestSupabaseStorage: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SetupPage),
      matchesGoldenFile('goldens/storage_setup_configured.png'),
    );
  });

  testWidgets('asset sync failure golden', (tester) async {
    await setDesktopSurface(tester);
    await tester.pumpWidget(
      _pageHarness(
        AssetLibraryPage(
          children: const [ChildVm(id: 'child-1', name: '澄澄')],
          selectedChildId: 'child-1',
          assets: const [
            AssetVm(
              id: 'asset-1',
              title: '太阳画',
              type: 'artwork',
              description: '画了太阳和花朵',
              tags: ['太阳', '花朵'],
              capturedAt: '2026-05-12',
              icon: Icons.palette,
              storageStatus: 'failed',
            ),
          ],
          typeOptions: _typeOptions,
          selectedAssets: const {'asset-1'},
          onChildChanged: (_) {},
          onToggle: (_) {},
          onUpdateAsset: (_, _) async => true,
          onDeleteAsset: (_) async => true,
          onDeleteSelected: () async => 0,
          onImportFiles: () async => const AssetImportReport(
            imported: 0,
            duplicates: 0,
            failed: 0,
            skipped: 0,
          ),
          onImportFolder: () async => const AssetImportReport(
            imported: 0,
            duplicates: 0,
            failed: 0,
            skipped: 0,
          ),
          onSyncAsset: (_) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AssetLibraryPage),
      matchesGoldenFile('goldens/asset_sync_failed.png'),
    );
  });

  testWidgets('export share golden', (tester) async {
    await setDesktopSurface(tester);
    await tester.pumpWidget(
      _pageHarness(
        GenerateExportPage(
          selectedCount: 8,
          generated: true,
          generating: false,
          exported: true,
          creationPhase: CreationWorkflowPhase.published,
          statusMessage: '长图 JPG 已导出：/tmp/kidmemory/job_123456.jpg',
          requestId: 'req_123456',
          logLines: const [
            '10:21:03  生成完成，已获得 jobId: job_123456',
            '10:21:16  长图 JPG 导出成功',
            '10:21:18  Supabase Storage 同步完成',
          ],
          templateOptions: const ['温暖童趣', '童话式成长记忆', '简约纪实'],
          pageSizeOptions: const ['A4 竖版  210 × 297 mm'],
          styleOptions: const ['温暖童趣  亲切温暖，适合儿童阅读'],
          exportTargetOptions: const [
            'PDF 文件  高质量 PDF（打印级别）',
            '长图 PNG  适合移动分享',
            '长图 JPG  体积更小',
          ],
          selectedTemplate: '温暖童趣',
          selectedPageSize: 'A4 竖版  210 × 297 mm',
          selectedStyle: '温暖童趣  亲切温暖，适合儿童阅读',
          selectedExportTarget: '长图 JPG  体积更小',
          exportResult: const ExportResultVm(
            kind: 'long_image_jpg',
            localPath: '/tmp/kidmemory/job_123456.jpg',
            storageStatus: 'synced',
            remoteUrl: 'https://project.supabase.co/signed/job_123456.jpg',
            shareText:
                'KidMemory 作品集：https://project.supabase.co/signed/job_123456.jpg\n链接有效期：3600 秒',
          ),
          onGenerate: () {},
          onConfirmPlan: () {},
          onExport: () {},
          onExportTargetChanged: (_) {},
          onOpenExportFolder: () {},
          onCopyShareText: () {},
          onCopyLongImage: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GenerateExportPage),
      matchesGoldenFile('goldens/export_share.png'),
    );
  });
}

Widget _pageHarness(Widget child) {
  return localizedTestApp(home: Scaffold(body: child));
}

const _readyChecks = [
  SetupCheckVm(
    index: '1',
    title: '本地资料库',
    body: '本地资料库连接正常。',
    action: '重新检测',
    state: '正常',
    ok: true,
  ),
  SetupCheckVm(
    index: '2',
    title: 'KidMemory 本地服务',
    body: '负责配置检测、资料库初始化、素材导入和生成任务。',
    action: '重新连接',
    state: '已启动',
    ok: true,
  ),
  SetupCheckVm(
    index: '3',
    title: 'pgvector 检测',
    body: 'pgvector 已安装并启用。',
    action: '重新检测',
    state: '正常',
    ok: true,
  ),
  SetupCheckVm(
    index: '4',
    title: '大模型接口配置',
    body: '提供文本生成、标签与提示词能力。',
    action: '配置',
    state: '正常',
    ok: true,
  ),
  SetupCheckVm(
    index: '5',
    title: '本地数据目录',
    body: '数据目录：/Users/me/Library/Application Support/KidMemory/data',
    action: '配置目录',
    state: '已配置',
    ok: true,
  ),
];

const _typeOptions = [
  {'value': 'all', 'label': '全部'},
  {'value': 'artwork', 'label': '绘画'},
  {'value': 'photo', 'label': '照片'},
  {'value': 'craft', 'label': '手工'},
];
