part of '../desktop_shell.dart';

class _ReadinessSnapshot {
  const _ReadinessSnapshot({
    required this.uiConfig,
    required this.config,
    required this.schema,
    required this.postgres,
    required this.pgvector,
    required this.openai,
  });

  factory _ReadinessSnapshot.unavailable({
    required Map<String, dynamic> uiConfig,
  }) {
    return _ReadinessSnapshot(
      uiConfig: uiConfig,
      config: const ReadinessConfigDto(
        raw: {},
        pathConfig: PathConfigDto(dataDir: '', workspaceDir: '', exportDir: ''),
        openAiConfig: OpenAiConfigDto(baseUrl: '', model: ''),
        supabaseStorageConfig: SupabaseStorageConfigDto(
          raw: {},
          configured: false,
          url: '',
          bucket: '',
          serviceRoleKeyConfigured: false,
          publicBaseUrl: '',
          signedUrlTtlSeconds: 3600,
          s3CredentialsDetected: false,
          authMode: '',
          diagnosticMessage: '',
          s3: SupabaseS3ConfigDto(
            endpoint: '',
            region: '',
            accessKeyConfigured: false,
            secretKeyConfigured: false,
          ),
        ),
      ),
      schema: const ReadinessCheckDto(raw: {}),
      postgres: const ReadinessCheckDto(raw: {}),
      pgvector: const ReadinessCheckDto(raw: {}),
      openai: const ReadinessCheckDto(raw: {}),
    );
  }

  final Map<String, dynamic> uiConfig;
  final ReadinessConfigDto config;
  final ReadinessCheckDto schema;
  final ReadinessCheckDto postgres;
  final ReadinessCheckDto pgvector;
  final ReadinessCheckDto openai;

  bool get available => config.raw.isNotEmpty;
}

class _DatasetSnapshot {
  const _DatasetSnapshot({
    required this.children,
    required this.activeChildId,
    required this.assetRows,
  });

  final List<ChildVm> children;
  final String? activeChildId;
  final List<AssetRecordDto> assetRows;
}
