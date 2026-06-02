part of '../../desktop_shell.dart';

extension _DesktopShellSetupDialogStorageSubmit on _DesktopShellState {
  Future<void> _submitSupabaseStorageConfig({
    required String provider,
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
      provider: provider,
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
      payload: SupabaseStorageConfigInput(
        provider: draft.provider,
        url: draft.url,
        bucket: draft.bucket,
        serviceRoleKey: draft.serviceRoleKey,
        publicBaseUrl: draft.publicBaseUrl,
        signedUrlTtlSeconds: draft.signedUrlTtlSeconds,
        s3Endpoint: draft.s3Endpoint,
        s3Region: draft.s3Region,
        s3AccessKeyId: draft.s3AccessKeyId,
        s3SecretAccessKey: draft.s3SecretAccessKey,
      ),
    );
    if (!mounted) return;
    _supabaseStorageServiceRoleKeyCache = draft.serviceRoleKey;
    _supabaseStorageS3AccessKeyCache = draft.s3AccessKeyId;
    _supabaseStorageS3SecretKeyCache = draft.s3SecretAccessKey;
    _setShellState(() {
      supabaseStorage = _supabaseStorageFromConfig(
        ReadinessConfig.fromJson({'supabaseStorage': result.configValue.raw}),
        previous: supabaseStorage,
      );
    });
    _showSnackBar(
      result.okValue
          ? AppLocalizations.of(context)!.setupStorageConfigSaved
          : AppLocalizations.of(context)!.setupStorageConfigSaveFailed,
    );
    await refreshReadiness();
  }
}
