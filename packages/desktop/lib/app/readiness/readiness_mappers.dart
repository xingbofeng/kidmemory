part of '../desktop_shell.dart';

extension _DesktopShellReadinessMappers on _DesktopShellState {
  List<T> _nonEmptyOr<T>(List<T> primary, List<T> fallback) {
    return primary.isNotEmpty ? primary : fallback;
  }

  String _nonEmptyTextOr(String primary, String fallback) {
    return primary.isNotEmpty ? primary : fallback;
  }

  String _openAiReadinessDescription(
    ReadinessConfigDto config,
    ReadinessCheckDto openai,
  ) {
    if (openai.isOk) {
      return '提供文本生成、标签与提示词能力，供书籍生成和素材解读使用。';
    }

    final baseUrl = _stringOrDefault(config.openAiConfig.baseUrl, '');
    final model = _stringOrDefault(config.openAiConfig.model, '');
    final details = <String>['提供文本生成、标签与提示词能力。请配置 Base URL、模型与 API Key。'];
    if (baseUrl.isNotEmpty) details.add('Base URL：$baseUrl');
    if (model.isNotEmpty) details.add('模型：$model');
    return details.join('\n');
  }

  String _stringOrDefault(Object? value, String fallback) {
    final text = value is String ? value.trim() : '';
    return text.isEmpty ? fallback : text;
  }

  _UiConfigSnapshot _parseUiConfig(Map<String, dynamic> raw) {
    final uiConfig = _UiConfigDto.fromJson(raw);
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

  List<SetupCheckVm> _parseSetupFallbackChecks(List<_SetupCheckDto> rawChecks) {
    if (rawChecks.isEmpty) return const [];
    final checks = <SetupCheckVm>[];
    for (final item in rawChecks) {
      final title = item.title.isNotEmpty ? item.title : '配置项';
      if (_deprecatedSetupCheckTitle(title) || title == 'Workspace 目录') {
        continue;
      }
      final sourceBody = item.body.isEmpty ? '等待配置读取' : item.body;
      final paths = _extractSetupDirectoryPaths(sourceBody);
      final normalizedBody = title == '本地数据目录'
          ? _readableLocalDataBodyFromRaw(sourceBody)
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
          secondaryActionLabel: title == '本地数据目录' ? '打开目录' : null,
          secondaryActionPath: title == '本地数据目录' && paths.primary.isNotEmpty
              ? paths.primary
              : null,
        ),
      );
    }
    return checks;
  }

  List<Map<String, String>> _parseLabeledOptions(
    List<_LabeledOptionDto> rawOptions,
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
}
