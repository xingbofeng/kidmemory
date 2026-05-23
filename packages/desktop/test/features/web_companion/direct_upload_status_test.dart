import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/features/web_companion/direct_upload/direct_upload_models.dart';
import 'package:kidmemory_desktop/features/web_companion/direct_upload/direct_upload_status.dart';

import '../../localized_test_app.dart';

void main() {
  Future<void> pumpList(
    WidgetTester tester, {
    required List<DirectUploadStatusItem> items,
    Future<void> Function(String objectKey)? onRetry,
  }) async {
    await tester.binding.setSurfaceSize(const Size(960, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: DirectUploadStatusList(
            items: items,
            onRetry: onRetry ?? (_) async {},
          ),
        ),
      ),
    );
    // Avoid pumpAndSettle here because the `downloading` row renders an
    // indeterminate CircularProgressIndicator, which never settles.
    await tester.pump();
  }

  testWidgets('pending_remote items render the waiting label', (tester) async {
    await pumpList(
      tester,
      items: [
        DirectUploadStatusItem(
          objectKey: 'web-companion-uploads/sess/foo.jpg',
          status: 'pending_remote',
        ),
      ],
    );
    expect(find.textContaining('等待回拉'), findsOneWidget);
    expect(find.textContaining('foo.jpg'), findsOneWidget);
  });

  testWidgets('downloading items render the in-progress label', (tester) async {
    await pumpList(
      tester,
      items: [
        DirectUploadStatusItem(
          objectKey: 'web-companion-uploads/sess/bar.png',
          status: 'downloading',
        ),
      ],
    );
    expect(find.textContaining('回拉中'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ready items render the success label and identifier', (
    tester,
  ) async {
    await pumpList(
      tester,
      items: [
        DirectUploadStatusItem(
          objectKey: 'web-companion-uploads/sess/baz.jpg',
          status: 'ready',
        ),
      ],
    );
    expect(find.textContaining('已入库'), findsOneWidget);
    expect(find.textContaining('baz.jpg'), findsOneWidget);
  });

  testWidgets(
    'failed items render the error message verbatim and a retry button',
    (tester) async {
      String? retried;
      await pumpList(
        tester,
        items: [
          DirectUploadStatusItem(
            objectKey: 'web-companion-uploads/sess/oops.jpg',
            status: 'failed',
            errorCode: 'download_failed',
            errorMessage: '网络中断，请稍后再试',
          ),
        ],
        onRetry: (key) async {
          retried = key;
        },
      );
      expect(find.text('网络中断，请稍后再试'), findsOneWidget);
      final retry = find.text('重试');
      expect(retry, findsOneWidget);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(retried, 'web-companion-uploads/sess/oops.jpg');
    },
  );

  testWidgets('failed items hide technical storage and request labels', (
    tester,
  ) async {
    await pumpList(
      tester,
      items: [
        DirectUploadStatusItem(
          objectKey: 'web-companion-uploads/sess/oops.jpg',
          status: 'failed',
          errorMessage:
              'Supabase sidecar requestId=req_1 taskId=task_1 SUPABASE_ANON_KEY',
        ),
      ],
    );
    expect(find.text('未知错误'), findsOneWidget);
    expect(find.textContaining('Supabase'), findsNothing);
    expect(find.textContaining('sidecar'), findsNothing);
    expect(find.textContaining('requestId'), findsNothing);
    expect(find.textContaining('taskId'), findsNothing);
  });
}
