import 'package:flutter/material.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart' show AgentConfigResponseDto;
import '../../../core/sidecar/agent_config_api.dart';
import '../../../core/sidecar/sidecar_api.dart';
import '../../../l10n/app_localizations.dart';

class AgentSettingsPage extends StatefulWidget {
  final SidecarApi sidecarApi;

  const AgentSettingsPage({super.key, required this.sidecarApi});

  @override
  State<AgentSettingsPage> createState() => _AgentSettingsPageState();
}

class _AgentSettingsPageState extends State<AgentSettingsPage> {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  // Agent 配置
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final baseUrlController = TextEditingController();
  final apiKeyController = TextEditingController();
  final modelController = TextEditingController();
  final temperatureController = TextEditingController();
  final maxTokensController = TextEditingController();

  String selectedProvider = 'openai';
  AgentConfigResponseDto? currentConfig;
  late final AgentConfigApi agentConfigApi;

  @override
  void initState() {
    super.initState();
    agentConfigApi = AgentConfigApi(widget.sidecarApi);
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    baseUrlController.dispose();
    apiKeyController.dispose();
    modelController.dispose();
    temperatureController.dispose();
    maxTokensController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentConfig() async {
    baseUrlController.text = 'https://api.openai.com';
    modelController.text = 'gpt-4';
    temperatureController.text = '0.7';
    maxTokensController.text = '4000';

    try {
      final config = await agentConfigApi.getDefaultAgentConfig();
      if (config == null) return;
      if (!mounted) return;
      setState(() {
        currentConfig = config;
        nameController.text = config.name;
        descriptionController.text = config.description ?? '';
        selectedProvider = config.provider;
        baseUrlController.text = config.baseUrl ?? 'https://api.openai.com';
        modelController.text = config.model;
        temperatureController.text = config.temperature.toString();
        maxTokensController.text = config.maxTokens.toString();
      });
    } catch (error) {
      debugPrint('Failed to load default agent config: $error');
    }
  }

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context)!;
    if (baseUrlController.text.isEmpty ||
        (currentConfig == null && apiKeyController.text.isEmpty)) {
      _showError(l10n.agentSettingsMissingConfigMessage);
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
        successMessage = null;
      });

      final config = AgentConfig(
        baseUrl: baseUrlController.text.trim(),
        apiKey: apiKeyController.text.trim(),
        model: modelController.text.trim().isEmpty
            ? 'gpt-4'
            : modelController.text.trim(),
      );

      final result = await agentConfigApi.testAgentConfig(config);

      setState(() {
        isLoading = false;
      });

      if (result.success) {
        setState(() {
          successMessage = l10n.agentSettingsConnectionTestSuccess;
        });
      } else {
        _showError(result.errorMessage ?? l10n.agentSettingsConnectionTestFailed);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('连接测试失败: $e');
    }
  }

  Future<void> _saveConfiguration() async {
    final l10n = AppLocalizations.of(context)!;
    if (baseUrlController.text.isEmpty || apiKeyController.text.isEmpty) {
      _showError(l10n.agentSettingsMissingConfigMessage);
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
        successMessage = null;
      });

      final temperature =
          double.tryParse(temperatureController.text.trim()) ?? 0.7;
      final maxTokens = int.tryParse(maxTokensController.text.trim()) ?? 4000;
      final configName = nameController.text.trim().isEmpty
          ? 'OpenAI'
          : nameController.text.trim();
      final description = descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim();

      final savedConfig = currentConfig == null
          ? await agentConfigApi.createAgentConfig(
              CreateAgentConfigInput(
                name: configName,
                description: description,
                provider: selectedProvider,
                model: modelController.text.trim().isEmpty
                    ? 'gpt-4'
                    : modelController.text.trim(),
                apiKey: apiKeyController.text.trim(),
                baseUrl: baseUrlController.text.trim(),
                temperature: temperature,
                maxTokens: maxTokens,
                isDefault: true,
              ),
            )
          : await agentConfigApi.updateAgentConfig(
              currentConfig!.id,
              UpdateAgentConfigInput(
                name: configName,
                description: description,
                provider: selectedProvider,
                model: modelController.text.trim().isEmpty
                    ? 'gpt-4'
                    : modelController.text.trim(),
                apiKey: apiKeyController.text.trim().isEmpty
                    ? null
                    : apiKeyController.text.trim(),
                baseUrl: baseUrlController.text.trim(),
                temperature: temperature,
                maxTokens: maxTokens,
              ),
            );

      await agentConfigApi.setDefaultAgentConfig(savedConfig.id);

      setState(() {
        currentConfig = savedConfig;
        isLoading = false;
        successMessage = l10n.agentSettingsSaveSuccess;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('保存配置失败: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
      successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.agentSettingsTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明文本
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.agentSettingsOpenAiDescription,
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 错误消息
            if (errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 成功消息
            if (successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        successMessage!,
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 配置表单
            Text(
              AppLocalizations.of(context)!.agentSettingsSectionTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: nameController,
              label: AppLocalizations.of(context)!.agentSettingsConfigNameLabel,
              hint: 'OpenAI',
              helperText: AppLocalizations.of(context)!.agentSettingsNameHelper,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: baseUrlController,
              label: 'Base URL',
              hint: AppLocalizations.of(context)!.agentSettingsBaseUrlHint,
              required: true,
              helperText: AppLocalizations.of(context)!.agentSettingsBaseUrlHelper,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: apiKeyController,
              label: 'API Key',
              hint: AppLocalizations.of(context)!.agentSettingsApiKeyHint,
              obscureText: true,
              required: true,
              helperText: AppLocalizations.of(context)!.agentSettingsApiKeyHelper,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: modelController,
              label: AppLocalizations.of(context)!.agentSettingsModelLabel,
              hint: AppLocalizations.of(context)!.agentSettingsModelHint,
              helperText: AppLocalizations.of(context)!.agentSettingsModelDefaultHint,
            ),
            const SizedBox(height: 32),

            // 操作按钮
            if (isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _testConnection,
                      icon: const Icon(Icons.wifi_protected_setup),
                      label: Text(AppLocalizations.of(context)!.actionTestConnection),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveConfiguration,
                      icon: const Icon(Icons.save),
                      label: Text(AppLocalizations.of(context)!.actionSaveSettings),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // 使用说明
            Text(
              AppLocalizations.of(context)!.agentSettingsUsageTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHelpItem(
                    AppLocalizations.of(context)!.agentSettingsOpenAiStepTitle,
                    AppLocalizations.of(context)!.agentSettingsOpenAiStepDescription,
                  ),
                  _buildHelpItem(
                    AppLocalizations.of(context)!.agentSettingsLocalStepTitle,
                    AppLocalizations.of(context)!.agentSettingsLocalStepDescription,
                  ),
                  _buildHelpItem(
                    AppLocalizations.of(context)!.agentSettingsCustomEndpointStepTitle,
                    AppLocalizations.of(context)!.agentSettingsCustomEndpointStepDescription,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helperText,
    bool obscureText = false,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            if (required) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
