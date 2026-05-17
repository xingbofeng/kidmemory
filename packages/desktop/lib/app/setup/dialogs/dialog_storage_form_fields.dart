part of '../../desktop_shell.dart';

const _supabaseStorageS3AuthDocsUrl =
    'https://supabase.com/docs/guides/storage/s3/authentication/';
const _supabaseStorageS3CompatibilityDocsUrl =
    'https://supabase.com/docs/guides/storage/s3/compatibility';
const _supabaseStorageBucketsDocsUrl =
    'https://supabase.com/docs/guides/storage/buckets/fundamentals';
const _supabaseApiKeysDocsUrl = 'https://supabase.com/docs/guides/api/api-keys';

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
      _showSnackBar('打开 Supabase 官方说明失败：$error');
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
      icon: const Icon(Icons.open_in_new_rounded, size: 16),
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
    final suffixIcons = <Widget>[
      if (helpUrl != null && helpTooltip != null)
        _storageDialogDocsButton(tooltip: helpTooltip, url: helpUrl),
      IconButton(
        tooltip: visible ? '隐藏' : '显示',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        onPressed: onToggle,
        icon: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
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
          width: suffixIcons.length == 2 ? 84 : 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: suffixIcons,
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
    required VoidCallback onToggleServiceRoleKey,
    required VoidCallback onToggleS3AccessKey,
    required VoidCallback onToggleS3SecretKey,
  }) {
    return [
      const Text(
        '先用 S3 方式最省事：接口地址、区域、桶名、Access Key 和 Secret Key 都在 Supabase 控制台里能找到。bucket 建议保持私有，KidMemory 会在分享时自动生成带有效期的链接。',
        style: TextStyle(color: Color(0xff6f6258), height: 1.35),
      ),
      _storageDialogGap(14),
      _storageDialogSectionTitle(
        'S3 方式（推荐）',
        helpTooltip: '打开 Supabase S3 官方说明',
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
        label: '接口地址',
        hintText: 'https://<project-ref>.storage.supabase.co/storage/v1/s3',
        helperText: '去 Supabase 的 Storage > Settings > S3 说明页复制 endpoint。',
        helpUrl: _supabaseStorageS3CompatibilityDocsUrl,
        helpTooltip: '打开 S3 兼容性说明',
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: s3RegionController,
        label: '区域',
        hintText: 'auto',
        helperText: '大多数项目直接填 auto 就行。',
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: bucketController,
        label: '桶名',
        hintText: 'kidmemory',
        helperText: '去 Supabase 的 Storage > Buckets 里看 bucket 名。',
        helpUrl: _supabaseStorageBucketsDocsUrl,
        helpTooltip: '打开 buckets 官方说明',
      ),
      _storageDialogGap(),
      _storageDialogSecretField(
        controller: s3AccessKeyController,
        label: 'Access Key ID',
        visible: showS3AccessKey,
        onToggle: onToggleS3AccessKey,
        hintText: '输入或粘贴 Access Key ID',
        helperText: '去 Supabase 的 Storage > Settings > S3 说明页复制 Access Key ID。',
        helpUrl: _supabaseStorageS3AuthDocsUrl,
        helpTooltip: '打开 S3 认证说明',
      ),
      _storageDialogGap(),
      _storageDialogSecretField(
        controller: s3SecretKeyController,
        label: 'Secret Access Key',
        visible: showS3SecretKey,
        onToggle: onToggleS3SecretKey,
        hintText: '输入或粘贴 Secret Access Key',
        helperText:
            '去 Supabase 的 Storage > Settings > S3 说明页复制 Secret Access Key。',
        helpUrl: _supabaseStorageS3AuthDocsUrl,
        helpTooltip: '打开 S3 认证说明',
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
        'REST 方式（可选）',
        helpTooltip: '打开 Supabase API Keys 官方说明',
        helpUrl: _supabaseApiKeysDocsUrl,
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: urlController,
        label: '项目地址',
        hintText: 'https://<project-ref>.supabase.co',
        helperText: '去 Supabase 项目首页或 Settings > API 里找 SUPABASE_URL。',
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: publicBaseUrlController,
        label: '公开访问前缀（可选）',
        hintText: '公开桶可填完整对象前缀',
        helperText: '只有公开桶才需要；私有桶可以留空，分享时会自动生成签名链接。',
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: ttlController,
        label: '签名链接有效期（秒）',
        hintText: '3600',
        helperText: '不改的话，默认就是 1 小时，填 3600 就可以。',
        keyboardType: TextInputType.number,
      ),
      _storageDialogGap(),
      _storageDialogSecretField(
        controller: serviceRoleKeyController,
        label: 'Service Role Key',
        visible: showServiceRoleKey,
        onToggle: onToggleServiceRoleKey,
        hintText: '输入或粘贴 Service Role Key',
        helperText:
            '去 Supabase 的 Settings > API Keys 里找 service_role / secret key。',
        helpUrl: _supabaseApiKeysDocsUrl,
        helpTooltip: '打开 API Keys 官方说明',
      ),
    ];
  }
}
