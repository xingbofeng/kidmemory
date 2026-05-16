import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';

import '../core/sidecar/sidecar_api.dart';
import '../core/sidecar/desktop_sidecar_gateway.dart';
import '../core/sidecar/sidecar_launcher.dart';
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
part 'setup/probes/probe_postgres.dart';
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
  bool generated = false;
  bool generating = false;
  bool exported = false;
  String? jobId;
  String traceId = '';
  String requestId = '';
  String statusMessage = '等待生成';
  String readinessMessage = _sidecarDisconnectedMessage;
  List<SetupCheckVm> readinessChecks = _disconnectedSetupChecks();
  List<Map<String, String>> searchTypeOptions = _defaultSearchTypeOptions;
  List<String> generationTemplates = _defaultGenerationTemplates;
  List<String> generationPageSizes = _defaultGenerationPageSizes;
  List<String> generationStyles = _defaultGenerationStyles;
  List<String> generationExportTargets = _defaultGenerationExportTargets;
  String generationTemplate = '温暖童趣';
  String generationPageSize = 'A4 竖版  210 × 297 mm';
  String generationStyle = '温暖童趣  亲切温暖，适合儿童阅读';
  String generationExportTarget = 'PDF 文件  高质量 PDF（打印级别）';
  SupabaseStorageVm supabaseStorage = SupabaseStorageVm.empty;
  ExportResultVm? exportResult;
  final selectedAssets = <String>{};
  final activityLog = <String>[
    '11:05:12  准备素材并构建 workspace',
    '11:05:18  调用 sidecar 生成任务',
    '11:05:28  校验 book.json 与 book.html',
    '11:05:52  等待预览 / PDF 导出',
  ];
  List<ChildVm> children = const [];
  List<AssetVm> assets = const [];
  String? selectedChildId;
  String currentExportDir = _defaultKidMemoryPaths().exportDir;
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
  bool _startupConfigurationGateChecked = false;
  bool _startupConfigurationRequired = true;

  bool get _navigationLocked =>
      _startupConfigurationGateChecked && _startupConfigurationRequired;

  AppStep get _effectiveStep => _navigationLocked ? AppStep.setup : step;

  @override
  void initState() {
    super.initState();
    api = widget.api ?? SidecarApi();
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
      runInstallCommand: _runInstallCommand,
      onLog: _appendLog,
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
    unawaited(_bootstrapSidecarAndRefresh());
  }

  void _setShellState(VoidCallback fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    final effectiveStep = _effectiveStep;
    final navigationLocked = _navigationLocked;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfff5a35c), Color(0xfffffbf5), Color(0xff6aa7df)],
            stops: [0, 0.22, 1],
          ),
        ),
        child: SafeArea(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xfffffbf5),
              border: Border.all(color: const Color(0x22a67c52)),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 28),
              ],
            ),
            child: Row(
              children: [
                Sidebar(
                  step: effectiveStep,
                  navigationLocked: navigationLocked,
                  onStep: _handleStepSelection,
                ),
                Expanded(child: _page(effectiveStep)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStepSelection(AppStep next) {
    if (_navigationLocked && next != AppStep.setup) return;
    if (step == next) return;
    setState(() => step = next);
  }

  Widget _page(AppStep effectiveStep) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: _pageForStep(effectiveStep),
    );
  }
}
