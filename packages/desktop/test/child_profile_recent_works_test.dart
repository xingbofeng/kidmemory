import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kidmemory_desktop/features/child_profile/child_profile_page.dart';
import 'package:kidmemory_desktop/shared/models/library_models.dart';
import 'package:kidmemory_desktop/shared/widgets/content.dart';

import 'localized_test_app.dart';

void main() {
  testWidgets('recent works thumbnails open a preview dialog', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: ChildProfilePage(
            children: const [ChildVm(id: 'child-1', name: '澄澄')],
            assets: const [
              AssetVm(
                id: 'asset-1',
                title: '恐龙世界',
                type: 'artwork',
                description: '描述',
                tags: ['恐龙'],
                capturedAt: '2026-05-12',
                icon: Icons.image,
              ),
              AssetVm(
                id: 'asset-2',
                title: '生日蛋糕',
                type: 'photo',
                description: '描述',
                tags: ['生日'],
                capturedAt: '2026-05-11',
                icon: Icons.image,
              ),
              AssetVm(
                id: 'asset-3',
                title: '彩虹手工',
                type: 'craft',
                description: '描述',
                tags: ['彩虹'],
                capturedAt: '2026-05-10',
                icon: Icons.image,
              ),
            ],
            selectedChildId: 'child-1',
            onAddProfile: () {},
            onTrySample: () {},
            onEditProfile: (_) {},
            onDeleteProfile: (_) {},
            onChildChanged: (_) {},
          ),
        ),
      ),
    );

    final previewTarget = find.byWidgetPredicate(
      (widget) =>
          widget is AssetArtworkPreview &&
          widget.label == '恐龙世界' &&
          widget.height == 120,
    );

    expect(previewTarget, findsOneWidget);

    await tester.tap(previewTarget);
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('恐龙世界'), findsWidgets);
    expect(find.byTooltip('关闭'), findsOneWidget);
  });

  testWidgets('child profile page does not use vertical scrolling', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: ChildProfilePage(
            children: const [ChildVm(id: 'child-1', name: '澄澄')],
            assets: const [
              AssetVm(
                id: 'asset-1',
                title: '恐龙世界',
                type: 'artwork',
                description: '描述',
                tags: ['恐龙'],
                capturedAt: '2026-05-12',
                icon: Icons.image,
              ),
            ],
            selectedChildId: 'child-1',
            onAddProfile: () {},
            onTrySample: () {},
            onEditProfile: (_) {},
            onDeleteProfile: (_) {},
            onChildChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
