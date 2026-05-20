import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../l10n/app_localizations.dart';
import '../setup/setup_page.dart';
import 'generate_export_page.dart';

@Preview(
  group: 'Supabase Storage',
  name: 'Setup Preview',
  size: Size(1440, 900),
)
Widget supabaseStorageSetupPreview() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          body: SetupPage(
            readinessMessage: l10n.generateExportPreviewReadinessMessage,
            checks: [
              SetupCheckVm(
                index: '1',
                title: l10n.generateExportPreviewSetupUrlTitle,
                body: l10n.generateExportPreviewSetupUrlBody,
                action: l10n.actionTestConnection,
                state: l10n.generateExportPreviewStateDetected,
                ok: true,
              ),
              SetupCheckVm(
                index: '2',
                title: l10n.generateExportPreviewSetupBucketTitle,
                body: l10n.generateExportPreviewSetupBucketBody,
                action: l10n.generateExportPreviewActionOpen,
                state: l10n.generateExportPreviewStateConfigured,
                ok: true,
              ),
              SetupCheckVm(
                index: '3',
                title: l10n.generateExportPreviewSetupPermissionTitle,
                body: l10n.generateExportPreviewSetupPermissionBody,
                action: l10n.actionTestConnection,
                state: l10n.generateExportPreviewStatePassed,
                ok: true,
              ),
              SetupCheckVm(
                index: '4',
                title: l10n.generateExportPreviewSetupSignatureTitle,
                body: l10n.generateExportPreviewSetupSignatureBody,
                action: l10n.actionConfigure,
                state: l10n.generateExportPreviewStateNormal,
                ok: true,
              ),
              SetupCheckVm(
                index: '5',
                title: l10n.generateExportPreviewSetupConnectionTitle,
                body: l10n.generateExportPreviewSetupConnectionBody,
                action: l10n.actionRetryLabel,
                state: l10n.generateExportPreviewStateConnected,
                ok: true,
              ),
            ],
            supabaseStorage: SupabaseStorageVm(
              configured: true,
              url: 'https://project.supabase.co',
              bucket: 'kidmemory-exports',
              serviceRoleKeyConfigured: true,
              publicBaseUrl: '',
              signedUrlTtlSeconds: 3600,
              testMessage: l10n.generateExportPreviewSignedUrlPassed,
            ),
            onSetupAction: _previewSetupNoop,
            onRefreshReadiness: _previewNoop,
            onOpenDirectory: _previewStringNoop,
            onConfigureSupabaseStorage: _previewNoop,
            onTestSupabaseStorage: _previewNoop,
          ),
        );
      },
    ),
  );
}

@Preview(
  group: 'Supabase Storage',
  name: 'Long Image Preview',
  size: Size(1440, 900),
)
Widget longImageExportPreview() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          body: GenerateExportPage(
            selectedCount: 8,
            generated: true,
            generating: false,
            exported: true,
            creationPhase: CreationWorkflowPhase.published,
            statusMessage: l10n.generateExportPreviewExportCompleted,
            requestId: 'req_123456',
            logLines: [
              l10n.generateExportPreviewLogReadingSamples,
              l10n.generateExportPreviewLogCoverGenerated,
              l10n.generateExportPreviewLogExportSubmitted,
            ],
            templateOptions: [
              l10n.generationTemplateWarmChildhood,
              l10n.generationTemplateFairyTaleMemory,
              l10n.generationTemplateSimpleDocumentary,
            ],
            pageSizeOptions: [l10n.generateExportDefaultPageSize],
            styleOptions: [l10n.generateExportDefaultStyle],
            exportTargetOptions: [
              l10n.generateExportPreviewExportImage,
              l10n.generateExportPreviewExportPdf,
              l10n.generateExportPreviewExportLongImage,
            ],
            selectedTemplate: l10n.generationTemplateWarmChildhood,
            selectedPageSize: l10n.generateExportPreviewSelectedPageSize,
            selectedStyle: l10n.generateExportPreviewSelectedStyle,
            selectedExportTarget: l10n.generateExportPreviewExportLongImage,
            exportResult: ExportResultVm(
              kind: 'long_image_jpg',
              localPath: '/tmp/kidmemory/job_123456.jpg',
              storageStatus: 'synced',
              remoteUrl: 'https://project.supabase.co/signed/job_123456.jpg',
              shareText: l10n.generateExportPreviewShareText(
                'https://project.supabase.co/signed/job_123456.jpg',
                3600,
              ),
            ),
            onGenerate: _previewNoop,
            onConfirmPlan: _previewNoop,
            onExport: _previewNoop,
            onExportTargetChanged: _previewStringNoop,
            onOpenExportFolder: _previewNoop,
            onCopyShareText: _previewNoop,
            onCopyLongImage: _previewNoop,
          ),
        );
      },
    ),
  );
}

void _previewNoop() {}

void _previewSetupNoop(SetupCheckVm _) {}

void _previewStringNoop(String _) {}
