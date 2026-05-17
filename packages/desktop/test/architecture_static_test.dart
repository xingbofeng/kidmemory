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

  test('desktop sidecar modules avoid local Request/Response API dto names', () {
    final targets = <String>[
      '$root/lib/core/sidecar/desktop_sidecar_gateway.dart',
      '$root/lib/core/sidecar/agent_config_api.dart',
      '$root/lib/shared/models/library_models.dart',
      '$root/lib/core/sidecar/sidecar_api.dart',
    ];
    final pattern = RegExp(r'class\s+\w*(Request|Response)\b');
    for (final target in targets) {
      final source = File(target).readAsStringSync();
      expect(
        pattern.hasMatch(source),
        isFalse,
        reason: '$target should avoid local Request/Response DTO names',
      );
    }
  });

  test('desktop sidecar gateway inputs should be protocol-generated aliases', () {
    final gatewaySource = File(
      '$root/lib/core/sidecar/desktop_sidecar_gateway.dart',
    ).readAsStringSync();

    expect(
      gatewaySource,
      contains("import 'package:kidmemory_protocol/kidmemory_protocol.dart';"),
    );
    for (final alias in const [
      'typedef PostgresConfigInput = PostgresConfigRequestDto;',
      'typedef OpenAiConfigInput = OpenAiConfigRequestDto;',
      'typedef PathsConfigInput = PathsConfigRequestDto;',
      'typedef SupabaseStorageConfigInput = SupabaseStorageConfigRequestDto;',
      'typedef UpdateAssetInput = UpdateAssetRequestDto;',
      'typedef CreateBookJobInput = CreateBookJobRequestDto;',
      'typedef ImportAssetsInput = ImportAssetsRequestDto;',
    ]) {
      expect(gatewaySource, contains(alias));
    }
  });

  test('desktop sidecar gateway avoids local API result dto classes', () {
    final gatewaySource = File(
      '$root/lib/core/sidecar/desktop_sidecar_gateway.dart',
    ).readAsStringSync();

    for (final localApiDto in const [
      'class OperationResultDto',
      'class ConfigurePathsResultDto',
      'class ConfigureSupabaseStorageResultDto',
      'class SupabaseStorageTestResultDto',
      'class EnqueueResultDto',
      'class StorageSyncRunResultDto',
      'class ArtifactShareResultDto',
      'class BookExportResultDto',
      'class ExportedPayloadDto',
      'class IndexingStatusDto',
      'class ImportSampleResultDto',
      'class EnsureChildResultDto',
      'class AssetSearchResultDto',
      'class AssetSearchItemDto',
      'class ImportAssetsResultDto',
      'class CreateBookJobResultDto',
      'class ResetSampleResultDto',
      'class UpdateAssetResultDto',
    ]) {
      expect(gatewaySource, isNot(contains(localApiDto)));
    }
  });
}
