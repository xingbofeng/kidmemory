import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../setup/setup_page.dart';
import 'generate_export_page.dart';

@Preview(group: 'Supabase Storage', name: 'Setup Preview', size: Size(1440, 900))
Widget supabaseStorageSetupPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SetupPage(
        readinessMessage: '准备完成：可继续开始导出',
        checks: [
          SetupCheckVm(
            index: '1',
            title: '1. 配置 Supabase URL',
            body: '确认已填写项目 URL 与密钥。',
            action: '测试',
            state: '已检测',
            ok: true,
          ),
          SetupCheckVm(
            index: '2',
            title: '2. 配置 Bucket',
            body: '确认导出数据 Bucket 已创建。',
            action: '前往',
            state: '已配置',
            ok: true,
          ),
          SetupCheckVm(
            index: '3',
            title: '3. 存储权限',
            body: '确认服务角色密钥权限可用于存储读写。',
            action: '测试',
            state: '通过',
            ok: true,
          ),
          SetupCheckVm(
            index: '4',
            title: '4. 目录与签名',
            body: '确认 URL 签名有效期配置符合预期。',
            action: '配置',
            state: '正常',
            ok: true,
          ),
          SetupCheckVm(
            index: '5',
            title: '5. 连接测试',
            body: '已成功尝试连接导出服务。',
            action: '重试',
            state: '连接成功',
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
          testMessage: '签名 URL 校验通过',
        ),
        onSetupAction: _previewSetupNoop,
        onRefreshReadiness: _previewNoop,
        onOpenDirectory: _previewStringNoop,
        onConfigureSupabaseStorage: _previewNoop,
        onTestSupabaseStorage: _previewNoop,
      ),
    ),
  );
}

@Preview(group: 'Supabase Storage', name: 'Long Image Preview', size: Size(1440, 900))
Widget longImageExportPreview() {
  return MaterialApp(
    home: Scaffold(
      body: GenerateExportPage(
        selectedCount: 8,
        generated: true,
        generating: false,
        exported: true,
        statusMessage: '导出任务已完成',
        requestId: 'req_123456',
        logLines: [
          '正在读取样本',
          '已生成封面',
          '导出任务提交成功',
        ],
        templateOptions: const ['温暖童趣', '童话式成长记忆', '简约纪实'],
        pageSizeOptions: const ['A4 竖版  210 × 297 mm'],
        styleOptions: const ['温暖童趣  亲切温暖，适合儿童阅读'],
        exportTargetOptions: [
          '导出为图片',
          '导出为 PDF',
          '导出为长图',
        ],
        selectedTemplate: '温暖童趣',
        selectedPageSize: 'A4 竖版',
        selectedStyle: '自然温和',
        selectedExportTarget: '导出为长图',
        exportResult: const ExportResultVm(
          kind: 'long_image_jpg',
          localPath: '/tmp/kidmemory/job_123456.jpg',
          storageStatus: 'synced',
          remoteUrl: 'https://project.supabase.co/signed/job_123456.jpg',
          shareText:
              'KidMemory 作品集：https://project.supabase.co/signed/job_123456.jpg\n链接有效期：3600 秒',
        ),
        onGenerate: _previewNoop,
        onGenerateSkipCover: _previewNoop,
        onExport: _previewNoop,
        onExportTargetChanged: _previewStringNoop,
        onOpenExportFolder: _previewNoop,
        onCopyShareText: _previewNoop,
        onCopyLongImage: _previewNoop,
      ),
    ),
  );
}

void _previewNoop() {}

void _previewSetupNoop(SetupCheckVm _) {}

void _previewStringNoop(String _) {}
