part of '../../desktop_shell.dart';

extension _DesktopShellSetupDialogOpenAi on _DesktopShellState {
  void _selectAllText(TextEditingController controller) {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  Future<void> _configureOpenAI() async {
    final status = await gateway.getConfigStatusRaw();
    if (!mounted) return;
    final openai = status['openai'] is Map<String, dynamic>
        ? status['openai'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final baseUrlController = TextEditingController(
      text: _stringOrDefault(openai['baseUrl'], ''),
    );
    final modelController = TextEditingController(
      text: _stringOrDefault(openai['model'], ''),
    );
    final apiKeyController = TextEditingController(
      text: resolveOpenAiApiKeyForEditor(
        openai,
        cachedApiKey: _openAiApiKeyCache ?? '',
      ),
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
                        hintText: AppLocalizations.of(context)!.setupInputApiKey,
                        helperText:
                            AppLocalizations.of(context)!.setupApiKeyVisibilityHint,
                        suffixIcon: IconButton(
                          tooltip: showApiKey
                              ? AppLocalizations.of(context)!.actionHide
                              : AppLocalizations.of(context)!.actionShow,
                          onPressed: () =>
                              setDialogState(() => showApiKey = !showApiKey),
                          icon: Icon(
                            showApiKey
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
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
    final result = await gateway.configureOpenAiRaw(
      payload: {
        'baseUrl': draft.baseUrl,
        'model': draft.model,
        'apiKey': draft.apiKey,
      },
    );
    if (result.okValue) {
      _setShellState(() => _openAiApiKeyCache = draft.apiKey);
    }

    _appendLog(
      result.okValue
          ? AppLocalizations.of(context)!.setupOpenAiConfigUpdated
          : AppLocalizations.of(context)!.setupOpenAiConfigUpdateFailed,
    );
    if (!mounted) return;

    _showSnackBar(
      result.okValue
          ? AppLocalizations.of(context)!.setupOpenAiConfigSaved
          : AppLocalizations.of(context)!.setupOpenAiConfigSaveFailed,
    );
    await _DesktopShellReadiness(this).refreshReadiness();
  }
}
