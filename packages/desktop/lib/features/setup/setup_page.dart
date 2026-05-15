import 'package:flutter/material.dart';

import '../../shared/widgets/chrome.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/layout.dart';

class SetupCheckVm {
  const SetupCheckVm({
    required this.index,
    required this.title,
    required this.body,
    required this.action,
    required this.state,
    this.ok,
    this.secondaryActionLabel,
    this.secondaryActionPath,
    this.progress,
    this.progressLabel,
    this.actionEnabled = true,
  });

  final String index;
  final String title;
  final String body;
  final String action;
  final String state;
  final bool? ok;
  final String? secondaryActionLabel;
  final String? secondaryActionPath;
  final double? progress;
  final String? progressLabel;
  final bool actionEnabled;
}

class SupabaseStorageVm {
  const SupabaseStorageVm({
    required this.configured,
    required this.url,
    required this.bucket,
    required this.serviceRoleKeyConfigured,
    required this.publicBaseUrl,
    required this.signedUrlTtlSeconds,
    this.s3CredentialsDetected = false,
    this.s3Endpoint = '',
    this.s3Region = '',
    this.s3AccessKeyConfigured = false,
    this.s3SecretKeyConfigured = false,
    this.authMode = 'none',
    this.diagnosticMessage = '',
    this.testMessage = '',
    this.testing = false,
  });

  final bool configured;
  final String url;
  final String bucket;
  final bool serviceRoleKeyConfigured;
  final String publicBaseUrl;
  final int signedUrlTtlSeconds;
  final bool s3CredentialsDetected;
  final String s3Endpoint;
  final String s3Region;
  final bool s3AccessKeyConfigured;
  final bool s3SecretKeyConfigured;
  final String authMode;
  final String diagnosticMessage;
  final String testMessage;
  final bool testing;

  static const empty = SupabaseStorageVm(
    configured: false,
    url: '',
    bucket: '',
    serviceRoleKeyConfigured: false,
    publicBaseUrl: '',
    signedUrlTtlSeconds: 3600,
  );

  SupabaseStorageVm copyWith({
    bool? configured,
    String? url,
    String? bucket,
    bool? serviceRoleKeyConfigured,
    String? publicBaseUrl,
    int? signedUrlTtlSeconds,
    bool? s3CredentialsDetected,
    String? s3Endpoint,
    String? s3Region,
    bool? s3AccessKeyConfigured,
    bool? s3SecretKeyConfigured,
    String? authMode,
    String? diagnosticMessage,
    String? testMessage,
    bool? testing,
  }) {
    return SupabaseStorageVm(
      configured: configured ?? this.configured,
      url: url ?? this.url,
      bucket: bucket ?? this.bucket,
      serviceRoleKeyConfigured:
          serviceRoleKeyConfigured ?? this.serviceRoleKeyConfigured,
      publicBaseUrl: publicBaseUrl ?? this.publicBaseUrl,
      signedUrlTtlSeconds: signedUrlTtlSeconds ?? this.signedUrlTtlSeconds,
      s3CredentialsDetected:
          s3CredentialsDetected ?? this.s3CredentialsDetected,
      s3Endpoint: s3Endpoint ?? this.s3Endpoint,
      s3Region: s3Region ?? this.s3Region,
      s3AccessKeyConfigured:
          s3AccessKeyConfigured ?? this.s3AccessKeyConfigured,
      s3SecretKeyConfigured:
          s3SecretKeyConfigured ?? this.s3SecretKeyConfigured,
      authMode: authMode ?? this.authMode,
      diagnosticMessage: diagnosticMessage ?? this.diagnosticMessage,
      testMessage: testMessage ?? this.testMessage,
      testing: testing ?? this.testing,
    );
  }
}

class SetupPage extends StatelessWidget {
  const SetupPage({
    required this.readinessMessage,
    required this.checks,
    required this.supabaseStorage,
    required this.onContinue,
    required this.onSetupAction,
    required this.onRefreshReadiness,
    required this.onOpenDirectory,
    required this.onConfigureSupabaseStorage,
    required this.onTestSupabaseStorage,
    super.key,
  });

  final String readinessMessage;
  final List<SetupCheckVm> checks;
  final SupabaseStorageVm supabaseStorage;
  final VoidCallback onContinue;
  final void Function(SetupCheckVm check) onSetupAction;
  final VoidCallback onRefreshReadiness;
  final void Function(String path) onOpenDirectory;
  final VoidCallback onConfigureSupabaseStorage;
  final VoidCallback onTestSupabaseStorage;

  static const pendingChecks = [
    SetupCheckVm(
      index: '1',
      title: 'PostgreSQL 配置',
      body: 'KidMemory 的本地资料库，保存孩子档案、素材元数据和任务记录。',
      action: '安装与配置',
      state: '需配置',
      ok: false,
    ),
    SetupCheckVm(
      index: '2',
      title: 'Sidecar 本地服务',
      body: '负责配置检测、数据库初始化、素材导入和生成任务。PostgreSQL 就绪后会自动启动。',
      action: '启动 Sidecar',
      state: '等待 PG',
      ok: false,
      actionEnabled: false,
    ),
    SetupCheckVm(
      index: '3',
      title: 'pgvector 检测',
      body: 'pgvector 是 PostgreSQL 的独立扩展，用于语义检索和相似内容匹配。',
      action: '安装与配置',
      state: '需配置',
      ok: false,
      actionEnabled: false,
    ),
    SetupCheckVm(
      index: '4',
      title: 'OpenAI-compatible API',
      body: '提供文本生成、讲故事、标签与提示词能力。',
      action: '配置',
      state: '需配置',
      actionEnabled: false,
    ),
    SetupCheckVm(
      index: '5',
      title: '本地数据目录',
      body: '保存本地数据与运行文件，支持迁移与备份。',
      action: '配置目录',
      secondaryActionLabel: '打开目录',
      state: '待检测',
      actionEnabled: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleChecks = checks.isEmpty ? pendingChecks : checks;
    final ready = _readinessComplete(readinessMessage);
    final banner = _readinessBanner(readinessMessage, onRefreshReadiness);
    return PageFrame(
      title: '设置',
      subtitle: '完成以下配置以启用 AI 能力与本地数据存储。我们会帮你检测环境并确保一切就绪。',
      status: null,
      decoration: const ProjectIconMark(size: 86),
      child: Column(
        children: [
          banner,
          const SizedBox(height: 18),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 3 : 2;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.count(
                        crossAxisCount: columns,
                        childAspectRatio: columns == 3 ? 1.66 : 1.48,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: visibleChecks
                            .map(
                              (check) => SetupCard(
                                index: check.index,
                                title: check.title,
                                body: check.body,
                                action: check.action,
                                state: check.state,
                                healthy: check.ok,
                                progress: check.progress,
                                progressLabel: check.progressLabel,
                                actionEnabled: check.actionEnabled,
                                onAction: check.action == '重新连接'
                                    ? onRefreshReadiness
                                    : () => onSetupAction(check),
                                secondaryActionLabel:
                                    check.secondaryActionLabel,
                                onSecondaryAction:
                                    check.secondaryActionPath == null ||
                                        !check.actionEnabled
                                    ? null
                                    : () => onOpenDirectory(
                                        check.secondaryActionPath!,
                                      ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 18),
                      _SupabaseStoragePanel(
                        storage: supabaseStorage,
                        onConfigure: onConfigureSupabaseStorage,
                        onTest: onTestSupabaseStorage,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: ready ? '开始使用 KidMemory' : '请完成配置后开始使用KidMemory',
            icon: Icons.wb_sunny_rounded,
            iconAsset: sunIconAsset,
            onPressed: ready ? onContinue : null,
          ),
        ],
      ),
    );
  }
}

class _SupabaseStoragePanel extends StatelessWidget {
  const _SupabaseStoragePanel({
    required this.storage,
    required this.onConfigure,
    required this.onTest,
  });

  final SupabaseStorageVm storage;
  final VoidCallback onConfigure;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final configured = storage.configured;
    final foregroundColor = configured
        ? const Color(0xff20954d)
        : const Color(0xff9a5a14);
    final strategy = storage.publicBaseUrl.trim().isEmpty
        ? '私有 bucket，分享时生成签名 URL'
        : '公开 URL：${storage.publicBaseUrl}';
    final testText = storage.testing
        ? '正在测试连接...'
        : storage.testMessage.trim().isEmpty
        ? '尚未测试'
        : storage.testMessage.trim();
    final authModeLabel = switch (storage.authMode) {
      'rest' => 'REST / Service Role',
      's3' => 'S3 协议',
      _ => storage.s3CredentialsDetected ? 'S3 未完成' : '未配置',
    };
    final credentialText = storage.authMode == 's3'
        ? (storage.s3AccessKeyConfigured && storage.s3SecretKeyConfigured
              ? 'S3 Key 已配置'
              : 'S3 Key 未配置')
        : (storage.serviceRoleKeyConfigured ? '已配置' : '未配置');
    final disabledReason = configured
        ? ''
        : '未填写 REST 配置，或未补齐 S3 Endpoint、Bucket 和 S3 Key 前不能测试连接';
    final diagnosticMessage = storage.diagnosticMessage.trim();
    final setupMessage = diagnosticMessage.isNotEmpty
        ? diagnosticMessage
        : disabledReason;

    return SurfaceCard(
      backgroundColor: configured
          ? const Color(0xffedf7ee)
          : const Color(0xfffff1dd),
      borderColor: configured
          ? const Color(0xffbfe4c6)
          : const Color(0xfff0cf8a),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: foregroundColor.withValues(alpha: 0.12),
                child: Icon(Icons.cloud_done_outlined, color: foregroundColor),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Supabase Storage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  configured ? '已配置' : '未配置',
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 28,
            runSpacing: 8,
            children: [
              _StorageFact(label: 'URL', value: _fallback(storage.url)),
              _StorageFact(label: 'Bucket', value: _fallback(storage.bucket)),
              _StorageFact(label: '认证模式', value: authModeLabel),
              _StorageFact(
                label: storage.authMode == 's3' ? 'S3 凭据' : 'Service Role Key',
                value: credentialText,
              ),
              if (storage.s3Endpoint.trim().isNotEmpty)
                _StorageFact(label: 'S3 Endpoint', value: storage.s3Endpoint),
              if (storage.s3Region.trim().isNotEmpty)
                _StorageFact(label: 'S3 Region', value: storage.s3Region),
              _StorageFact(label: 'URL 策略', value: strategy),
              _StorageFact(
                label: '签名有效期',
                value: '${storage.signedUrlTtlSeconds} 秒',
              ),
              _StorageFact(label: '最近测试', value: testText),
            ],
          ),
          if (setupMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              setupMessage,
              style: const TextStyle(
                color: Color(0xff8c7663),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (!configured) ...[
            const SizedBox(height: 10),
            const Text(
              '配置提示：S3 模式通常只需要 endpoint、region、bucket、access key 和 secret key。bucket 建议保持私有，KidMemory 会在分享时自动生成带有效期的链接。',
              style: TextStyle(
                color: Color(0xff8c7663),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(
                label: '配置存储',
                icon: Icons.settings_outlined,
                onPressed: onConfigure,
              ),
              SecondaryButton(
                label: '测试连接',
                icon: Icons.cloud_sync_outlined,
                onPressed: configured && !storage.testing ? onTest : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fallback(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '未填写' : trimmed;
  }
}

class _StorageFact extends StatelessWidget {
  const _StorageFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Text(
      '$label：$value',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xff5d5148),
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

Widget _readinessBanner(String message, VoidCallback onRefreshReadiness) {
  final disconnected = message.startsWith('Sidecar 未连接');
  final ready = _readinessComplete(message);
  final title = disconnected ? '本地服务准备中' : (ready ? '环境已就绪' : '环境检测中');
  final actionLabel = disconnected ? '重新连接' : '刷新检测';
  final body = disconnected
      ? 'KidMemory 的本地服务负责配置、检测和数据任务。通常会随应用自动准备。'
      : (ready ? '环境检测已通过，可进入正式创作流程。' : '集中检查初始化依赖是否可用。');
  final backgroundColor = disconnected || !ready
      ? const Color(0xfffff1dd)
      : const Color(0xffedf7ee);
  final borderColor = disconnected || !ready
      ? const Color(0xfff0cf8a)
      : const Color(0xffbfe4c6);
  final foregroundColor = disconnected || !ready
      ? const Color(0xff9a5a14)
      : const Color(0xff20954d);
  final icon = disconnected || !ready
      ? Icons.priority_high_rounded
      : Icons.check_circle_rounded;

  return SurfaceCard(
    backgroundColor: backgroundColor,
    borderColor: borderColor,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: foregroundColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: foregroundColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: const TextStyle(color: Color(0xff6f6258), height: 1.45),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: SecondaryButton(
                  label: actionLabel,
                  onPressed: onRefreshReadiness,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

bool _readinessComplete(String value) {
  final match = RegExp(r'已完成\s+(\d+)\s*/\s*(\d+)').firstMatch(value);
  if (match == null) return false;
  final done = int.tryParse(match.group(1) ?? '');
  final total = int.tryParse(match.group(2) ?? '');
  return done != null && total != null && total > 0 && done >= total;
}
