part of '../../desktop_shell.dart';

class _OpenAiConfigDraft {
  const _OpenAiConfigDraft({
    required this.baseUrl,
    required this.model,
    required this.apiKey,
  });

  factory _OpenAiConfigDraft.fromControllers({
    required TextEditingController baseUrl,
    required TextEditingController model,
    required TextEditingController apiKey,
  }) {
    return _OpenAiConfigDraft(
      baseUrl: baseUrl.text.trim(),
      model: model.text.trim(),
      apiKey: apiKey.text.trim(),
    );
  }

  final String baseUrl;
  final String model;
  final String apiKey;
}

class _SupabaseStorageConfigDraft {
  const _SupabaseStorageConfigDraft({
    required this.provider,
    required this.url,
    required this.bucket,
    required this.serviceRoleKey,
    required this.publicBaseUrl,
    required this.signedUrlTtlSeconds,
    required this.s3Endpoint,
    required this.s3Region,
    required this.s3AccessKeyId,
    required this.s3SecretAccessKey,
  });

  factory _SupabaseStorageConfigDraft.fromControllers({
    required String provider,
    required TextEditingController url,
    required TextEditingController bucket,
    required TextEditingController serviceRoleKey,
    required TextEditingController publicBaseUrl,
    required TextEditingController signedUrlTtlSeconds,
    required TextEditingController s3Endpoint,
    required TextEditingController s3Region,
    required TextEditingController s3AccessKeyId,
    required TextEditingController s3SecretAccessKey,
  }) {
    return _SupabaseStorageConfigDraft(
      provider: provider,
      url: url.text.trim(),
      bucket: bucket.text.trim(),
      serviceRoleKey: serviceRoleKey.text.trim(),
      publicBaseUrl: publicBaseUrl.text.trim(),
      signedUrlTtlSeconds:
          int.tryParse(signedUrlTtlSeconds.text.trim()) ?? 3600,
      s3Endpoint: s3Endpoint.text.trim(),
      s3Region: s3Region.text.trim(),
      s3AccessKeyId: s3AccessKeyId.text.trim(),
      s3SecretAccessKey: s3SecretAccessKey.text.trim(),
    );
  }

  final String provider;
  final String url;
  final String bucket;
  final String serviceRoleKey;
  final String publicBaseUrl;
  final int signedUrlTtlSeconds;
  final String s3Endpoint;
  final String s3Region;
  final String s3AccessKeyId;
  final String s3SecretAccessKey;
}
