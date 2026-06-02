part of '../../desktop_shell.dart';

extension _DesktopShellSetupDialogStorageForm on _DesktopShellState {
  Future<bool?> _showSupabaseStorageDialog({
    required String selectedProvider,
    required void Function(String provider) onProviderChanged,
    required TextEditingController urlController,
    required TextEditingController bucketController,
    required TextEditingController publicBaseUrlController,
    required TextEditingController ttlController,
    required TextEditingController serviceRoleKeyController,
    required TextEditingController s3EndpointController,
    required TextEditingController s3RegionController,
    required TextEditingController s3AccessKeyController,
    required TextEditingController s3SecretKeyController,
    required bool serviceRoleKeyConfigured,
    required bool s3AccessKeyConfigured,
    required bool s3SecretKeyConfigured,
  }) {
    var showServiceRoleKey = false;
    var showS3AccessKey = false;
    var showS3SecretKey = false;
    var provider = _normalizeSupabaseStorageProvider(selectedProvider);

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.setupStorageDialogTitle,
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildSupabaseStorageDialogFields(
                      urlController: urlController,
                      selectedProvider: provider,
                      bucketController: bucketController,
                      publicBaseUrlController: publicBaseUrlController,
                      ttlController: ttlController,
                      serviceRoleKeyController: serviceRoleKeyController,
                      s3EndpointController: s3EndpointController,
                      s3RegionController: s3RegionController,
                      s3AccessKeyController: s3AccessKeyController,
                      s3SecretKeyController: s3SecretKeyController,
                      serviceRoleKeyConfigured: serviceRoleKeyConfigured,
                      s3AccessKeyConfigured: s3AccessKeyConfigured,
                      s3SecretKeyConfigured: s3SecretKeyConfigured,
                      showServiceRoleKey: showServiceRoleKey,
                      showS3AccessKey: showS3AccessKey,
                      showS3SecretKey: showS3SecretKey,
                      onProviderChanged: (value) {
                        provider = _normalizeSupabaseStorageProvider(value);
                        onProviderChanged(provider);
                        setDialogState(() {});
                      },
                      onToggleServiceRoleKey: () => setDialogState(
                        () => showServiceRoleKey = !showServiceRoleKey,
                      ),
                      onToggleS3AccessKey: () => setDialogState(
                        () => showS3AccessKey = !showS3AccessKey,
                      ),
                      onToggleS3SecretKey: () => setDialogState(
                        () => showS3SecretKey = !showS3SecretKey,
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.actionCancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(AppLocalizations.of(context)!.actionSave),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
