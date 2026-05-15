part of '../../desktop_shell.dart';

extension _DesktopShellSetupDialogStorage on _DesktopShellState {
  Future<void> _configureSupabaseStorage() async {
    final status = await gateway.getConfigStatusDto();
    if (!mounted) return;
    final storage = status.supabaseStorageConfig;
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
    final serviceRoleKeyController = TextEditingController();
    final s3EndpointController = TextEditingController(
      text: _stringOrDefault(storage.s3.endpoint, supabaseStorage.s3Endpoint),
    );
    final s3RegionController = TextEditingController(
      text: _stringOrDefault(
        storage.s3.region,
        supabaseStorage.s3Region.isEmpty ? 'auto' : supabaseStorage.s3Region,
      ),
    );
    final s3AccessKeyController = TextEditingController();
    final s3SecretKeyController = TextEditingController();
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
