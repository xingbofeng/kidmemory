import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/features/web_companion/direct_upload/direct_upload_dialog.dart';
import 'package:kidmemory_desktop/features/web_companion/direct_upload/direct_upload_entry.dart';
import 'package:kidmemory_desktop/features/web_companion/direct_upload/direct_upload_models.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  final config = DirectUploadConfig(
    sessionId: 'sess-001',
    childId: 'child-7',
    bucket: 'web-companion-uploads',
    sessionPath: 'web-companion-uploads/sess-001',
    supabaseUrl: 'https://example.supabase.co',
    anonKey: 'anon-public-key',
    publicUrl: 'https://companion.example.com/direct-upload?sessionId=sess-001',
    recommendedClientLimit: 200,
    expiresAtHintSeconds: 10800,
    token: 'test-token',
  );

  Future<void> pumpDialog(
    WidgetTester tester, {
    DirectUploadStatusSnapshot? status,
    VoidCallback? onClose,
    Future<void> Function()? onPullback,
    Future<void> Function(String objectKey)? onRetry,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DirectUploadDialog(
            config: config,
            status: status,
            onClose: onClose ?? () {},
            onPullback: onPullback ?? () async {},
            onRetry: onRetry ?? (_) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dialog shows the child id text', (tester) async {
    await pumpDialog(tester);
    expect(find.textContaining('child-7'), findsWidgets);
  });

  testWidgets('dialog shows the bucket and sessionId path', (tester) async {
    await pumpDialog(tester);
    expect(find.textContaining('web-companion-uploads/sess-001'), findsWidgets);
  });

  testWidgets('dialog shows the direct upload risk banner', (tester) async {
    await pumpDialog(tester);
    expect(find.textContaining('上传完成后需在电脑端拉回'), findsWidgets);
    expect(find.textContaining('素材才会正式入库'), findsWidgets);
    expect(find.textContaining('Supabase'), findsNothing);
    expect(find.textContaining('sidecar'), findsNothing);
    expect(find.textContaining('requestId'), findsNothing);
    expect(find.textContaining('taskId'), findsNothing);
  });

  testWidgets('dialog has a close affordance', (tester) async {
    var closed = false;
    await pumpDialog(tester, onClose: () => closed = true);
    final closeFinder = find.byTooltip('关闭');
    expect(closeFinder, findsOneWidget);
    await tester.tap(closeFinder);
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });

  testWidgets('dialog renders the publicUrl as selectable text', (
    tester,
  ) async {
    await pumpDialog(tester);
    expect(
      find.textContaining(
        'https://companion.example.com/direct-upload?sessionId=sess-001',
      ),
      findsWidgets,
    );
  });

  testWidgets('dialog renders a real QR image for the publicUrl', (
    tester,
  ) async {
    await pumpDialog(tester);
    final qrFinder = find.byKey(
      ValueKey<String>('direct-upload-qr:${config.publicUrl}'),
    );
    expect(qrFinder, findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.textContaining('QR 占位'), findsNothing);
  });

  testWidgets('dialog tapping the pullback button invokes the callback', (
    tester,
  ) async {
    var calls = 0;
    await pumpDialog(
      tester,
      onPullback: () async {
        calls += 1;
      },
    );
    final pullback = find.text('拉回本地');
    expect(pullback, findsOneWidget);
    await tester.tap(pullback);
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('DirectUploadEntryButton shows upload label and is tappable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DirectUploadEntryButton(onTap: () => taps += 1)),
      ),
    );
    expect(find.textContaining('扫码上传'), findsOneWidget);
    await tester.tap(find.byType(DirectUploadEntryButton));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });
}
