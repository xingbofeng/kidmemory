import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kidmemory_desktop/shared/widgets/chrome.dart';

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

  test('desktop OpenAI setup uses persisted agent config APIs only', () {
    final legacyOpenAiConfigPath = '/config' '/openai';
    final legacyOpenAiCheckPath = '/config/check' '/openai';
    final legacyAgentTestPath = '/books/agent' '/test';
    final targets = <String>[
      '$root/lib/core/sidecar/agent_config_api.dart',
      '$root/lib/core/sidecar/desktop_sidecar_gateway.dart',
      '$root/lib/app/setup/dialogs/dialog_openai.dart',
      '$root/lib/features/agent_settings/agent_settings_page.dart',
    ];

    for (final target in targets) {
      final source = File(target).readAsStringSync();
      expect(
        source,
        isNot(contains(legacyOpenAiConfigPath)),
        reason: '$target should not write legacy setup OpenAI config',
      );
      expect(
        source,
        isNot(contains(legacyOpenAiCheckPath)),
        reason: '$target should test the default persisted agent config',
      );
      expect(
        source,
        isNot(contains(legacyAgentTestPath)),
        reason: '$target should test persisted agent configs',
      );
    }
  });

  test('desktop shell delegates sidecar process lifecycle to core service', () {
    final shellSidecarSource = File(
      '$root/lib/app/sidecar/sidecar.dart',
    ).readAsStringSync();

    expect(shellSidecarSource, isNot(contains('Socket.connect')));
    expect(shellSidecarSource, isNot(contains('ProcessStartMode.detached')));
  });

  test(
    'desktop sidecar modules avoid local Request/Response API dto names',
    () {
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
    },
  );

  test(
    'desktop sidecar gateway inputs should be protocol-generated aliases',
    () {
      final gatewaySource = File(
        '$root/lib/core/sidecar/desktop_sidecar_gateway.dart',
      ).readAsStringSync();

      expect(
        gatewaySource,
        contains(
          "import 'package:kidmemory_protocol/kidmemory_protocol.dart'",
        ),
      );
      for (final alias in const [
        'typedef PostgresConfigInput = PostgresConfigRequestDto;',
        'typedef PathsConfigInput = PathsConfigRequestDto;',
        'typedef SupabaseStorageConfigInput = SupabaseStorageConfigRequestDto;',
        'typedef UpdateAssetInput = UpdateAssetRequestDto;',
        'typedef ImportAssetsInput = ImportAssetsRequestDto;',
      ]) {
        expect(gatewaySource, contains(alias));
      }
      expect(
        gatewaySource,
        contains("'/creation/tasks'"),
        reason: 'creation should use task-first sidecar routes',
      );
      expect(
        gatewaySource,
        isNot(contains('/books/jobs')),
        reason: 'desktop should not call the removed legacy book job API',
      );
    },
  );

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
      'class ExportedPayloadDto',
      'class IndexingStatusDto',
      'class ImportSampleResultDto',
      'class EnsureChildResultDto',
      'class AssetSearchResultDto',
      'class AssetSearchItemDto',
      'class ImportAssetsResultDto',
      'class ResetSampleResultDto',
      'class UpdateAssetResultDto',
    ]) {
      expect(gatewaySource, isNot(contains(localApiDto)));
    }
  });

  test('issue 2 creation and upload UI uses the bundled icon library', () {
    final iconFiles = Directory('$root/assets/icons/library')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.png'))
        .toList(growable: false);
    expect(iconFiles, hasLength(64));
    expect(AppIconAssets.byName, hasLength(64));
    expect(
      AppIconAssets.byName.values.toSet(),
      equals(
        iconFiles.map((file) {
          final name = file.uri.pathSegments.last;
          return '${AppIconAssets.libraryRoot}/$name';
        }).toSet(),
      ),
    );

    final uiSources =
        [
              File(
                '$root/lib/features/generate_export/generate_export_page.dart',
              ),
              File('$root/lib/features/asset_library/asset_library_page.dart'),
              File(
                '$root/lib/features/asset_library/asset_library_widgets.dart',
              ),
              File('$root/lib/app/setup/dialogs/dialog_openai.dart'),
              File(
                '$root/lib/app/setup/dialogs/dialog_storage_form_fields.dart',
              ),
              Directory('$root/lib/features/web_companion/direct_upload'),
              Directory('$root/lib/features/web_companion/trusted_upload'),
            ]
            .expand(
              (entry) => entry is File
                  ? [entry]
                  : (entry as Directory)
                        .listSync(recursive: true)
                        .whereType<File>()
                        .where(
                          (file) =>
                              file.path.endsWith('_dialog.dart') ||
                              file.path.endsWith('_entry.dart') ||
                              file.path.endsWith('_status.dart'),
                        ),
            )
            .toList(growable: false);

    for (final file in uiSources) {
      final source = file.readAsStringSync();
      expect(
        source,
        anyOf(contains('AppAssetIcon'), contains('iconAsset')),
        reason: file.path,
      );
      expect(source, isNot(contains('Icons.')), reason: file.path);
      expect(
        RegExp(r'(^|[^A-Za-z])Icon\(').hasMatch(source),
        isFalse,
        reason: file.path,
      );
    }
  });

  test('setup migration keeps common Dart and Flutter identifiers intact', () {
    final setupSources = Directory('$root/lib/app/setup')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => MapEntry(file.path, file.readAsStringSync()));

    for (final corruptedIdentifier in const [
      'Process.tart',
      'process.tdout',
      'process.tderr',
      'ProcessSignal.igterm',
      '_StreamKind.tdout',
      '_StreamKind.tderr',
      '.election',
      'CrossAxisAlignment.tart',
    ]) {
      for (final source in setupSources) {
        expect(
          source.value,
          isNot(contains(corruptedIdentifier)),
          reason:
              '${source.key} contains invalid identifier $corruptedIdentifier',
        );
      }
    }
  });
}
