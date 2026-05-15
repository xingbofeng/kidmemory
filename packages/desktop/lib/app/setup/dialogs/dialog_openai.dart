part of '../../desktop_shell.dart';

extension _DesktopShellSetupDialogOpenAi on _DesktopShellState {
  Future<void> _configureOpenAI() async {
    final status = await gateway.getConfigStatusDto();
    if (!mounted) return;
    final openai = status.openAiConfig;
    final baseUrlController = TextEditingController(
      text: _stringOrDefault(openai.baseUrl, ''),
    );
    final modelController = TextEditingController(
      text: _stringOrDefault(openai.model, ''),
    );
    final apiKeyController = TextEditingController();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('配置 OpenAI-compatible API'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: baseUrlController,
                  decoration: const InputDecoration(labelText: 'Base URL'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'OPENAI_API_KEY（留空保留）',
                  ),
                  obscureText: true,
                ),
              ],
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
    );
    if (shouldSave != true) return;

    final draft = _OpenAiConfigDraft.fromControllers(
      baseUrl: baseUrlController,
      model: modelController,
      apiKey: apiKeyController,
    );
    final result = await gateway.configureOpenAiDto(
      payload: OpenAiConfigRequest(
        baseUrl: draft.baseUrl,
        model: draft.model,
        apiKey: draft.apiKey.isEmpty ? null : draft.apiKey,
      ),
    );
    _appendLog(result.ok ? 'OpenAI 配置已更新' : 'OpenAI 配置更新失败');
    if (!mounted) return;
    _showSnackBar(result.ok ? 'OpenAI 配置已保存' : 'OpenAI 配置保存失败');
    await refreshReadiness();
  }
}
