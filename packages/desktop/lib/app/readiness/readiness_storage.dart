part of '../desktop_shell.dart';

extension _DesktopShellReadinessStorage on _DesktopShellState {
  SupabaseStorageVm _supabaseStorageFromConfig(
    ReadinessConfigDto config, {
    required SupabaseStorageVm previous,
  }) {
    final storage = config.supabaseStorageConfig;
    if (!storage.configured &&
        storage.url.isEmpty &&
        storage.bucket.isEmpty &&
        !storage.serviceRoleKeyConfigured &&
        !storage.s3CredentialsDetected &&
        storage.diagnosticMessage.isEmpty &&
        storage.authMode.isEmpty) {
      return previous.copyWith(configured: false);
    }
    return SupabaseStorageVm(
      configured:
          storage.configured ||
          (storage.url.trim().isNotEmpty &&
              storage.bucket.trim().isNotEmpty &&
              storage.serviceRoleKeyConfigured),
      url: storage.url.trim(),
      bucket: storage.bucket.trim(),
      serviceRoleKeyConfigured: storage.serviceRoleKeyConfigured,
      publicBaseUrl: storage.publicBaseUrl.trim(),
      signedUrlTtlSeconds: storage.signedUrlTtlSeconds,
      s3CredentialsDetected: storage.s3CredentialsDetected,
      s3Endpoint: storage.s3.endpoint.trim(),
      s3Region: storage.s3.region.trim(),
      s3AccessKeyConfigured: storage.s3.accessKeyConfigured,
      s3SecretKeyConfigured: storage.s3.secretKeyConfigured,
      authMode: storage.authMode.trim(),
      diagnosticMessage: storage.diagnosticMessage.trim(),
      testMessage: previous.testMessage,
      testing: previous.testing,
    );
  }
}
