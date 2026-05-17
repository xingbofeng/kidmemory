part of '../../desktop_shell.dart';

extension _DesktopShellSetupDialogStorage on _DesktopShellState {
  Future<void> _configureSupabaseStorage() async {
    final statusRaw = await gateway.getConfigStatusRaw();
    if (!mounted) return;
    final storageRaw = statusRaw['supabaseStorage'] is Map<String, dynamic>
        ? statusRaw['supabaseStorage'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final s3Raw = storageRaw['s3'] is Map<String, dynamic>
        ? storageRaw['s3'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final storage = SupabaseStorageConfigDto.fromJson(storageRaw);
    final urlController = TextEditingController(
      text: _stringOrDefault(storage.url, supabaseStorage.url),
    );
    final bucketController = TextEditingController(
      text: _stringOrDefault(storage.bucket, supabaseStorage.bucket),
    );
    final publicBaseUrlController = TextEditingController(
      text: _stringOrDefault(
        storage.publicBaseUrl,
        supabaseStorage.publicBaseUrl,
      ),
    );
    final ttlController = TextEditingController(
      text:
          '${_intOrDefault(storage.signedUrlTtlSeconds, supabaseStorage.signedUrlTtlSeconds)}',
    );
    final serviceRoleKeyController = TextEditingController(
      text: _stringOrDefault(
        storageRaw['serviceRoleKey'],
        _supabaseStorageServiceRoleKeyCache ?? '',
      ),
    );
    final s3EndpointController = TextEditingController(
      text: _stringOrDefault(
        storage.s3Config.endpointValue,
        supabaseStorage.s3Endpoint,
      ),
    );
    final s3RegionController = TextEditingController(
      text: _stringOrDefault(
        storage.s3Config.regionValue,
        supabaseStorage.s3Region.isEmpty ? 'auto' : supabaseStorage.s3Region,
      ),
    );
    final s3AccessKeyController = TextEditingController(
      text: _stringOrDefault(
        s3Raw['accessKeyId'],
        _supabaseStorageS3AccessKeyCache ?? '',
      ),
    );
    final s3SecretKeyController = TextEditingController(
      text: _stringOrDefault(
        s3Raw['secretAccessKey'],
        _supabaseStorageS3SecretKeyCache ?? '',
      ),
    );
    final shouldSave = await _showSupabaseStorageDialog(
      urlController: urlController,
      bucketController: bucketController,
      publicBaseUrlController: publicBaseUrlController,
      ttlController: ttlController,
      serviceRoleKeyController: serviceRoleKeyController,
      s3EndpointController: s3EndpointController,
      s3RegionController: s3RegionController,
      s3AccessKeyController: s3AccessKeyController,
      s3SecretKeyController: s3SecretKeyController,
      serviceRoleKeyConfigured: storage.serviceRoleKeyConfiguredValue,
      s3AccessKeyConfigured: storage.s3Config.accessKeyConfigured,
      s3SecretKeyConfigured: storage.s3Config.secretKeyConfigured,
    );
    if (shouldSave != true) return;
    await _submitSupabaseStorageConfig(
      urlController: urlController,
      bucketController: bucketController,
      publicBaseUrlController: publicBaseUrlController,
      ttlController: ttlController,
      serviceRoleKeyController: serviceRoleKeyController,
      s3EndpointController: s3EndpointController,
      s3RegionController: s3RegionController,
      s3AccessKeyController: s3AccessKeyController,
      s3SecretKeyController: s3SecretKeyController,
    );
  }
}
