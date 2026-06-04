part of '../../desktop_shell.dart';

extension _DesktopShellSetupDialogOpenAi on _DesktopShellState {
  void _selectAllText(TextEditingController controller) {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  Future<void> _configureOpenAI() async {
    final agentConfigApi = AgentConfigApi(api);
    final shellL10n = AppLocalizations.of(context)!;
    AgentConfigResponseDto? currentConfig;
    try {
      currentConfig = await agentConfigApi.getDefaultAgentConfig();
    } catch (error) {
      _appendLog(shellL10n.setupOpenAiDefaultConfigLoadFailed(error));
    }
    if (!mounted) return;

    final baseUrlController = TextEditingController(
      text: currentConfig?.baseUrl ?? '',
    );
    final modelController = TextEditingController(
      text: currentConfig?.model ?? '',
    );
    final apiKeyController = TextEditingController(
      text: _openAiApiKeyCache ?? '',
    );

    var showApiKey = false;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.setupOpenAiDialogTitle),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: baseUrlController,
                      autofocus: true,
                      onTap: () => _selectAllText(baseUrlController),
                      decoration: const InputDecoration(labelText: 'Base URL'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: modelController,
                      onTap: () => _selectAllText(modelController),
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: apiKeyController,
                      onTap: () => _selectAllText(apiKeyController),
                      decoration: InputDecoration(
                        labelText: 'OPENAI_API_KEY',
                        hintText: AppLocalizations.of(
                          context,
                        )!.setupInputApiKey,
                        helperText: AppLocalizations.of(
                          context,
                        )!.setupApiKeyVisibilityHint,
                        suffixIcon: IconButton(
                          tooltip: showApiKey
                              ? AppLocalizations.of(context)!.actionHide
                              : AppLocalizations.of(context)!.actionShow,
                          onPressed: () =>
                              setDialogState(() => showApiKey = !showApiKey),
                          icon: AppAssetIcon(
                            showApiKey ? lockIconAsset : viewIconAsset,
                            size: 20,
                          ),
                        ),
                      ),
                      obscureText: !showApiKey,
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                  ],
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
      ),
    );

    if (shouldSave != true) return;

    final draft = _OpenAiConfigDraft.fromControllers(
      baseUrl: baseUrlController,
      model: modelController,
      apiKey: apiKeyController,
    );
    var saved = false;
    try {
      final provider = _agentProviderForBaseUrl(draft.baseUrl);
      final model = draft.model.isEmpty ? 'gpt-4' : draft.model;
      final name =
          currentConfig?.name ??
          (provider == 'openai' ? 'OpenAI' : '$model Agent');
      final savedConfig = currentConfig == null
          ? await agentConfigApi.createAgentConfig(
              CreateAgentConfigInput(
                name: name,
                provider: provider,
                model: model,
                baseUrl: draft.baseUrl,
                apiKey: draft.apiKey,
                temperature: 0.7,
                maxTokens: 4000,
                isDefault: true,
              ),
            )
          : await agentConfigApi.updateAgentConfig(
              currentConfig.id,
              UpdateAgentConfigInput(
                name: name,
                provider: provider,
                model: model,
                baseUrl: draft.baseUrl,
                apiKey: draft.apiKey.isEmpty ? null : draft.apiKey,
                temperature: currentConfig.temperature,
                maxTokens: currentConfig.maxTokens,
              ),
            );
      await agentConfigApi.setDefaultAgentConfig(savedConfig.id);
      saved = true;
    } catch (error) {
      _appendLog('${shellL10n.setupOpenAiConfigUpdateFailed}: $error');
    }
    if (!mounted) return;

    if (saved) {
      _setShellState(() => _openAiApiKeyCache = draft.apiKey);
    }

    _appendLog(
      saved
          ? shellL10n.setupOpenAiConfigUpdated
          : shellL10n.setupOpenAiConfigUpdateFailed,
    );

    _showSnackBar(
      saved
          ? shellL10n.setupOpenAiConfigSaved
          : shellL10n.setupOpenAiConfigSaveFailed,
    );
    await _DesktopShellReadiness(this).refreshReadiness();
  }

  String _agentProviderForBaseUrl(String baseUrl) {
    final normalized = baseUrl.trim().toLowerCase();
    if (normalized.isEmpty || normalized.contains('api.openai.com')) {
      return 'openai';
    }
    return 'custom';
  }
}
