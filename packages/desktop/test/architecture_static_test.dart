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
    final legacyOpenAiConfigPath =
        '/config'
        '/openai';
    final legacyOpenAiCheckPath =
        '/config/check'
        '/openai';
    final legacyAgentTestPath =
        '/books/agent'
        '/test';
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
        contains("import 'package:kidmemory_protocol/kidmemory_protocol.dart'"),
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
    expect(iconFiles.length, greaterThanOrEqualTo(AppIconAssets.byName.length));
    expect(AppIconAssets.byName.length, greaterThanOrEqualTo(64));
    final existingIconPaths = iconFiles.map((file) {
      final name = file.uri.pathSegments.last;
      return '${AppIconAssets.libraryRoot}/$name';
    }).toSet();
    for (final iconPath in AppIconAssets.byName.values) {
      expect(existingIconPaths, contains(iconPath));
    }

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

    final combinedUiSource = uiSources
        .map((file) => file.readAsStringSync())
        .join('\n');
    expect(
      combinedUiSource,
      anyOf(contains('AppAssetIcon'), contains('iconAsset')),
    );

    for (final file in uiSources) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('Icons.')), reason: file.path);
      expect(
        RegExp(r'(^|[^A-Za-z])Icon\(').hasMatch(source),
        isFalse,
        reason: file.path,
      );
    }
  });

  test('generate export feature is split into focused modules', () {
    final featureRoot = Directory('$root/lib/features/generate_export');
    final pageFile = File('${featureRoot.path}/generate_export_page.dart');
    final pageSource = pageFile.readAsStringSync();

    final expectedFiles = [
      'generate_export_assets.dart',
      'generate_export_models.dart',
      'generate_export_utils.dart',
      'widgets/activity_and_failures.dart',
      'widgets/compose_stage.dart',
      'widgets/creation_stage_stepper.dart',
      'widgets/export_result_panel.dart',
      'widgets/generation_progress.dart',
      'widgets/plan_confirmation.dart',
      'widgets/preview_panels.dart',
      'widgets/settings_panel.dart',
      'widgets/shared_ui.dart',
    ];

    for (final relativePath in expectedFiles) {
      expect(
        File('${featureRoot.path}/$relativePath').existsSync(),
        isTrue,
        reason: '$relativePath should exist',
      );
    }

    expect(pageSource.split('\n'), hasLength(lessThanOrEqualTo(500)));
    expect(pageSource, contains('class GenerateExportPage'));
    for (final movedDeclaration in const [
      'class ExportResultVm',
      'enum CreationWorkflowPhase',
      'class SmartGenerateActions',
      'class GenerationFlowProgress',
      'class ExportResultPanel',
      'class GenerateSettingsPanel',
    ]) {
      expect(
        pageSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should not live in the page shell',
      );
    }
  });

  test('child profile feature is split into focused modules', () {
    final featureRoot = Directory('$root/lib/features/child_profile');
    final pageFile = File('${featureRoot.path}/child_profile_page.dart');
    final pageSource = pageFile.readAsStringSync();

    final expectedFiles = [
      'child_profile_utils.dart',
      'widgets/child_profile_content.dart',
      'widgets/child_profile_empty_state.dart',
      'widgets/child_profile_empty_artwork.dart',
      'widgets/child_profile_empty_features.dart',
      'widgets/child_profile_empty_hero.dart',
      'widgets/child_profile_empty_privacy.dart',
      'widgets/child_profile_stats_panels.dart',
      'widgets/child_profile_work_panels.dart',
      'widgets/child_profile_aside_panel.dart',
      'widgets/child_profile_header.dart',
      'widgets/child_profile_shared_ui.dart',
    ];

    for (final relativePath in expectedFiles) {
      expect(
        File('${featureRoot.path}/$relativePath').existsSync(),
        isTrue,
        reason: '$relativePath should exist',
      );
    }

    expect(pageSource.split('\n'), hasLength(lessThanOrEqualTo(500)));
    expect(pageSource, contains('class ChildProfilePage'));
    for (final movedDeclaration in const [
      'class ChildProfileContent',
      'class EmptyChildProfilePage',
      'class ChildProfileSectionHeader',
      'class ChildProfileMetricTile',
      'class ChildProfilePortrait',
      'class ChildProfilePieChartPainter',
    ]) {
      expect(
        pageSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should not live in the page shell',
      );
    }

    final emptyStateSource = File(
      '${featureRoot.path}/widgets/child_profile_empty_state.dart',
    ).readAsStringSync();
    final emptyArtworkSource = File(
      '${featureRoot.path}/widgets/child_profile_empty_artwork.dart',
    ).readAsStringSync();
    for (final movedDeclaration in const [
      'class ShieldHomeIllustration',
      'class EmptyDesignCard',
      'class MemoryBookIllustration',
      'class MemoryBookPainter',
      'class WhiteCircleIcon',
      'class DecorDot',
      'class Sparkle',
      'class SparklePainter',
    ]) {
      expect(
        emptyStateSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should live in empty artwork widgets',
      );
      expect(emptyArtworkSource, contains(movedDeclaration));
    }

    final emptyFeaturesSource = File(
      '${featureRoot.path}/widgets/child_profile_empty_features.dart',
    ).readAsStringSync();
    for (final movedDeclaration in const [
      'class EmptyFeatureStrip',
      'class EmptyFeaturePill',
      'class EmptyFeatureDivider',
    ]) {
      expect(
        emptyStateSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should live in empty feature widgets',
      );
      expect(emptyFeaturesSource, contains(movedDeclaration));
    }

    final emptyPrivacySource = File(
      '${featureRoot.path}/widgets/child_profile_empty_privacy.dart',
    ).readAsStringSync();
    for (final movedDeclaration in const [
      'class EmptyPrivacyCard',
      'class EmptyPrivacyRow',
      'class DataOwnershipBanner',
    ]) {
      expect(
        emptyStateSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should live in empty privacy widgets',
      );
      expect(emptyPrivacySource, contains(movedDeclaration));
    }

    final emptyHeroSource = File(
      '${featureRoot.path}/widgets/child_profile_empty_hero.dart',
    ).readAsStringSync();
    for (final movedDeclaration in const [
      'class EmptyHeroCard',
      'class EmptyHeroCopy',
    ]) {
      expect(
        emptyStateSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should live in empty hero widgets',
      );
      expect(emptyHeroSource, contains(movedDeclaration));
    }

    final contentSource = File(
      '${featureRoot.path}/widgets/child_profile_content.dart',
    ).readAsStringSync();
    final statsPanelsSource = File(
      '${featureRoot.path}/widgets/child_profile_stats_panels.dart',
    ).readAsStringSync();
    for (final movedDeclaration in const [
      'class GrowthStatsPanel',
      'class ChildProfileDistributionPanel',
      'class ChildProfileDistributionChart',
      'class ChildProfilePieChartPainter',
    ]) {
      expect(
        contentSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should live in stats panels',
      );
      expect(statsPanelsSource, contains(movedDeclaration));
    }

    final workPanelsSource = File(
      '${featureRoot.path}/widgets/child_profile_work_panels.dart',
    ).readAsStringSync();
    for (final movedDeclaration in const [
      'class RecentAssetsPanel',
      'class CollectionRecordsPanel',
    ]) {
      expect(
        contentSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should live in work panels',
      );
      expect(workPanelsSource, contains(movedDeclaration));
    }

    final asidePanelSource = File(
      '${featureRoot.path}/widgets/child_profile_aside_panel.dart',
    ).readAsStringSync();
    for (final movedDeclaration in const [
      'class ProfileAsidePanel',
      'class ProfileArtworkRail',
    ]) {
      expect(
        contentSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should live in aside panel',
      );
      expect(asidePanelSource, contains(movedDeclaration));
    }

    final sharedUiSource = File(
      '${featureRoot.path}/widgets/child_profile_shared_ui.dart',
    ).readAsStringSync();
    for (final removedDeclaration in const [
      'class ActivityTimeline',
      'class ChildProfileTimelineNode',
      'class ChildProfileTimelineItem',
    ]) {
      expect(
        '$contentSource\n$sharedUiSource',
        isNot(contains(removedDeclaration)),
        reason: '$removedDeclaration is not wired to the current profile page',
      );
    }

    final headerSource = File(
      '${featureRoot.path}/widgets/child_profile_header.dart',
    ).readAsStringSync();
    for (final movedDeclaration in const [
      'class ChildProfilePortrait',
      'AssetVm? childProfileImageAsset',
      'class DeleteChildButton',
      'class ProfileHeaderScene',
    ]) {
      expect(
        contentSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should live in profile header widgets',
      );
      expect(headerSource, contains(movedDeclaration));
    }
  });

  test('asset library controller and utility modules use imports', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final pageFile = File('${featureRoot.path}/asset_library_page.dart');
    final pageSource = pageFile.readAsStringSync();

    final expectedFiles = [
      'asset_library_controller.dart',
      'asset_library_utils.dart',
      'asset_library_widgets.dart',
    ];

    for (final relativePath in expectedFiles) {
      expect(
        File('${featureRoot.path}/$relativePath').existsSync(),
        isTrue,
        reason: '$relativePath should exist',
      );
    }

    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final assetSelectorsSource = File(
      '${featureRoot.path}/asset_library_asset_selectors.dart',
    ).readAsStringSync();
    expect(pageSource, isNot(contains("part 'asset_library_state.dart';")));
    expect(pageSource, isNot(contains("part 'asset_library_widgets.dart';")));
    expect(
      File('${featureRoot.path}/asset_library_state.dart').existsSync(),
      isFalse,
      reason: 'legacy part file should be removed after import migration',
    );
    expect(
      stateSource,
      isNot(contains("import 'asset_library_controller.dart';")),
    );
    expect(
      assetSelectorsSource,
      contains("import 'asset_library_controller.dart';"),
    );
    expect(stateSource, contains("import 'asset_library_widgets.dart';"));

    final controllerSource = File(
      '${featureRoot.path}/asset_library_controller.dart',
    ).readAsStringSync();
    expect(
      controllerSource,
      isNot(contains("part of 'asset_library_page.dart'")),
    );
    expect(controllerSource, contains('class AssetLibraryController'));
    expect(controllerSource, contains('class AssetLibraryPageWindow'));

    final widgetsSource = File(
      '${featureRoot.path}/asset_library_widgets.dart',
    ).readAsStringSync();
    expect(widgetsSource, isNot(contains("part of 'asset_library_page.dart'")));
  });

  test('asset library widgets are split into focused widget modules', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final widgetsBarrel = File(
      '${featureRoot.path}/asset_library_widgets.dart',
    );
    final widgetsSource = widgetsBarrel.readAsStringSync();

    final expectedFiles = [
      'widgets/asset_library_palette.dart',
      'widgets/asset_library_toolbar.dart',
      'widgets/asset_library_toolbar_controls.dart',
      'widgets/asset_library_status.dart',
      'widgets/asset_library_filter_status.dart',
      'widgets/asset_library_selection.dart',
      'widgets/asset_library_panels.dart',
    ];

    for (final relativePath in expectedFiles) {
      expect(
        File('${featureRoot.path}/$relativePath').existsSync(),
        isTrue,
        reason: '$relativePath should exist',
      );
      expect(
        widgetsSource,
        contains("export '$relativePath';"),
        reason: 'asset_library_widgets.dart should export $relativePath',
      );
    }

    expect(widgetsSource, isNot(contains('class AssetLibraryToolbar')));
    expect(widgetsSource, isNot(contains('class AssetLibraryStatusBar')));
    expect(widgetsSource, isNot(contains('class EmptyAssetLibrary')));
    expect(widgetsSource.split('\n'), hasLength(lessThanOrEqualTo(20)));

    final toolbarSource = File(
      '${featureRoot.path}/widgets/asset_library_toolbar.dart',
    ).readAsStringSync();
    final toolbarControlsSource = File(
      '${featureRoot.path}/widgets/asset_library_toolbar_controls.dart',
    ).readAsStringSync();
    for (final movedControl in const [
      'class ReadonlyToolbarField',
      'class ToolbarLabeledField',
      'class InlineStatusChip',
      'class AssetLibraryToolbarButton',
      'class IndexingStatusPill',
      'class AssetLibrarySearchStatusStrip',
    ]) {
      expect(
        toolbarSource,
        isNot(contains(movedControl)),
        reason: '$movedControl should live in toolbar controls',
      );
      expect(toolbarControlsSource, contains(movedControl));
    }

    final statusSource = File(
      '${featureRoot.path}/widgets/asset_library_status.dart',
    ).readAsStringSync();
    final selectionSource = File(
      '${featureRoot.path}/widgets/asset_library_selection.dart',
    ).readAsStringSync();
    for (final movedSelectionWidget in const [
      'class AssetLibraryBatchActionBar',
      'class AssetLibraryBatchTextButton',
    ]) {
      expect(
        statusSource,
        isNot(contains(movedSelectionWidget)),
        reason: '$movedSelectionWidget should live in selection widgets',
      );
      expect(selectionSource, contains(movedSelectionWidget));
    }

    expect(
      selectionSource,
      isNot(contains('class AssetLibrarySelectionBasket')),
      reason:
          'AssetLibrarySelectionBasket is not wired to the current asset library UI',
    );

    expect(
      statusSource,
      isNot(contains('class AssetStorageAction')),
      reason: 'AssetStorageAction is not wired to the current asset library UI',
    );

    final filterStatusSource = File(
      '${featureRoot.path}/widgets/asset_library_filter_status.dart',
    ).readAsStringSync();
    for (final movedFilterWidget in const [
      'class AssetLibraryStatusBar',
      'class AssetLibrarySegmentOption',
    ]) {
      expect(
        statusSource,
        isNot(contains(movedFilterWidget)),
        reason: '$movedFilterWidget should live in filter status widgets',
      );
      expect(filterStatusSource, contains(movedFilterWidget));
    }
  });

  test('asset library inspector detail widgets are removed when not wired', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final panelsSource = File(
      '${featureRoot.path}/widgets/asset_library_panels.dart',
    ).readAsStringSync();

    expect(stateSource, isNot(contains('Widget _buildDemoDetail')));
    expect(stateSource, isNot(contains('Widget _buildEditableDetail')));
    expect(stateSource, isNot(contains('InputDecoration _fieldDecoration')));
    expect(stateSource, isNot(contains('String _displayAssetTitle')));
    expect(stateSource, isNot(contains('String _formatChineseDate')));

    for (final removedDeclaration in const [
      'class AssetLibraryDemoDetail',
      'class AssetLibraryEditableDetail',
    ]) {
      expect(
        panelsSource,
        isNot(contains(removedDeclaration)),
        reason: '$removedDeclaration is not wired to the current main view',
      );
    }
  });

  test('asset library page delegates models grid and smart pick logic', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final pageSource = File(
      '${featureRoot.path}/asset_library_page.dart',
    ).readAsStringSync();

    for (final relativePath in const [
      'asset_library_models.dart',
      'asset_library_smart_pick.dart',
    ]) {
      expect(
        File('${featureRoot.path}/$relativePath').existsSync(),
        isTrue,
        reason: '$relativePath should exist',
      );
    }

    final panelsSource = File(
      '${featureRoot.path}/widgets/asset_library_panels.dart',
    ).readAsStringSync();
    expect(panelsSource, contains('class AssetLibraryGridArea'));

    for (final movedDeclaration in const [
      'class AssetImportReport',
      'class AssetMetadataUpdate',
      'Widget _buildAssetGridArea',
      'List<AssetVm> _buildSmartSuggestion',
      'int _smartAssetScore',
    ]) {
      expect(
        pageSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should not live in the page shell',
      );
    }
  });

  test('asset library page delegates import feedback and delete dialogs', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final pageSource = File(
      '${featureRoot.path}/asset_library_page.dart',
    ).readAsStringSync();

    for (final relativePath in const [
      'asset_library_import_feedback.dart',
      'asset_library_dialogs.dart',
    ]) {
      expect(
        File('${featureRoot.path}/$relativePath').existsSync(),
        isTrue,
        reason: '$relativePath should exist',
      );
    }

    for (final movedDeclaration in const [
      'void _showImportToast',
      'showDialog<bool>',
      'assetLibraryImportSummaryMessage',
      'assetLibraryDeleteSelectedConfirm',
    ]) {
      expect(
        pageSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should not live in the page shell',
      );
    }
  });

  test('asset library page delegates smart pick dialog UI', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final pageSource = File(
      '${featureRoot.path}/asset_library_page.dart',
    ).readAsStringSync();
    final dialogFile = File(
      '${featureRoot.path}/asset_library_smart_pick_dialog.dart',
    );

    expect(dialogFile.existsSync(), isTrue);
    final dialogSource = dialogFile.readAsStringSync();
    expect(dialogSource, contains('class AssetLibrarySmartPickDialogResult'));
    expect(
      dialogSource,
      contains('Future<AssetLibrarySmartPickDialogResult?>'),
    );

    for (final movedDeclaration in const [
      'StatefulBuilder',
      "RadioListTile<String>",
      'assetLibrarySmartPickedCount',
      'assetLibraryPageS919',
    ]) {
      expect(
        pageSource,
        isNot(contains(movedDeclaration)),
        reason: '$movedDeclaration should not live in the page shell',
      );
    }
  });

  test('asset library page delegates search and indexing feedback text', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final pageSource = File(
      '${featureRoot.path}/asset_library_page.dart',
    ).readAsStringSync();
    final helperFile = File(
      '${featureRoot.path}/asset_library_search_feedback.dart',
    );

    expect(helperFile.existsSync(), isTrue);
    final helperSource = helperFile.readAsStringSync();
    expect(helperSource, contains('assetLibraryMissingSemanticSearchMessage'));
    expect(helperSource, contains('assetLibraryMissingChildMessage'));
    expect(helperSource, contains('assetLibraryEmptyQueryMessage'));
    expect(helperSource, contains('assetLibrarySemanticSearchingMessage'));
    expect(helperSource, contains('assetLibrarySearchFailedMessage'));
    expect(helperSource, contains('assetLibraryIndexingRefreshFailedMessage'));

    for (final movedMessage in const [
      'assetLibraryPageS483',
      'assetLibraryPageS858',
      'assetLibraryPageS867',
      'assetLibraryPageS665',
      'assetLibrarySearchFailedStatus',
      'assetLibraryPageS825',
    ]) {
      expect(
        pageSource,
        isNot(contains(movedMessage)),
        reason: '$movedMessage should not live in the page shell',
      );
    }
  });

  test('asset library page delegates editor action helpers', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final pageSource = File(
      '${featureRoot.path}/asset_library_page.dart',
    ).readAsStringSync();
    final helperFile = File(
      '${featureRoot.path}/asset_library_editor_actions.dart',
    );

    expect(helperFile.existsSync(), isTrue);
    final helperSource = helperFile.readAsStringSync();
    expect(helperSource, contains('buildAssetMetadataUpdate'));
    expect(helperSource, contains('openAssetOriginalFile'));
    expect(helperSource, contains('showAssetMetadataSaveToast'));
    expect(helperSource, contains('showAssetDeleteResultToast'));
    expect(helperSource, contains('showAssetSyncResultToast'));

    for (final movedDetail in const [
      '      AssetMetadataUpdate(',
      "Process.start('open'",
      'assetLibraryOpenOriginalFailedMessage',
      'assetLibraryPageS249',
      'assetLibraryPageS434',
      'assetLibraryPageS437',
    ]) {
      expect(
        pageSource,
        isNot(contains(movedDetail)),
        reason: '$movedDetail should not live in the page shell',
      );
    }
  });

  test('asset library page delegates main view layout', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final mainViewFile = File(
      '${featureRoot.path}/widgets/asset_library_main_view.dart',
    );

    expect(mainViewFile.existsSync(), isTrue);
    final mainViewSource = mainViewFile.readAsStringSync();
    expect(mainViewSource, contains('class AssetLibraryMainView'));
    expect(stateSource, contains('AssetLibraryMainView('));

    for (final movedDetail in const [
      'AssetLibraryToolbar(',
      'AssetLibraryStatusBar(',
      'AssetLibraryGridArea(',
      'PaginationBar(',
      'DropTarget(',
      'LayoutBuilder(',
    ]) {
      expect(
        stateSource,
        isNot(contains(movedDetail)),
        reason: '$movedDetail should not live in the page shell',
      );
    }
  });

  test('asset library page removes unused inspector shell layout', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final pageSource = File(
      '${featureRoot.path}/asset_library_page.dart',
    ).readAsStringSync();
    final panelsSource = File(
      '${featureRoot.path}/widgets/asset_library_panels.dart',
    ).readAsStringSync();

    expect(panelsSource, isNot(contains('class AssetLibraryDemoDetail')));
    expect(panelsSource, isNot(contains('class AssetLibraryEditableDetail')));
    expect(pageSource, isNot(contains('Widget _buildInspector')));
    expect(pageSource, isNot(contains('unused_element')));
    expect(pageSource, isNot(contains('AssetLibraryDemoDetail(')));
    expect(pageSource, isNot(contains('AssetLibraryEditableDetail(')));
    expect(pageSource, isNot(contains('AssetInspectorEmptyState(')));
  });

  test(
    'asset library page shell keeps state implementation in focused module',
    () {
      final featureRoot = Directory('$root/lib/features/asset_library');
      final pageSource = File(
        '${featureRoot.path}/asset_library_page.dart',
      ).readAsStringSync();
      final stateFile = File(
        '${featureRoot.path}/asset_library_page_state.dart',
      );

      expect(stateFile.existsSync(), isTrue);
      final stateSource = stateFile.readAsStringSync();
      expect(pageSource.split('\n'), hasLength(lessThanOrEqualTo(500)));
      expect(pageSource, contains('class AssetLibraryPage'));
      expect(pageSource, isNot(contains('class _AssetLibraryPageState')));
      expect(pageSource, isNot(contains('class AssetLibraryPageState')));
      expect(stateSource, contains('class AssetLibraryPageState'));
      expect(pageSource, contains('AssetLibraryPageState'));
    },
  );

  test('asset library state delegates search and indexing actions', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final searchActionsFile = File(
      '${featureRoot.path}/asset_library_search_actions.dart',
    );

    expect(searchActionsFile.existsSync(), isTrue);
    final searchActionsSource = searchActionsFile.readAsStringSync();
    expect(searchActionsSource, contains('mixin AssetLibrarySearchActions'));
    expect(stateSource, contains('class AssetLibraryPageState'));
    expect(stateSource, contains('AssetLibrarySearchActions'));
    expect(
      stateSource,
      contains("import 'asset_library_search_actions.dart';"),
    );

    for (final movedMethod in const [
      'Future<void> _runSemanticSearch()',
      'Future<void> _refreshSearchIndexingStatus()',
      'void _clearSemanticSearch()',
    ]) {
      expect(
        stateSource,
        isNot(contains(movedMethod)),
        reason: '$movedMethod should live in asset_library_search_actions.dart',
      );
      expect(searchActionsSource, contains(movedMethod.replaceAll('_', '')));
    }
  });

  test('asset library state delegates import actions', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final importActionsFile = File(
      '${featureRoot.path}/asset_library_import_actions.dart',
    );

    expect(importActionsFile.existsSync(), isTrue);
    final importActionsSource = importActionsFile.readAsStringSync();
    expect(importActionsSource, contains('mixin AssetLibraryImportActions'));
    expect(stateSource, contains('AssetLibraryImportActions'));
    expect(
      stateSource,
      contains("import 'asset_library_import_actions.dart';"),
    );

    for (final movedMethod in const [
      'Future<void> _importFilesWithMessage()',
      'Future<void> _importFolderWithMessage()',
      'Future<void> _runImportWithMessage(',
      'Future<void> _importDroppedPathsWithMessage(',
    ]) {
      expect(
        stateSource,
        isNot(contains(movedMethod)),
        reason: '$movedMethod should live in asset_library_import_actions.dart',
      );
    }
    for (final publicMethod in const [
      'Future<void> importFilesWithMessage()',
      'Future<void> importFolderWithMessage()',
      'Future<void> runImportWithMessage(',
      'Future<void> importDroppedPathsWithMessage(',
    ]) {
      expect(importActionsSource, contains(publicMethod));
    }
  });

  test('asset library state delegates selection and delete actions', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final selectionActionsFile = File(
      '${featureRoot.path}/asset_library_selection_actions.dart',
    );

    expect(selectionActionsFile.existsSync(), isTrue);
    final selectionActionsSource = selectionActionsFile.readAsStringSync();
    expect(
      selectionActionsSource,
      contains('mixin AssetLibrarySelectionActions'),
    );
    expect(stateSource, contains('AssetLibrarySelectionActions'));
    expect(
      stateSource,
      contains("import 'asset_library_selection_actions.dart';"),
    );

    for (final movedMethod in const [
      'void _clearSelectedAssets()',
      'Future<void> _showSmartPickDialog()',
      'Future<void> _deleteSelectedWithConfirmation()',
    ]) {
      expect(
        stateSource,
        isNot(contains(movedMethod)),
        reason:
            '$movedMethod should live in asset_library_selection_actions.dart',
      );
    }
    for (final publicMethod in const [
      'void clearSelectedAssets()',
      'Future<void> showSmartPickDialog()',
      'Future<void> deleteSelectedWithConfirmation()',
    ]) {
      expect(selectionActionsSource, contains(publicMethod));
    }
  });

  test('asset library state delegates metadata editor actions', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final metadataActionsFile = File(
      '${featureRoot.path}/asset_library_metadata_actions.dart',
    );

    expect(metadataActionsFile.existsSync(), isTrue);
    final metadataActionsSource = metadataActionsFile.readAsStringSync();
    expect(
      metadataActionsSource,
      contains('mixin AssetLibraryMetadataActions'),
    );
    expect(stateSource, contains('AssetLibraryMetadataActions'));
    expect(
      stateSource,
      contains("import 'asset_library_metadata_actions.dart';"),
    );

    for (final movedMethod in const [
      'void syncEditor()',
      'void _markMetadataDirty()',
    ]) {
      expect(
        stateSource,
        isNot(contains(movedMethod)),
        reason:
            '$movedMethod should live in asset_library_metadata_actions.dart',
      );
    }
    expect(metadataActionsSource, contains('void syncEditor()'));
    expect(metadataActionsSource, contains('void markMetadataDirty()'));
  });

  test('asset library state delegates inline interaction actions', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final interactionActionsFile = File(
      '${featureRoot.path}/asset_library_interaction_actions.dart',
    );

    expect(interactionActionsFile.existsSync(), isTrue);
    final interactionActionsSource = interactionActionsFile.readAsStringSync();
    expect(
      interactionActionsSource,
      contains('mixin AssetLibraryInteractionActions'),
    );
    expect(stateSource, contains('AssetLibraryInteractionActions'));
    expect(
      stateSource,
      contains("import 'asset_library_interaction_actions.dart';"),
    );

    for (final inlineDetail in const [
      'onSearchChanged: (_) => setState',
      'onSortChanged: (mode) => setState',
      'onTypeFilterChanged: (type) => setState',
      'onAssetTap: (asset) {',
      'onPreviousPage: () => setState',
      'onNextPage: () => setState',
      'onDragEntered: () => setState',
      'onDragExited: () => setState',
      'onDroppedPaths: (paths) async {',
    ]) {
      expect(
        stateSource,
        isNot(contains(inlineDetail)),
        reason: '$inlineDetail should live in interaction actions',
      );
    }
    for (final publicMethod in const [
      'void handleSearchChanged()',
      'void changeSortMode(String mode)',
      'void changeTypeFilter(String type)',
      'void selectAsset(AssetVm asset)',
      'void goToPreviousPage(',
      'void goToNextPage(',
      'void enterDrag()',
      'void exitDrag()',
      'Future<void> dropPaths(',
    ]) {
      expect(interactionActionsSource, contains(publicMethod));
    }
  });

  test('asset library state delegates derived display helpers', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final displayHelpersFile = File(
      '${featureRoot.path}/asset_library_display_helpers.dart',
    );

    expect(displayHelpersFile.existsSync(), isTrue);
    final displayHelpersSource = displayHelpersFile.readAsStringSync();
    expect(
      stateSource,
      isNot(contains("import 'asset_library_display_helpers.dart';")),
    );
    final viewStateSource = File(
      '${featureRoot.path}/asset_library_view_state.dart',
    ).readAsStringSync();
    expect(
      viewStateSource,
      contains("import 'asset_library_display_helpers.dart';"),
    );

    for (final movedMethod in const [
      'String? _selectedChildName()',
      'Map<String, int> _typeCounts(',
      'String _displayType(',
    ]) {
      expect(
        stateSource,
        isNot(contains(movedMethod)),
        reason: '$movedMethod should live in display helpers',
      );
    }
    for (final helper in const [
      'String? selectedAssetLibraryChildName(',
      'Map<String, int> assetLibraryTypeCounts(',
      'String assetLibraryDisplayType(',
    ]) {
      expect(displayHelpersSource, contains(helper));
    }
  });

  test('asset library state delegates asset selector getters', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final selectorsFile = File(
      '${featureRoot.path}/asset_library_asset_selectors.dart',
    );

    expect(selectorsFile.existsSync(), isTrue);
    final selectorsSource = selectorsFile.readAsStringSync();
    expect(selectorsSource, contains('mixin AssetLibraryAssetSelectors'));
    expect(stateSource, contains('AssetLibraryAssetSelectors'));
    expect(
      stateSource,
      contains("import 'asset_library_asset_selectors.dart';"),
    );

    for (final movedGetter in const [
      'AssetVm? get selectedAsset',
      'List<AssetVm> get currentPageAssets',
      'List<AssetVm> get displayedAssets',
      'List<AssetVm> get selectedBasketAssets',
      'List<AssetVm> get filteredAssets',
    ]) {
      expect(
        stateSource,
        isNot(contains(movedGetter)),
        reason: '$movedGetter should live in asset selectors',
      );
      expect(selectorsSource, contains(movedGetter));
    }
  });

  test('asset library state delegates lifecycle state adjustments', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final lifecycleActionsFile = File(
      '${featureRoot.path}/asset_library_lifecycle_actions.dart',
    );

    expect(lifecycleActionsFile.existsSync(), isTrue);
    final lifecycleActionsSource = lifecycleActionsFile.readAsStringSync();
    expect(
      lifecycleActionsSource,
      contains('mixin AssetLibraryLifecycleActions'),
    );
    expect(stateSource, contains('AssetLibraryLifecycleActions'));
    expect(
      stateSource,
      contains("import 'asset_library_lifecycle_actions.dart';"),
    );

    for (final movedDetail in const [
      'AssetLibraryController.containsType(widget.typeOptions',
      'oldWidget.typeOptions != widget.typeOptions',
      'oldWidget.selectedChildId != widget.selectedChildId',
      '      semanticSearchResults = const [];',
    ]) {
      expect(
        stateSource,
        isNot(contains(movedDetail)),
        reason: '$movedDetail should live in lifecycle actions',
      );
    }
    for (final publicMethod in const [
      'void initializeTypeDefaults()',
      'void handleWidgetUpdated(',
      'void handleTypeOptionsChanged()',
      'void handleSelectedChildChanged()',
    ]) {
      expect(lifecycleActionsSource, contains(publicMethod));
    }
  });

  test('asset library state delegates build view state assembly', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final viewStateFile = File(
      '${featureRoot.path}/asset_library_view_state.dart',
    );

    expect(viewStateFile.existsSync(), isTrue);
    final viewStateSource = viewStateFile.readAsStringSync();
    expect(viewStateSource, contains('class AssetLibraryViewState'));
    expect(
      viewStateSource,
      contains('AssetLibraryViewState buildAssetLibraryViewState('),
    );
    expect(stateSource, contains("import 'asset_library_view_state.dart';"));
    expect(stateSource, contains('buildAssetLibraryViewState('));

    for (final movedDetail in const [
      'final isDemoMode = widget.children.isEmpty && widget.assets.isEmpty;',
      'final visibleAssets = filteredAssets;',
      'final pageWindow = AssetLibraryController.pageWindow(',
      'final selectedChildName = selectedAssetLibraryChildName(',
      'final totalPages = pageWindow.totalPages;',
      'final currentPage = pageWindow.currentPage;',
      'final pageAssets = pageWindow.pageAssets;',
    ]) {
      expect(
        stateSource,
        isNot(contains(movedDetail)),
        reason: '$movedDetail should live in asset library view state',
      );
    }
  });

  test('asset library main view consumes view state for display data', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final mainViewSource = File(
      '${featureRoot.path}/widgets/asset_library_main_view.dart',
    ).readAsStringSync();
    final viewStateSource = File(
      '${featureRoot.path}/asset_library_view_state.dart',
    ).readAsStringSync();

    expect(viewStateSource, contains('final Map<String, int> typeCounts;'));
    expect(viewStateSource, contains('String displayType(String value)'));
    expect(mainViewSource, contains('required this.viewState'));
    expect(mainViewSource, contains('final AssetLibraryViewState viewState;'));
    expect(stateSource, contains('viewState: viewState,'));

    for (final removedParameter in const [
      'required this.isDemoMode',
      'required this.typeCounts',
      'required this.visibleAssets',
      'required this.pageAssets',
      'required this.currentPage',
      'required this.totalPages',
      'required this.pageSize',
      'required this.displayType',
      'final bool isDemoMode;',
      'final Map<String, int> typeCounts;',
      'final List<AssetVm> visibleAssets;',
      'final List<AssetVm> pageAssets;',
      'final int currentPage;',
      'final int totalPages;',
      'final int pageSize;',
      'final String Function(String value) displayType;',
    ]) {
      expect(
        mainViewSource,
        isNot(contains(removedParameter)),
        reason:
            '$removedParameter should be represented by AssetLibraryViewState',
      );
    }
  });

  test('asset library main view consumes view actions for callbacks', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();
    final mainViewSource = File(
      '${featureRoot.path}/widgets/asset_library_main_view.dart',
    ).readAsStringSync();
    final viewStateSource = File(
      '${featureRoot.path}/asset_library_view_state.dart',
    ).readAsStringSync();

    expect(viewStateSource, contains('class AssetLibraryViewActions'));
    expect(mainViewSource, contains('required this.actions'));
    expect(mainViewSource, contains('final AssetLibraryViewActions actions;'));
    expect(stateSource, contains('actions: AssetLibraryViewActions('));

    for (final removedCallback in const [
      'required this.onSearchChanged',
      'required this.onChildChanged',
      'required this.onSortChanged',
      'required this.onSemanticSearch',
      'required this.onRefreshSearchIndexing',
      'required this.onImportFiles',
      'required this.onImportFolder',
      'required this.onSmartPick',
      'required this.onDeleteSelected',
      'required this.onClearSelection',
      'required this.onTypeFilterChanged',
      'required this.onClearSearch',
      'required this.onAssetTap',
      'required this.onPreviousPage',
      'required this.onNextPage',
      'required this.onDragEntered',
      'required this.onDragExited',
      'required this.onDroppedPaths',
      'final ValueChanged<String> onSearchChanged;',
      'final Future<void> Function() onSemanticSearch;',
      'final ValueChanged<AssetVm> onAssetTap;',
      'final VoidCallback onPreviousPage;',
      'final ValueChanged<List<String>> onDroppedPaths;',
    ]) {
      expect(
        mainViewSource,
        isNot(contains(removedCallback)),
        reason:
            '$removedCallback should be represented by AssetLibraryViewActions',
      );
    }
  });

  test(
    'asset library main view consumes view state for ui flags and filters',
    () {
      final featureRoot = Directory('$root/lib/features/asset_library');
      final mainViewSource = File(
        '${featureRoot.path}/widgets/asset_library_main_view.dart',
      ).readAsStringSync();
      final viewStateSource = File(
        '${featureRoot.path}/asset_library_view_state.dart',
      ).readAsStringSync();

      for (final viewStateField in const [
        'final List<ChildVm> children;',
        'final String? selectedChildId;',
        'final String selectedSortMode;',
        'final bool semanticSearching;',
        'final bool refreshingIndex;',
        'final bool importBusy;',
        'final bool deleteBusy;',
        'final bool draggingFiles;',
        'final List<Map<String, String>> typeOptions;',
        'final String selectedFilterType;',
        'final String indexingMessage;',
        'final bool semanticSearchActive;',
        'final String searchStatusMessage;',
        'final int semanticSearchResultCount;',
        'final Set<String> selectedAssets;',
      ]) {
        expect(viewStateSource, contains(viewStateField));
      }

      for (final removedParameter in const [
        'required this.children',
        'required this.selectedChildId',
        'required this.selectedSortMode',
        'required this.semanticSearching',
        'required this.refreshingIndex',
        'required this.importBusy',
        'required this.deleteBusy',
        'required this.draggingFiles',
        'required this.typeOptions',
        'required this.selectedFilterType',
        'required this.indexingMessage',
        'required this.semanticSearchActive',
        'required this.searchStatusMessage',
        'required this.semanticSearchResultCount',
        'required this.selectedAssets',
        'final List<ChildVm> children;',
        'final String? selectedChildId;',
        'final String selectedSortMode;',
        'final bool semanticSearching;',
        'final bool refreshingIndex;',
        'final bool importBusy;',
        'final bool deleteBusy;',
        'final bool draggingFiles;',
        'final List<Map<String, String>> typeOptions;',
        'final String selectedFilterType;',
        'final String indexingMessage;',
        'final bool semanticSearchActive;',
        'final String searchStatusMessage;',
        'final int semanticSearchResultCount;',
        'final Set<String> selectedAssets;',
      ]) {
        expect(
          mainViewSource,
          isNot(contains(removedParameter)),
          reason:
              '$removedParameter should be represented by AssetLibraryViewState',
        );
      }
    },
  );

  test('asset library page state removes stale editor flags', () {
    final featureRoot = Directory('$root/lib/features/asset_library');
    final stateSource = File(
      '${featureRoot.path}/asset_library_page_state.dart',
    ).readAsStringSync();

    for (final staleField in const ['savingMetadata', 'inspectorCollapsed']) {
      expect(
        stateSource,
        isNot(contains(staleField)),
        reason: '$staleField is no longer wired to the asset library UI',
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
