part of 'app_test.dart';

void appProfileAndDatasetSuite() {
  testWidgets('editing child profile posts updated name to children api', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _MultiChildSidecarApi();
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
        localizedTestApp(home: DesktopShell(api: _FakeSidecarApi())),
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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

  testWidgets('delete child profile confirms before deleting linked data', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _MultiChildSidecarApi();
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
    await tester.pumpAndSettle();

    await gotoStep(tester, '孩子档案');
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除').first);
    await tester.pumpAndSettle();

    expect(find.text('确定要删除「澄澄」吗？'), findsOneWidget);
    expect(find.text('删除后，这个孩子的素材、索引和相关本地记录也会一起删除。'), findsOneWidget);
    expect(api.deletedChildIds, isEmpty);

    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('取消')),
    );
    await tester.pumpAndSettle();
    expect(api.deletedChildIds, isEmpty);

    await tester.tap(find.text('删除').first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('删除')),
    );
    await tester.pumpAndSettle();

    expect(api.deletedChildIds, contains('child-1'));
  });

  testWidgets(
    'desktop shell starts without a hardcoded selected sample asset and uses sidecar child data',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        localizedTestApp(home: DesktopShell(api: _FakeSidecarApi())),
      );
      await tester.pumpAndSettle();

      await gotoStep(tester, '孩子档案');
      await tester.pumpAndSettle();
      expect(find.text('澄澄'), findsWidgets);

      await gotoStep(tester, '创作台');
      await tester.pumpAndSettle();
      expect(find.text('素材准备'), findsOneWidget);
    },
  );

  testWidgets('desktop shell initializes the schema before loading dataset', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _MultiChildSidecarApi();
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
    await tester.pumpWidget(localizedTestApp(home: DesktopShell(api: api)));
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
      localizedTestApp(home: DesktopShell(api: _SampleImportFailureApi())),
    );
    await tester.pumpAndSettle();

    await openSampleFromHome(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('导入示例数据集'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('导入失败'), findsOneWidget);
  });
}
