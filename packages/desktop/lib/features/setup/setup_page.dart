import 'package:flutter/material.dart';

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
  final void Function(SetupCheckVm check) onSetupAction;
  final VoidCallback onRefreshReadiness;
  final void Function(String path) onOpenDirectory;
  final VoidCallback onConfigureSupabaseStorage;
  final VoidCallback onTestSupabaseStorage;

  static const pendingChecks = [
    SetupCheckVm(
      index: '1',
      title: '大模型接口配置',
      body: '提供文本生成、标签与提示词能力。请配置 Base URL、模型与 API Key。',
      action: '测试连接',
      state: '需配置',
      secondaryActionLabel: '修改配置',
      secondaryActionPath: '__action__:配置',
      actionEnabled: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleChecks = checks.isEmpty ? pendingChecks : checks;
    return PageFrame(
      title: '设置',
      subtitle: '完成以下配置以启用 AI 能力与本地数据存储。我们会帮你检测环境并确保一切就绪。',
      status: null,
      child: Column(
        children: [
          _readinessBanner(readinessMessage, onRefreshReadiness),
          const SizedBox(height: 18),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : (constraints.maxWidth >= 620 ? 2 : 1);
                const gridSpacing = 18.0;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: columns,
                        childAspectRatio: columns == 3 ? 1.16 : 1.22,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ...visibleChecks.map(
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
                              secondaryActionLabel: check.secondaryActionLabel,
                              onSecondaryAction:
                                  check.secondaryActionPath == null
                                  ? null
                                  : () {
                                      final marker = check.secondaryActionPath!;
                                      if (marker.startsWith('__action__:')) {
                                        final action = marker.substring(
                                          '__action__:'.length,
                                        );
                                        onSetupAction(
                                          SetupCheckVm(
                                            index: check.index,
                                            title: check.title,
                                            body: check.body,
                                            action: action,
                                            state: check.state,
                                            ok: check.ok,
                                            secondaryActionLabel:
                                                check.secondaryActionLabel,
                                            secondaryActionPath:
                                                check.secondaryActionPath,
                                            progress: check.progress,
                                            progressLabel: check.progressLabel,
                                            actionEnabled: true,
                                          ),
                                        );
                                        return;
                                      }
                                      if (!check.actionEnabled) return;
                                      onOpenDirectory(marker);
                                    },
                            ),
                          ),
                          _SupabaseStoragePanel(
                            storage: supabaseStorage,
                            onConfigure: onConfigureSupabaseStorage,
                            onTest: onTestSupabaseStorage,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
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
    final backgroundColor = configured
        ? const Color(0xffedf7ee)
        : const Color(0xfffcfbf9);
    final borderColor = configured
        ? const Color(0xffbfe4c6)
        : const Color(0xffe7e2da);
    final description = '用于保存导出结果与分享文件。';

    return SurfaceCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SetupLeadingBadge(
                icon: Icons.archive_outlined,
                color: foregroundColor,
                backgroundColor: configured
                    ? const Color(0xffeef8f0)
                    : const Color(0xfffff4e5),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Storage 配置',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      configured ? '已配置' : '未配置',
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xffe8e0d5)),
          const SizedBox(height: 18),
          Text(
            description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.45),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: '修改配置',
                  icon: Icons.settings_outlined,
                  fullWidth: true,
                  height: 52,
                  onPressed: onConfigure,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryButton(
                  label: '测试连接',
                  icon: Icons.link_rounded,
                  fullWidth: true,
                  height: 52,
                  onPressed: configured && !storage.testing ? onTest : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _readinessBanner(String message, VoidCallback onRefreshReadiness) {
  final disconnected = message.startsWith('Sidecar 未连接');
  final ready = _readinessComplete(message);
  final title = disconnected ? '本地服务准备中' : (ready ? '环境已就绪' : '环境检测中');
  final actionLabel = disconnected ? '重新连接' : '刷新检测';
  final body = disconnected
      ? 'KidMemory 的本地服务负责配置、检测和数据任务。通常会随应用自动准备。'
      : (ready ? '环境检测已通过，可进入正式创作流程。' : '集中检查初始化依赖是否可用。');
  final backgroundColor = const Color(0xfff5f8f6);
  final borderColor = const Color(0xffdce8df);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SecondaryButton(
                    label: actionLabel,
                    onPressed: onRefreshReadiness,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SetupLeadingBadge extends StatelessWidget {
  const _SetupLeadingBadge({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffd4e6d8)),
      ),
      child: Icon(icon, size: 31, color: color),
    );
  }
}

bool _readinessComplete(String value) {
  final match = RegExp(r'已完成\s+(\d+)\s*/\s*(\d+)').firstMatch(value);
  if (match == null) return false;
  final done = int.tryParse(match.group(1) ?? '');
  final total = int.tryParse(match.group(2) ?? '');
  return done != null && total != null && total > 0 && done >= total;
}
