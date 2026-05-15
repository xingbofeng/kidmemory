part of '../../desktop_shell.dart';

extension _DesktopShellSetupDialogStorageSubmit on _DesktopShellState {
  Future<void> _submitSupabaseStorageConfig({
    required TextEditingController urlController,
    required TextEditingController bucketController,
    required TextEditingController publicBaseUrlController,
    required TextEditingController ttlController,
    required TextEditingController serviceRoleKeyController,
    required TextEditingController s3EndpointController,
    required TextEditingController s3RegionController,
    required TextEditingController s3AccessKeyController,
    required TextEditingController s3SecretKeyController,
  }) async {
    final draft = _SupabaseStorageConfigDraft.fromControllers(
      url: urlController,
      bucket: bucketController,
      serviceRoleKey: serviceRoleKeyController,
      publicBaseUrl: publicBaseUrlController,
      signedUrlTtlSeconds: ttlController,
      s3Endpoint: s3EndpointController,
      s3Region: s3RegionController,
      s3AccessKeyId: s3AccessKeyController,
      s3SecretAccessKey: s3SecretKeyController,
    );
    final result = await gateway.configureSupabaseStorageDto(
      payload: SupabaseStorageConfigRequest(
        url: draft.url,
        bucket: draft.bucket,
        serviceRoleKey: draft.serviceRoleKey.isEmpty
            ? null
            : draft.serviceRoleKey,
        publicBaseUrl: draft.publicBaseUrl,
        signedUrlTtlSeconds: draft.signedUrlTtlSeconds,
        s3Endpoint: draft.s3Endpoint,
        s3Region: draft.s3Region,
        s3AccessKeyId: draft.s3AccessKeyId.isEmpty
            ? null
            : draft.s3AccessKeyId,
        s3SecretAccessKey: draft.s3SecretAccessKey.isEmpty
            ? null
            : draft.s3SecretAccessKey,
      ),
    );
    if (!mounted) return;
    _setShellState(() {
      supabaseStorage = _supabaseStorageFromConfig(
        ReadinessConfigDto.fromJson({
          'supabaseStorage': result.config.raw,
        }),
        previous: supabaseStorage,
      );
    });
    _showSnackBar(
      result.ok
          ? 'Supabase Storage 配置已保存'
          : 'Supabase Storage 配置保存失败',
    );
    await refreshReadiness();
  }
}
