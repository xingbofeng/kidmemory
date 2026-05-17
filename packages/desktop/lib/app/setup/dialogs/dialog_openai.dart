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
            title: const Text('配置大模型接口'),
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
                        hintText: '输入 API Key',
                        helperText: '本地明文保存，点击眼睛可显示/隐藏',
                        suffixIcon: IconButton(
                          tooltip: showApiKey ? '隐藏' : '显示',
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
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('保存'),
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
    _appendLog(result.okValue ? 'OpenAI 配置已更新' : 'OpenAI 配置更新失败');
    if (!mounted) return;
    _showSnackBar(result.okValue ? 'OpenAI 配置已保存' : 'OpenAI 配置保存失败');
    await refreshReadiness();
  }
}
