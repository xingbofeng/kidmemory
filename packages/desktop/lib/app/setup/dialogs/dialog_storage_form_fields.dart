part of '../../desktop_shell.dart';

const _supabaseStorageS3AuthDocsUrl =
    'https://supabase.com/docs/guides/storage/s3/authentication/';
const _supabaseStorageS3CompatibilityDocsUrl =
    'https://supabase.com/docs/guides/storage/s3/compatibility';
const _supabaseStorageBucketsDocsUrl =
    'https://supabase.com/docs/guides/storage/buckets/fundamentals';
const _supabaseApiKeysDocsUrl = 'https://supabase.com/docs/guides/api/api-keys';

String _normalizeSupabaseStorageProvider(String provider) {
  final normalized = provider.trim().toLowerCase();
  if (normalized == 'cos') return 'cos';
  return 'supabase';
}

extension _DesktopShellSetupDialogStorageFormFields on _DesktopShellState {
  void _selectAllText(TextEditingController controller) {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  Widget _storageDialogGap([double height = 8]) => SizedBox(height: height);

  Future<void> _openStorageDocs(String url) async {
    try {
      await openExternalTarget(url);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(
        AppLocalizations.of(context)!.setupOpenSupabaseDocsFailed(error),
      );
    }
  }

  Widget _storageDialogDocsButton({
    required String tooltip,
    required String url,
  }) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      icon: const AppAssetIcon(viewIconAsset, size: 16),
      onPressed: () => _openStorageDocs(url),
    );
  }

  Widget _storageDialogSectionTitle(
    String text, {
    String? helpTooltip,
    String? helpUrl,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ),
        if (helpUrl != null && helpTooltip != null)
          _storageDialogDocsButton(tooltip: helpTooltip, url: helpUrl),
      ],
    );
  }

  InputDecoration _storageDialogDecoration(
    String label, {
    String? hintText,
    String? helperText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      suffixIcon: suffixIcon,
    );
  }

  Widget _storageDialogSecretField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    String? hintText,
    String? helperText,
    String? helpTooltip,
    String? helpUrl,
  }) {
    final suffixWidgets = <Widget>[
      if (helpUrl != null && helpTooltip != null)
        _storageDialogDocsButton(tooltip: helpTooltip, url: helpUrl),
      IconButton(
        tooltip: visible
            ? AppLocalizations.of(context)!.actionHide
            : AppLocalizations.of(context)!.actionShow,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        onPressed: onToggle,
        icon: AppAssetIcon(visible ? lockIconAsset : viewIconAsset, size: 20),
      ),
    ];
    return TextField(
      controller: controller,
      onTap: () => _selectAllText(controller),
      obscureText: !visible,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      decoration: _storageDialogDecoration(
        label,
        hintText: hintText,
        helperText: helperText,
        suffixIcon: SizedBox(
          width: suffixWidgets.length == 2 ? 84 : 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: suffixWidgets,
          ),
        ),
      ),
    );
  }

  Widget _storageDialogField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? helperText,
    TextInputType? keyboardType,
    String? helpTooltip,
    String? helpUrl,
  }) {
    final suffixIcon = helpUrl == null || helpTooltip == null
        ? null
        : _storageDialogDocsButton(tooltip: helpTooltip, url: helpUrl);
    return TextField(
      controller: controller,
      onTap: () => _selectAllText(controller),
      decoration: _storageDialogDecoration(
        label,
        hintText: hintText,
        helperText: helperText,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
    );
  }

  List<Widget> _buildSupabaseStorageDialogFields({
    required TextEditingController urlController,
    required String selectedProvider,
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
    required bool showServiceRoleKey,
    required bool showS3AccessKey,
    required bool showS3SecretKey,
    required void Function(String provider) onProviderChanged,
    required VoidCallback onToggleServiceRoleKey,
    required VoidCallback onToggleS3AccessKey,
    required VoidCallback onToggleS3SecretKey,
  }) {
    final provider = _normalizeSupabaseStorageProvider(selectedProvider);
    return [
      Text(
        AppLocalizations.of(context)!.setupStorageSectionIntro,
        style: TextStyle(color: Color(0xff6f6258), height: 1.35),
      ),
      _storageDialogGap(14),
      DropdownButtonFormField<String>(
        value: provider,
        decoration: _storageDialogDecoration('存储服务商'),
        items: const [
          DropdownMenuItem(value: 'supabase', child: Text('Supabase')),
          DropdownMenuItem(value: 'cos', child: Text('腾讯云 COS')),
        ],
        onChanged: (value) {
          if (value == null) return;
          onProviderChanged(value);
        },
      ),
      _storageDialogGap(14),
      _storageDialogSectionTitle(
        provider == 'cos'
            ? 'COS / S3 兼容方式'
            : AppLocalizations.of(context)!.setupStorageS3ModeLabel,
        helpTooltip: AppLocalizations.of(context)!.setupOpenSupabaseS3Docs,
        helpUrl: _supabaseStorageS3AuthDocsUrl,
      ),
      _storageDialogGap(),
      ..._buildSupabaseStorageS3Fields(
        bucketController: bucketController,
        s3EndpointController: s3EndpointController,
        s3RegionController: s3RegionController,
        s3AccessKeyController: s3AccessKeyController,
        s3SecretKeyController: s3SecretKeyController,
        s3AccessKeyConfigured: s3AccessKeyConfigured,
        s3SecretKeyConfigured: s3SecretKeyConfigured,
        showS3AccessKey: showS3AccessKey,
        showS3SecretKey: showS3SecretKey,
        onToggleS3AccessKey: onToggleS3AccessKey,
        onToggleS3SecretKey: onToggleS3SecretKey,
      ),
      if (provider == 'supabase') ...[
        _storageDialogGap(18),
        ..._buildSupabaseStorageRestFields(
          urlController: urlController,
          publicBaseUrlController: publicBaseUrlController,
          ttlController: ttlController,
          serviceRoleKeyController: serviceRoleKeyController,
          serviceRoleKeyConfigured: serviceRoleKeyConfigured,
          showServiceRoleKey: showServiceRoleKey,
          onToggleServiceRoleKey: onToggleServiceRoleKey,
        ),
      ],
    ];
  }

  List<Widget> _buildSupabaseStorageS3Fields({
    required TextEditingController bucketController,
    required TextEditingController s3EndpointController,
    required TextEditingController s3RegionController,
    required TextEditingController s3AccessKeyController,
    required TextEditingController s3SecretKeyController,
    required bool s3AccessKeyConfigured,
    required bool s3SecretKeyConfigured,
    required bool showS3AccessKey,
    required bool showS3SecretKey,
    required VoidCallback onToggleS3AccessKey,
    required VoidCallback onToggleS3SecretKey,
  }) {
    return [
      _storageDialogField(
        controller: s3EndpointController,
        label: AppLocalizations.of(context)!.setupStorageEndpointLabel,
        hintText: 'https://<project-ref>.torage.upabase.co/storage/v1/s3',
        helperText: AppLocalizations.of(context)!.setupStorageS3EndpointHint,
        helpUrl: _supabaseStorageS3CompatibilityDocsUrl,
        helpTooltip: AppLocalizations.of(context)!.setupOpenS3CompatibilityHelp,
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: s3RegionController,
        label: AppLocalizations.of(context)!.setupRegionLabel,
        hintText: 'auto',
        helperText: AppLocalizations.of(context)!.setupAutoUseAutoValue,
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: bucketController,
        label: AppLocalizations.of(context)!.setupBucketNameLabel,
        hintText: 'kidmemory',
        helperText: AppLocalizations.of(context)!.setupStorageBucketNameHint,
        helpUrl: _supabaseStorageBucketsDocsUrl,
        helpTooltip: AppLocalizations.of(context)!.setupOpenBucketsHelp,
      ),
      _storageDialogGap(),
      _storageDialogSecretField(
        controller: s3AccessKeyController,
        label: 'Access Key ID',
        visible: showS3AccessKey,
        onToggle: onToggleS3AccessKey,
        hintText: AppLocalizations.of(context)!.setupInputAccessKeyId,
        helperText: AppLocalizations.of(context)!.setupStorageS3AccessKeyIdHint,
        helpUrl: _supabaseStorageS3AuthDocsUrl,
        helpTooltip: AppLocalizations.of(context)!.setupOpenS3AuthHelp,
      ),
      _storageDialogGap(),
      _storageDialogSecretField(
        controller: s3SecretKeyController,
        label: 'Secret Access Key',
        visible: showS3SecretKey,
        onToggle: onToggleS3SecretKey,
        hintText: AppLocalizations.of(context)!.setupInputSecretAccessKey,
        helperText: AppLocalizations.of(context)!.setupStorageS3SecretKeyHint,
        helpUrl: _supabaseStorageS3AuthDocsUrl,
        helpTooltip: AppLocalizations.of(context)!.setupOpenS3AuthHelp,
      ),
    ];
  }

  List<Widget> _buildSupabaseStorageRestFields({
    required TextEditingController urlController,
    required TextEditingController publicBaseUrlController,
    required TextEditingController ttlController,
    required TextEditingController serviceRoleKeyController,
    required bool serviceRoleKeyConfigured,
    required bool showServiceRoleKey,
    required VoidCallback onToggleServiceRoleKey,
  }) {
    return [
      _storageDialogSectionTitle(
        AppLocalizations.of(context)!.setupStorageRestModeLabel,
        helpTooltip: AppLocalizations.of(context)!.setupOpenSupabaseApiKeysHelp,
        helpUrl: _supabaseApiKeysDocsUrl,
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: urlController,
        label: AppLocalizations.of(context)!.setupProjectUrlLabel,
        hintText: 'https://<project-ref>.upabase.co',
        helperText: AppLocalizations.of(context)!.setupStorageProjectUrlHint,
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: publicBaseUrlController,
        label: AppLocalizations.of(
          context,
        )!.setupStoragePublicAccessPrefixLabel,
        hintText: AppLocalizations.of(context)!.setupStoragePublicPrefixHint,
        helperText: AppLocalizations.of(context)!.setupPublicBucketOptionalHint,
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: ttlController,
        label: AppLocalizations.of(context)!.setupSignedUrlTTLLabel,
        hintText: '3600',
        helperText: AppLocalizations.of(context)!.setupSignedUrlDefaultHint,
        keyboardType: TextInputType.number,
      ),
      _storageDialogGap(),
      _storageDialogSecretField(
        controller: serviceRoleKeyController,
        label: 'Service Role Key',
        visible: showServiceRoleKey,
        onToggle: onToggleServiceRoleKey,
        hintText: AppLocalizations.of(context)!.setupInputServiceRoleKey,
        helperText: AppLocalizations.of(
          context,
        )!.setupStorageApiKeyHelpServiceRole,
        helpUrl: _supabaseApiKeysDocsUrl,
        helpTooltip: AppLocalizations.of(context)!.setupOpenApiKeysHelp,
      ),
    ];
  }
}
