part of '../desktop_shell.dart';

extension _DesktopShellReadinessStorage on _DesktopShellState {
  SupabaseStorageVm _supabaseStorageFromConfig(
    ReadinessConfig config, {
    required SupabaseStorageVm previous,
  }) {
    final storage = config.supabaseStorageConfig;
    if (!storage.configuredValue &&
        storage.urlValue.isEmpty &&
        storage.bucketValue.isEmpty &&
        !storage.serviceRoleKeyConfiguredValue &&
        !storage.s3CredentialsDetectedValue &&
        storage.diagnosticMessageValue.isEmpty &&
        storage.authModeValue.isEmpty) {
      return previous.copyWith(configured: false);
    }
    return SupabaseStorageVm(
      configured:
          storage.configuredValue ||
          (storage.urlValue.trim().isNotEmpty &&
              storage.bucketValue.trim().isNotEmpty &&
              storage.serviceRoleKeyConfiguredValue),
      provider: storage.providerValue.trim().isEmpty
          ? 'supabase'
          : storage.providerValue.trim(),
      url: storage.urlValue.trim(),
      bucket: storage.bucketValue.trim(),
      serviceRoleKeyConfigured: storage.serviceRoleKeyConfiguredValue,
      publicBaseUrl: storage.publicBaseUrlValue.trim(),
      signedUrlTtlSeconds: storage.signedUrlTtlSecondsValue,
      s3CredentialsDetected: storage.s3CredentialsDetectedValue,
      s3Endpoint: storage.s3Config.endpointValue.trim(),
      s3Region: storage.s3Config.regionValue.trim(),
      s3AccessKeyConfigured: storage.s3Config.accessKeyConfigured,
      s3SecretKeyConfigured: storage.s3Config.secretKeyConfigured,
      authMode: storage.authModeValue.trim(),
      diagnosticMessage: storage.diagnosticMessageValue.trim(),
      testMessage: previous.testMessage,
      testing: previous.testing,
    );
  }
}
