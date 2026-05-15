import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final root = Directory.current.path;

  test(
    'setup command runner has timeout and process cancellation guardrails',
    () {
      final source = File(
        '$root/lib/app/setup/commands/command_runner.dart',
      ).readAsStringSync();

      expect(source, contains('timeout = _setupCommandTimeout'));
      expect(source, contains('process.exitCode.timeout'));
      expect(source, contains('ProcessSignal.sigterm'));
    },
  );

  test('shared library view models are not owned by asset library page', () {
    final assetLibrarySource = File(
      '$root/lib/features/asset_library/asset_library_page.dart',
    ).readAsStringSync();
    final childProfileSource = File(
      '$root/lib/features/child_profile/child_profile_page.dart',
    ).readAsStringSync();

    expect(assetLibrarySource, isNot(contains('class ChildVm')));
    expect(assetLibrarySource, isNot(contains('class AssetVm')));
    expect(
      childProfileSource,
      isNot(contains("import '../asset_library/asset_library_page.dart';")),
    );
  });

  test('sidecar http client does not own agent configuration domain API', () {
    final sidecarApiSource = File(
      '$root/lib/core/sidecar/sidecar_api.dart',
    ).readAsStringSync();

    expect(sidecarApiSource, isNot(contains('class AgentConfigDto')));
    expect(sidecarApiSource, isNot(contains('class AgentRunDto')));
    expect(sidecarApiSource, isNot(contains('/api/config/agent-configs')));
  });

  test('desktop shell delegates sidecar process lifecycle to core service', () {
    final shellSidecarSource = File(
      '$root/lib/app/sidecar/sidecar.dart',
    ).readAsStringSync();

    expect(shellSidecarSource, isNot(contains('Socket.connect')));
    expect(shellSidecarSource, isNot(contains('ProcessStartMode.detached')));
  });
}
