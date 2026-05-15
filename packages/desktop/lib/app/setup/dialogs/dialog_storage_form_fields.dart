part of '../../desktop_shell.dart';

extension _DesktopShellSetupDialogStorageFormFields on _DesktopShellState {
  Widget _storageDialogGap([double height = 8]) => SizedBox(height: height);

  Widget _storageDialogSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
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
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      autocorrect: false,
      enableSuggestions: false,
      decoration: _storageDialogDecoration(
        label,
        hintText: hintText,
        helperText: helperText,
        suffixIcon: IconButton(
          tooltip: visible ? '隐藏' : '显示',
          onPressed: onToggle,
          icon: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
  }) {
    return TextField(
      controller: controller,
      decoration: _storageDialogDecoration(
        label,
        hintText: hintText,
        helperText: helperText,
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
    required bool showServiceRoleKey,
    required bool showS3AccessKey,
    required bool showS3SecretKey,
    required VoidCallback onToggleServiceRoleKey,
    required VoidCallback onToggleS3AccessKey,
    required VoidCallback onToggleS3SecretKey,
  }) {
    return [
      const Text(
        '推荐先用 S3 模式：endpoint、region、bucket、access key 和 secret key 都可以直接在 Supabase 控制台里找到。bucket 建议保持私有，KidMemory 会在分享时自动生成带有效期的链接。',
        style: TextStyle(
          color: Color(0xff6f6258),
          height: 1.35,
        ),
      ),
      _storageDialogGap(14),
      ..._buildSupabaseStorageS3Fields(
        bucketController: bucketController,
        s3EndpointController: s3EndpointController,
        s3RegionController: s3RegionController,
        s3AccessKeyController: s3AccessKeyController,
        s3SecretKeyController: s3SecretKeyController,
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
    required bool showS3AccessKey,
    required bool showS3SecretKey,
    required VoidCallback onToggleS3AccessKey,
    required VoidCallback onToggleS3SecretKey,
  }) {
    return [
      _storageDialogSectionTitle('S3 模式'),
      _storageDialogGap(),
      _storageDialogField(
        controller: s3EndpointController,
        label: 'SUPABASE_S3_ENDPOINT',
        hintText: 'https://<project-ref>.storage.supabase.co/storage/v1/s3',
        helperText: '通常来自 Supabase Storage 的 S3 配置页。',
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: s3RegionController,
        label: 'SUPABASE_S3_REGION',
        hintText: 'auto',
        helperText: '大多数项目可以直接使用 auto。',
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: bucketController,
        label: 'SUPABASE_S3_BUCKET',
        hintText: 'kidmemory',
        helperText: '在 Storage -> Files -> Buckets 里看 bucket 名。',
      ),
      _storageDialogGap(),
      _storageDialogSecretField(
        controller: s3AccessKeyController,
        label: 'SUPABASE_S3_ACCESS_KEY_ID',
        visible: showS3AccessKey,
        onToggle: onToggleS3AccessKey,
        hintText: '留空保留当前值',
        helperText: '从 Supabase 的 S3 凭据页面复制。',
      ),
      _storageDialogGap(),
      _storageDialogSecretField(
        controller: s3SecretKeyController,
        label: 'SUPABASE_S3_SECRET_ACCESS_KEY',
        visible: showS3SecretKey,
        onToggle: onToggleS3SecretKey,
        hintText: '留空保留当前值',
        helperText: '这是敏感密钥，输入后会写入本地配置。',
      ),
    ];
  }

  List<Widget> _buildSupabaseStorageRestFields({
    required TextEditingController urlController,
    required TextEditingController publicBaseUrlController,
    required TextEditingController ttlController,
    required TextEditingController serviceRoleKeyController,
    required bool showServiceRoleKey,
    required VoidCallback onToggleServiceRoleKey,
  }) {
    return [
      _storageDialogSectionTitle('REST 模式（可选）'),
      _storageDialogGap(),
      _storageDialogField(
        controller: urlController,
        label: 'SUPABASE_URL',
        hintText: 'https://<project-ref>.supabase.co',
        helperText: '如果你只用 S3，这项可以先不填。',
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: publicBaseUrlController,
        label: 'SUPABASE_STORAGE_PUBLIC_BASE_URL',
        hintText: '公开桶可填完整对象前缀',
        helperText: '私有 bucket 可留空，分享时会生成签名 URL。',
      ),
      _storageDialogGap(),
      _storageDialogField(
        controller: ttlController,
        label: 'SUPABASE_STORAGE_SIGNED_URL_TTL_SECONDS',
        hintText: '3600',
        helperText: '签名链接默认 1 小时有效。',
        keyboardType: TextInputType.number,
      ),
      _storageDialogGap(),
      _storageDialogSecretField(
        controller: serviceRoleKeyController,
        label: 'SUPABASE_SERVICE_ROLE_KEY',
        visible: showServiceRoleKey,
        onToggle: onToggleServiceRoleKey,
        hintText: '留空保留当前值',
        helperText: 'REST 模式需要 service role key。S3 模式可不填。',
      ),
    ];
  }
}
