import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/sidecar/sidecar_api.dart';
import '../core/sidecar/desktop_sidecar_gateway.dart';
import '../core/sidecar/sidecar_launcher.dart';
import '../core/sidecar/agent_config_api.dart';
import '../core/logging/desktop_log_cleanup_worker.dart';
import '../core/logging/desktop_logger.dart';
import '../core/logging/desktop_trace_context.dart';
import '../features/asset_library/asset_library_page.dart';
import '../features/child_profile/child_profile_page.dart';
import '../features/generate_export/generate_export_page.dart';
import '../features/sample_dataset/sample_dataset_page.dart';
import '../features/setup/setup_page.dart';
import '../features/web_companion/direct_upload/direct_upload_controller.dart';
import '../features/web_companion/direct_upload/direct_upload_dialog.dart';
import '../features/web_companion/direct_upload/direct_upload_models.dart';
import '../shared/models/library_models.dart';
import 'app_step.dart';
import '../shared/widgets/chrome.dart';
import '../shared/widgets/content.dart';
import '../shared/widgets/status.dart';
import '../../l10n/app_localizations.dart';

// Types & defaults
part 'desktop_shell_types.dart';
part 'desktop_shell_defaults.dart';
part 'desktop_shell_models.dart';
// Pages
part 'pages/pages.dart';
part 'pages/paths.dart';
part 'pages/feedback.dart';
// Dataset
part 'dataset/dataset.dart';
part 'dataset/dataset_external.dart';
part 'dataset/dataset_children.dart';
part 'dataset/dataset_preview.dart';
part 'dataset/dataset_sample.dart';
part 'dataset/controllers.dart';
// Assets
part 'assets/asset_actions.dart';
part 'assets/direct_upload.dart';
// Assets - Import
part 'assets/import/import.dart';
part 'assets/import/import_staging.dart';
part 'assets/import/import_preview.dart';
part 'assets/import/import_utils.dart';
part 'assets/import/import_summary.dart';
// Export
part 'export/export.dart';
part 'export/export_asset_sync.dart';
part 'export/export_generation_state.dart';
part 'export/export_result_state.dart';
part 'export/export_targets.dart';
part 'export/export_sync.dart';
part 'export/export_actions.dart';
// Sidecar
part 'sidecar/sidecar.dart';
part 'sidecar/sidecar_installers.dart';
part 'sidecar/executable_finder.dart';
part 'sidecar/node_install.dart';
part 'sidecar/install_runner.dart';
// Readiness
part 'readiness/readiness.dart';
part 'readiness/readiness_refresh_apply.dart';
part 'readiness/readiness_checks.dart';
part 'readiness/readiness_storage.dart';
part 'readiness/readiness_startup_gate.dart';
part 'readiness/readiness_rules.dart';
part 'readiness/readiness_parsing.dart';
part 'readiness/readiness_parsing_json.dart';
part 'readiness/readiness_mappers.dart';
// Utils
part 'utils/text_utils.dart';
part 'utils/snapshots.dart';
// Setup - Actions
part 'setup/actions/setup_actions.dart';
part 'setup/actions/setup_postgres.dart';
part 'setup/actions/setup_pgvector.dart';
part 'setup/actions/setup_system.dart';
// Setup - Commands
part 'setup/commands/command_runner.dart';
part 'setup/commands/command_streaming.dart';
// Setup - Dialogs
part 'setup/dialogs/dialog_openai.dart';
part 'setup/dialogs/dialog_storage.dart';
part 'setup/dialogs/dialog_storage_form.dart';
part 'setup/dialogs/dialog_storage_form_fields.dart';
part 'setup/dialogs/dialog_storage_submit.dart';
// Setup - Probes
part 'setup/probes/probe.dart';
part 'setup/probes/probe_pgvector.dart';
// Setup - State
part 'setup/state/setup_state.dart';
part 'setup/state/setup_config.dart';
part 'setup/state/setup_paths_state.dart';
part 'setup/state/progress_tracker.dart';
part 'setup/state/progress_updates.dart';
// Setup - Flows
part 'setup/flows/setup_flow.dart';
part 'setup/flows/local_data_picker.dart';
part 'setup/flows/local_data_apply.dart';
part 'setup/flows/storage_test.dart';
part 'setup/flows/targeted_checks.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({
    super.key,
    this.api,
    this.pickDataDirectoryPath,
    this.pickImportFiles,
    this.pickImportFolderPath,
    this.openExternalTarget,
    this.copyToClipboard,
    this.localReadinessDetectionEnabled = true,
  });

  final SidecarApi? api;
  final Future<String?> Function()? pickDataDirectoryPath;
  final Future<List<XFile>> Function()? pickImportFiles;
  final Future<String?> Function()? pickImportFolderPath;
  final Future<void> Function(String target)? openExternalTarget;
  final Future<void> Function(String text)? copyToClipboard;
  final bool localReadinessDetectionEnabled;

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  AppStep step = AppStep.child;
  bool sampleImported = false;
  bool sampleImporting = false;
  bool sampleImportFailed = false;
  bool generated = false;
  bool generating = false;
  bool exported = false;
  bool shareCreating = false;
  CreationWorkflowPhase creationWorkflowPhase = CreationWorkflowPhase.preparing;
  CreationTaskPreviewVm? creationTask;
  CreationFailureVm? creationFailure;
  List<CreationTaskStepVm> creationTaskSteps = const [];
  String generatedArtifactKind = '';
  String generatedArtifactPath = '';
  String previewFailureReason = '';
  String? taskId;
  String traceId = '';
  String requestId = '';
  String statusMessage = '';
  String readinessMessage = '';
  List<SetupCheckVm> readinessChecks = const [];
  List<Map<String, String>> searchTypeOptions = const [];
  List<String> generationTemplates = const [];
  List<String> generationPageSizes = const [];
  List<String> generationStyles = const [];
  List<String> generationExportTargets = const [];
  String generationCreationType = 'storybook';
  String generationTemplate = '';
  String generationPageSize = '';
  String generationStyle = '';
  String generationExportTarget = '';
  SupabaseStorageVm supabaseStorage = SupabaseStorageVm.empty;
  ExportResultVm? exportResult;
  final selectedAssets = <String>{};
  final activityLog = <String>[];
  List<ChildVm> children = const [];
  List<AssetVm> assets = const [];
  String? selectedChildId;
  String currentExportDir = _defaultKidMemoryPaths().exportDir;
  String? _supabaseStorageServiceRoleKeyCache;
  String? _supabaseStorageS3AccessKeyCache;
  String? _supabaseStorageS3SecretKeyCache;
  String? _openAiApiKeyCache;
  late final SidecarApi api;
  late final Future<String?> Function() pickDataDirectoryPath;
  late final Future<List<XFile>> Function() pickImportFiles;
  late final Future<String?> Function() pickImportFolderPath;
  late final Future<void> Function(String target) openExternalTarget;
  late final Future<void> Function(String text) copyToClipboard;
  late final _DesktopShellControllers controllers;
  late final SidecarLauncher sidecarLauncher;
  late final DesktopSidecarGateway gateway;
  late final DesktopTraceContext desktopTraceContext;
  late final DesktopLogger desktopLogger;
  late final DesktopLogCleanupWorker desktopLogCleanupWorker;
  Timer? _creationTaskPollingTimer;
  int _bundledPostgresPort = _pgDefaultPort;
  bool _localizedDefaultsInitialized = false;

  @override
  void initState() {
    super.initState();
    // Desktop always talks to the local sidecar fixed port. Avoid inheriting
    // accidental KIDMEMORY_SIDECAR_* env values from parent launch processes.
    api = widget.api ?? SidecarApi(baseUrl: 'http://127.0.0.1:4317');
    pickDataDirectoryPath =
        widget.pickDataDirectoryPath ?? _pickDataDirectoryPath;
    pickImportFiles = widget.pickImportFiles ?? _pickImportFiles;
    pickImportFolderPath = widget.pickImportFolderPath ?? _pickImportFolderPath;
    openExternalTarget =
        widget.openExternalTarget ?? _openExternalTargetDefault;
    copyToClipboard = widget.copyToClipboard ?? _copyTextToClipboardDefault;
    desktopTraceContext = DesktopTraceContext();
    desktopLogger = DesktopLogger();
    desktopLogCleanupWorker = DesktopLogCleanupWorker(
      logsDirectoryPath: desktopLogger.logsDirectoryPath,
    );
    controllers = _DesktopShellControllers(api: api);
    gateway = DesktopSidecarGateway(api);
    sidecarLauncher = SidecarLauncher(
      api: api,
      findExecutable: _findExecutable,
      ensureNodeAvailable: _ensureNodeAvailable,
      onLog: _appendLog,
      localizationsProvider: () => AppLocalizations.of(context),
      extraEnvironment: () => <String, String>{
        'POSTGRES_HOST': _pgDefaultLoopback,
        'POSTGRES_PORT': '$_bundledPostgresPort',
        'POSTGRES_DATABASE': _pgDefaultDatabase,
        'POSTGRES_USER': 'postgres',
      },
      onReadinessMessage: (message) {
        if (mounted) _setShellState(() => readinessMessage = message);
      },
    );
    unawaited(desktopLogCleanupWorker.cleanup(retainDays: 14));
    unawaited(
      desktopLogger.append(
        level: DesktopLogLevel.info,
        event: 'desktop.app.started',
        data: const {'source': 'desktop_shell.initState'},
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_bootstrapSidecarAndRefresh());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localizedDefaultsInitialized) return;
    _localizedDefaultsInitialized = true;
    readinessChecks = _disconnectedSetupChecks(context);
    statusMessage = AppLocalizations.of(
      context,
    )!.contentPreviewWaitingForGenerationLabel;
    searchTypeOptions = _defaultSearchTypeOptions(context);
    generationTemplates = _defaultGenerationTemplates(context);
    generationPageSizes = _defaultGenerationPageSizes(context);
    generationStyles = _defaultGenerationStyles(context);
    generationExportTargets = _defaultGenerationExportTargets(context);
    generationTemplate = AppLocalizations.of(context)!.desktopShellS696;
    generationPageSize = AppLocalizations.of(context)!.desktopShellS101;
    generationStyle = AppLocalizations.of(context)!.desktopShellS697;
    generationExportTarget = AppLocalizations.of(context)!.desktopShellS129;
    activityLog.addAll([
      AppLocalizations.of(context)!.desktopShellS89,
      AppLocalizations.of(context)!.desktopShellS90,
      AppLocalizations.of(context)!.desktopShellS91,
      AppLocalizations.of(context)!.desktopShellS92,
    ]);
  }

  void _setShellState(VoidCallback fn) {
    setState(fn);
    if (step != AppStep.generate) {
      _stopCreationTaskPolling();
    }
  }

  // Keep a local lifecycle fallback, but respect PG owner lock to avoid
  // stale DesktopShell instances stopping the new session database.
  void _stopBundledPostgresIfRunning() {
    final pgCtl = _bundledPostgresTool('pg_ctl');
    if (pgCtl == null) return;
    final dataDir = Directory(_bundledPostgresDataDir());
    if (!dataDir.existsSync()) return;
    final ownerFile = File(_bundledPostgresOwnerPath());
    final ownerPid = ownerFile.existsSync()
        ? ownerFile.readAsStringSync().trim()
        : '';
    if (ownerPid != '$pid') return;
    try {
      Process.runSync(
        pgCtl,
        ['-D', dataDir.path, 'stop', '-m', 'fast'],
        environment: {...Platform.environment, 'PATH': _setupCommandPath},
      );
      if (ownerFile.existsSync()) {
        ownerFile.deleteSync();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _stopCreationTaskPolling();
    _stopBundledPostgresIfRunning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xfff6f5f2),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xfff9f8f6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xffe7e2db)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Sidebar(
                    step: step,
                    navigationLocked: false,
                    hasChildProfile: children.isNotEmpty,
                    onStep: _handleStepSelection,
                  ),
                  Expanded(child: _page(step)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleStepSelection(AppStep next) {
    if (next == AppStep.assets && children.isEmpty) return;
    if (step == next) return;
    _setShellState(() => step = next);
  }

  Widget _page(AppStep effectiveStep) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: _pageForStep(effectiveStep),
    );
  }
}
