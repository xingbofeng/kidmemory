part of '../desktop_shell.dart';

extension _DesktopShellReadinessMappers on _DesktopShellState {
  List<T> _nonEmptyOr<T>(List<T> primary, List<T> fallback) {
    return primary.isNotEmpty ? primary : fallback;
  }

  String _nonEmptyTextOr(String primary, String fallback) {
    return primary.isNotEmpty ? primary : fallback;
  }

  String _openAiReadinessDescription() {
    return '提供文本生成、标签与提示词能力。请配置 Base URL、模型与 API Key。';
  }

  String _stringOrDefault(Object? value, String fallback) {
    final text = value is String ? value.trim() : '';
    return text.isEmpty ? fallback : text;
  }

  _UiConfigSnapshot _parseUiConfig(Map<String, dynamic> raw) {
    final uiConfig = _UiConfigParsed.fromJson(raw);
    final setupChecks = _parseSetupFallbackChecks(uiConfig.setupChecks);
    final searchTypeOptions = _parseLabeledOptions(uiConfig.searchTypeOptions);
    final generationTemplates = _nonEmptyOr(
      uiConfig.templates,
      _defaultGenerationTemplates,
    );
    final generationPageSizes = _nonEmptyOr(
      uiConfig.pageSizes,
      _defaultGenerationPageSizes,
    );
    final generationStyles = _nonEmptyOr(
      uiConfig.styles,
      _defaultGenerationStyles,
    );
    final generationExportTargets = _nonEmptyOr(
      uiConfig.exportTargets,
      _defaultGenerationExportTargets,
    );

    return _UiConfigSnapshot(
      setupChecks: _nonEmptyOr(setupChecks, _disconnectedSetupChecks()),
      searchTypeOptions: _nonEmptyOr(
        searchTypeOptions,
        _defaultSearchTypeOptions,
      ),
      generationTemplates: generationTemplates,
      generationPageSizes: generationPageSizes,
      generationStyles: generationStyles,
      generationExportTargets: generationExportTargets,
      defaultGenerationTemplate: _nonEmptyTextOr(
        uiConfig.defaults.template,
        generationTemplates.first,
      ),
      defaultGenerationPageSize: _nonEmptyTextOr(
        uiConfig.defaults.pageSize,
        generationPageSizes.first,
      ),
      defaultGenerationStyle: _nonEmptyTextOr(
        uiConfig.defaults.style,
        generationStyles.first,
      ),
      defaultGenerationExportTarget: _nonEmptyTextOr(
        uiConfig.defaults.exportTarget,
        generationExportTargets.first,
      ),
    );
  }

  List<SetupCheckVm> _parseSetupFallbackChecks(
    List<_SetupCheckParsed> rawChecks,
  ) {
    if (rawChecks.isEmpty) return const [];
    final checks = <SetupCheckVm>[];
    for (final item in rawChecks) {
      final title = _normalizeSetupTitle(
        item.title.isNotEmpty ? item.title : '配置项',
      );
      final sourceBody = item.body.isEmpty ? '等待配置读取' : item.body;
      final normalizedBody = title == '大模型接口配置'
          ? '提供文本生成、标签与提示词能力。请配置 Base URL、模型与 API Key。'
          : (item.purpose.isNotEmpty
                ? item.purpose
                : _extractSetupPurpose(sourceBody));
      checks.add(
        SetupCheckVm(
          index: '${checks.length + 1}',
          title: title,
          body: normalizedBody,
          action: _setupActionForTitle(item.action, title),
          state: item.state.isNotEmpty ? item.state : '待检测',
          ok: item.ok,
          secondaryActionLabel: title == '大模型接口配置' ? '修改配置' : null,
          secondaryActionPath: title == '大模型接口配置' ? '__action__:配置' : null,
        ),
      );
    }
    return checks;
  }

  List<Map<String, String>> _parseLabeledOptions(
    List<_LabeledOptionParsed> rawOptions,
  ) {
    if (rawOptions.isEmpty) return const [];
    final options = <Map<String, String>>[];
    for (final item in rawOptions) {
      final value = item.value;
      final label = item.label.isNotEmpty ? item.label : value;
      if (value.isEmpty) continue;
      options.add({'value': value, 'label': label});
    }
    return options;
  }

  String _readinessState(ReadinessCheckDto result) {
    final ok = result.okOrNull;
    if (ok == true) return '正常';
    if (ok == false) return '需处理';
    return '待检测';
  }

  String _normalizeSetupTitle(String title) {
    return switch (title) {
      'Sidecar 本地服务' => _sidecarSetupTitle,
      _ => title,
    };
  }
}
