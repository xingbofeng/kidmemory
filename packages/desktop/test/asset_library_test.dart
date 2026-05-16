import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/features/asset_library/asset_library_page.dart';
import 'package:kidmemory_desktop/shared/models/library_models.dart';
import 'package:kidmemory_desktop/shared/widgets/content.dart';

const _okImportReport = AssetImportReport(
  imported: 1,
  duplicates: 0,
  failed: 0,
  skipped: 0,
);

AssetImportReport _importReport({
  int imported = 0,
  int duplicates = 0,
  int failed = 0,
  int skipped = 0,
  String message = '',
  String title = '',
}) {
  return AssetImportReport(
    imported: imported,
    duplicates: duplicates,
    failed: failed,
    skipped: skipped,
    message: message,
    title: title,
  );
}

void main() {
  testWidgets('asset library uses preview urls for imported assets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssetLibraryPage(
            children: const [ChildVm(id: 'child-1', name: '澄澄')],
            selectedChildId: 'child-1',
            assets: const [
              AssetVm(
                id: 'asset-1',
                title: '照片预览',
                type: 'photo',
                description: 'desc',
                tags: ['tag'],
                capturedAt: '2026-05-12',
                icon: Icons.photo_camera,
                previewUrl: 'http://127.0.0.1:4317/assets/asset-1/preview',
              ),
            ],
            selectedAssets: const {},
            onChildChanged: (_) {},
            onToggle: (_) {},
            onUpdateAsset: (_, _) async => true,
            onDeleteAsset: (_) async => true,
            onDeleteSelected: () async => 0,
            onImportFiles: () async => _okImportReport,
            typeOptions: const [
              {'value': 'all', 'label': '全部'},
              {'value': 'artwork', 'label': '绘画'},
              {'value': 'photo', 'label': '照片'},
              {'value': 'craft', 'label': '手工'},
            ],
            onImportFolder: () async => _okImportReport,
            onImportDroppedPaths: (_) async => _okImportReport,
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is NetworkImage,
      ),
      findsWidgets,
    );
  });

  testWidgets('asset library shows import actions when real assets exist', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssetLibraryPage(
            children: const [ChildVm(id: 'child-1', name: '澄澄')],
            selectedChildId: 'child-1',
            assets: const [
              AssetVm(
                id: 'asset-1',
                title: '太阳',
                type: 'artwork',
                description: 'desc',
                tags: ['tag'],
                capturedAt: '2026-05-12',
                icon: Icons.palette,
              ),
            ],
            selectedAssets: const {'asset-1'},
            onChildChanged: (_) {},
            onToggle: (_) {},
            onUpdateAsset: (_, _) async => true,
            onDeleteAsset: (_) async => true,
            onDeleteSelected: () async => 0,
            onImportFiles: () async => _okImportReport,
            typeOptions: const [
              {'value': 'all', 'label': '全部'},
              {'value': 'artwork', 'label': '绘画'},
              {'value': 'photo', 'label': '照片'},
              {'value': 'craft', 'label': '手工'},
            ],
            onImportFolder: () async => _okImportReport,
            onImportDroppedPaths: (_) async => _okImportReport,
          ),
        ),
      ),
    );

    expect(find.text('导入图片'), findsWidgets);
    expect(find.text('导入文件夹'), findsWidgets);
    expect(find.text('已选择 1 项素材'), findsOneWidget);
  });

  testWidgets('asset library shows storage status and retry sync action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? syncedAssetId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssetLibraryPage(
            children: const [ChildVm(id: 'child-1', name: '澄澄')],
            selectedChildId: 'child-1',
            assets: const [
              AssetVm(
                id: 'asset-1',
                title: '太阳',
                type: 'artwork',
                description: 'desc',
                tags: ['tag'],
                capturedAt: '2026-05-12',
                icon: Icons.palette,
                storageStatus: 'failed',
              ),
            ],
            selectedAssets: const {},
            onChildChanged: (_) {},
            onToggle: (_) {},
            onUpdateAsset: (_, _) async => true,
            onDeleteAsset: (_) async => true,
            onDeleteSelected: () async => 0,
            onImportFiles: () async => _okImportReport,
            typeOptions: const [
              {'value': 'all', 'label': '全部'},
              {'value': 'artwork', 'label': '绘画'},
              {'value': 'photo', 'label': '照片'},
              {'value': 'craft', 'label': '手工'},
            ],
            onImportFolder: () async => _okImportReport,
            onSyncAsset: (assetId) async {
              syncedAssetId = assetId;
              return true;
            },
          ),
        ),
      ),
    );

    expect(find.text('同步失败'), findsOneWidget);
    await tester.ensureVisible(find.text('重新同步'));
    await tester.tap(find.text('重新同步'));
    await tester.pumpAndSettle();

    expect(syncedAssetId, 'asset-1');
    expect(find.textContaining('已加入同步队列'), findsOneWidget);
  });

  testWidgets(
    'asset library keeps import actions visible when a child has no assets yet',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetLibraryPage(
              children: const [ChildVm(id: 'child-1', name: '澄澄')],
              selectedChildId: 'child-1',
              assets: const [],
              selectedAssets: const {},
              onChildChanged: (_) {},
              onToggle: (_) {},
              onUpdateAsset: (_, _) async => true,
              onDeleteAsset: (_) async => true,
              onDeleteSelected: () async => 0,
              onImportFiles: () async => _okImportReport,
              typeOptions: const [
                {'value': 'all', 'label': '全部'},
                {'value': 'artwork', 'label': '绘画'},
                {'value': 'photo', 'label': '照片'},
                {'value': 'craft', 'label': '手工'},
              ],
              onImportFolder: () async => _okImportReport,
            ),
          ),
        ),
      );

      expect(find.text('还没有素材'), findsOneWidget);
      expect(find.text('导入图片'), findsWidgets);
      expect(find.text('导入文件夹'), findsWidgets);
    },
  );

  testWidgets('asset library requires delete confirmation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var deleteCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssetLibraryPage(
            children: const [ChildVm(id: 'child-1', name: '澄澄')],
            selectedChildId: 'child-1',
            assets: const [
              AssetVm(
                id: 'asset-1',
                title: '太阳',
                type: 'artwork',
                description: 'desc',
                tags: ['tag'],
                capturedAt: '2026-05-12',
                icon: Icons.palette,
              ),
            ],
            selectedAssets: const {'asset-1'},
            onChildChanged: (_) {},
            onToggle: (_) {},
            onUpdateAsset: (_, _) async => true,
            onDeleteAsset: (_) async {
              deleteCalled = true;
              return true;
            },
            onDeleteSelected: () async => 0,
            typeOptions: const [
              {'value': 'all', 'label': '全部'},
              {'value': 'artwork', 'label': '绘画'},
              {'value': 'photo', 'label': '照片'},
              {'value': 'craft', 'label': '手工'},
            ],
            onImportFiles: () async => _okImportReport,
            onImportFolder: () async => _okImportReport,
            onImportDroppedPaths: (_) async => _okImportReport,
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('删除素材'));
    await tester.tap(find.text('删除素材'));
    await tester.pumpAndSettle();
    expect(find.text('确认删除素材'), findsOneWidget);
    expect(deleteCalled, isFalse);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(deleteCalled, isFalse);

    await tester.ensureVisible(find.text('删除素材'));
    await tester.tap(find.text('删除素材'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(deleteCalled, isTrue);
  });

  testWidgets('asset library search and filter change the rendered assets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _assetLibraryHarness(
        assets: const [
          AssetVm(
            id: 'asset-sun',
            title: '太阳画',
            type: 'artwork',
            description: 'desc',
            tags: ['黄色'],
            capturedAt: '2026-05-12',
            icon: Icons.palette,
          ),
          AssetVm(
            id: 'asset-cake',
            title: '纸杯蛋糕',
            type: 'craft',
            description: 'desc',
            tags: ['生日'],
            capturedAt: '2026-05-11',
            icon: Icons.build,
          ),
        ],
      ),
    );

    await tester.enterText(find.byType(TextField).first, '太阳');
    await tester.pumpAndSettle();
    expect(find.text('太阳画'), findsWidgets);
    expect(find.text('纸杯蛋糕'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('手工'));
    await tester.pumpAndSettle();
    expect(find.text('纸杯蛋糕'), findsWidgets);
    expect(find.text('太阳画'), findsNothing);
  });

  testWidgets('asset library exposes clear sort modes and can sort by type', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _assetLibraryHarness(
        assets: const [
          AssetVm(
            id: 'asset-photo',
            title: '照片素材',
            type: 'photo',
            description: 'desc',
            tags: ['照片'],
            capturedAt: '2026-05-10',
            icon: Icons.photo_camera,
          ),
          AssetVm(
            id: 'asset-craft',
            title: '手工素材',
            type: 'craft',
            description: 'desc',
            tags: ['手工'],
            capturedAt: '2026-05-11',
            icon: Icons.build,
          ),
          AssetVm(
            id: 'asset-artwork',
            title: '绘画素材',
            type: 'artwork',
            description: 'desc',
            tags: ['绘画'],
            capturedAt: '2026-05-12',
            icon: Icons.palette,
          ),
        ],
      ),
    );

    expect(find.text('创建时间（最新）'), findsOneWidget);
    await tester.tap(find.text('创建时间（最新）'));
    await tester.pumpAndSettle();
    expect(find.text('创建时间（最早）'), findsOneWidget);
    expect(find.text('种类（绘画/照片/手工）'), findsOneWidget);
    expect(find.text('标题（A-Z）'), findsOneWidget);

    await tester.tap(find.text('种类（绘画/照片/手工）').last);
    await tester.pumpAndSettle();

    final cards = tester.widgetList<AssetCard>(find.byType(AssetCard));
    expect(cards.map((card) => card.asset.title).toList(), [
      '绘画素材',
      '照片素材',
      '手工素材',
    ]);
  });

  testWidgets('asset library import reports clear success feedback', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _assetLibraryHarness(
        assets: const [],
        onImportFiles: () async => _okImportReport,
      ),
    );

    await tester.tap(find.text('导入图片').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('导入完成'), findsOneWidget);
    expect(find.text('成功 1 · 重复 0 · 跳过 0 · 失败 0'), findsOneWidget);
  });

  testWidgets('asset import toast uses nested report counts', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _assetLibraryHarness(
        assets: const [],
        onImportFiles: () async => _importReport(imported: 2, duplicates: 1),
      ),
    );

    await tester.tap(find.text('导入图片').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('导入完成'), findsOneWidget);
    expect(find.text('成功 2 · 重复 1 · 跳过 0 · 失败 0'), findsOneWidget);
  });

  testWidgets(
    'asset import toast shows empty result message on empty reports',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _assetLibraryHarness(
          assets: const [],
          onImportFiles: () async => _importReport(),
        ),
      );

      await tester.tap(find.text('导入图片').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      expect(find.text('未导入素材'), findsOneWidget);
      expect(find.textContaining('导入 0'), findsNothing);
    },
  );

  testWidgets('asset library paginates real assets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _assetLibraryHarness(
        assets: List.generate(
          7,
          (index) => AssetVm(
            id: 'asset-$index',
            title: '素材 $index',
            type: 'artwork',
            description: 'desc',
            tags: const ['tag'],
            capturedAt: '2026-05-12',
            icon: Icons.palette,
          ),
        ),
      ),
    );

    expect(find.text('素材 0'), findsWidgets);
    expect(find.text('素材 6'), findsNothing);

    await tester.tap(find.byTooltip('下一页'));
    await tester.pumpAndSettle();
    expect(find.text('素材 6'), findsWidgets);
    expect(find.text('素材 0'), findsNothing);
  });

  testWidgets('sample fallback detail follows the selected asset', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? toggledId;
    await tester.pumpWidget(
      _assetLibraryHarness(
        assets: const [
          AssetVm(
            id: 'asset-birthday-cake',
            title: '生日快乐',
            type: 'photo',
            description: 'desc',
            tags: ['tag'],
            capturedAt: '2026-05-12',
            icon: Icons.photo_camera,
          ),
        ],
        children: const [],
        onToggle: (id) => toggledId = id,
      ),
    );

    await tester.tap(find.text('生日快乐').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('加入本次作品集'));
    await tester.tap(find.text('加入本次作品集'));
    await tester.pumpAndSettle();

    expect(toggledId, 'asset-birthday-cake');
  });

  testWidgets('asset library supports smart pick flow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Set<String>? replaced;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssetLibraryPage(
            children: const [ChildVm(id: 'child-1', name: '澄澄')],
            selectedChildId: 'child-1',
            assets: const [
              AssetVm(
                id: 'asset-1',
                title: '太阳',
                type: 'artwork',
                description: 'desc',
                tags: ['tag'],
                capturedAt: '2026-05-12',
                icon: Icons.palette,
              ),
              AssetVm(
                id: 'asset-2',
                title: '大海',
                type: 'photo',
                description: 'desc',
                tags: ['tag'],
                capturedAt: '2026-05-10',
                icon: Icons.photo,
              ),
            ],
            selectedAssets: const {},
            onChildChanged: (_) {},
            onToggle: (_) {},
            onReplaceSelectedAssets: (ids) => replaced = ids,
            onUpdateAsset: (_, _) async => true,
            onDeleteAsset: (_) async => true,
            onDeleteSelected: () async => 0,
            typeOptions: const [
              {'value': 'all', 'label': '全部'},
              {'value': 'artwork', 'label': '绘画'},
              {'value': 'photo', 'label': '照片'},
              {'value': 'craft', 'label': '手工'},
            ],
            onImportFiles: () async => _okImportReport,
            onImportFolder: () async => _okImportReport,
          ),
        ),
      ),
    );

    await tester.tap(find.text('帮我挑素材').first);
    await tester.pumpAndSettle();

    expect(find.text('适合做绘本'), findsOneWidget);
    expect(find.text('适合做成长纪念册'), findsOneWidget);
    expect(find.text('适合做回忆录视频'), findsOneWidget);

    await tester.tap(find.text('确认使用'));
    await tester.pumpAndSettle();

    expect(replaced, isNotNull);
    expect(replaced!.isNotEmpty, isTrue);
  });
}

Widget _assetLibraryHarness({
  required List<AssetVm> assets,
  List<ChildVm> children = const [ChildVm(id: 'child-1', name: '澄澄')],
  ValueChanged<String>? onToggle,
  Future<AssetImportReport> Function()? onImportFiles,
}) {
  return MaterialApp(
    home: Scaffold(
      body: AssetLibraryPage(
        children: children,
        selectedChildId: children.isEmpty ? null : children.first.id,
        assets: assets,
        selectedAssets: const {},
        onChildChanged: (_) {},
        onToggle: onToggle ?? (_) {},
        onUpdateAsset: (_, _) async => true,
        onDeleteAsset: (_) async => true,
        onDeleteSelected: () async => 0,
        onImportFiles: onImportFiles ?? () async => _okImportReport,
        onImportFolder: () async => _okImportReport,
        onImportDroppedPaths: (_) async => _okImportReport,
        typeOptions: const [
          {'value': 'all', 'label': '全部'},
          {'value': 'artwork', 'label': '绘画'},
          {'value': 'photo', 'label': '照片'},
          {'value': 'craft', 'label': '手工'},
        ],
      ),
    ),
  );
}
