import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kidmemory_desktop/features/sample_dataset/sample_dataset_page.dart';

import '../../localized_test_app.dart';

void main() {
  testWidgets('sample dataset page shows placeholder previews when empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: SampleDatasetPage(
            imported: false,
            importing: false,
            importFailed: false,
            previewAssets: const [],
            artworkCount: 0,
            craftCount: 0,
            photoCount: 0,
            tagCount: 0,
            onReset: () {},
            onOpenSamplePdf: () {},
            onBrowseSampleAssets: () {},
            onGenerateSampleBook: () {},
            onImport: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('示例数据集'), findsOneWidget);
    expect(find.text('导入示例数据集'), findsOneWidget);
    expect(find.text('阳光花园'), findsWidgets);
    expect(find.text('草地男孩'), findsWidgets);
    expect(find.text('生日蛋糕'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
