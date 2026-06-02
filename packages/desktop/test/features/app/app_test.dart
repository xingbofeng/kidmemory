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

import '../../localized_test_app.dart';

part 'app_fake_sidecar_apis.dart';
part 'app_navigation_suite.dart';
part 'app_profile_dataset_suite.dart';
part 'app_setup_and_export_suite.dart';
part 'app_share_and_preview_suite.dart';

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
  await tester.ensureVisible(find.text('生成儿童绘本').first);
  await tester.tap(find.text('生成儿童绘本').first);
  await tester.pumpAndSettle();
  await tester.ensureVisible(primaryButton('开始规划'));
  await tester.tap(primaryButton('开始规划'));
  await tester.pumpAndSettle();
  await confirmReadyCreationPlan(tester);
}

Future<void> generateMemoryVideoFromCard(WidgetTester tester) async {
  await tester.ensureVisible(find.text('生成回忆视频'));
  await tester.tap(find.text('生成回忆视频'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(primaryButton('开始规划'));
  await tester.tap(primaryButton('开始规划'));
  await tester.pumpAndSettle();
  await confirmReadyCreationPlan(tester);
}

void main() {
  appNavigationSuite();
  appSetupAndExportSuite();
  appShareAndPreviewSuite();
  appProfileAndDatasetSuite();
}
