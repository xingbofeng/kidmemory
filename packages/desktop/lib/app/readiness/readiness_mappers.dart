part of '../desktop_shell.dart';

extension _DesktopShellReadinessMappers on _DesktopShellState {
  List<T> _nonEmptyOr<T>(List<T> primary, List<T> fallback) {
    return primary.isNotEmpty ? primary : fallback;
  }

  String _nonEmptyTextOr(String primary, String fallback) {
    return primary.isNotEmpty ? primary : fallback;
  }

  String _openAiReadinessDescription() {
    return AppLocalizations.of(context)!.setupOpenAiDescription;
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
      _defaultGenerationPageSizes(context),
    );
    final generationStyles = _nonEmptyOr(
      uiConfig.styles,
      _defaultGenerationStyles(context),
    );
    final generationExportTargets = _nonEmptyOr(
      uiConfig.exportTargets,
      _defaultGenerationExportTargets(context),
    );

    return _UiConfigSnapshot(
      setupChecks: _nonEmptyOr(setupChecks, _disconnectedSetupChecks(context)),
      searchTypeOptions: _nonEmptyOr(
        searchTypeOptions,
        _defaultSearchTypeOptions(context),
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
        item.title.isNotEmpty ? item.title : AppLocalizations.of(context)!.setupItemTitle,
      );
      final sourceBody = item.body.isEmpty ? AppLocalizations.of(context)!.setupWaitingConfigLoad : item.body;
      final normalizedBody = title == AppLocalizations.of(context)!.setupOpenAiTitle
          ? AppLocalizations.of(context)!.setupOpenAiDescription
          : (item.purpose.isNotEmpty
                ? item.purpose
                : _extractSetupPurpose(sourceBody));
      checks.add(
        SetupCheckVm(
          index: '${checks.length + 1}',
          title: title,
          body: normalizedBody,
          action: _setupActionForTitle(item.action, title),
          state: item.state.isNotEmpty ? item.state : AppLocalizations.of(context)!.setupPending,
          ok: item.ok,
          secondaryActionLabel: title == AppLocalizations.of(context)!.setupOpenAiTitle ? AppLocalizations.of(context)!.actionEditConfig : null,
          secondaryActionPath: title == AppLocalizations.of(context)!.setupOpenAiTitle ? AppLocalizations.of(context)!.actionConfigurePathToken : null,
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
    if (ok == true) return AppLocalizations.of(context)!.setupHealthy;
    if (ok == false) return AppLocalizations.of(context)!.setupNeedsAction;
    return AppLocalizations.of(context)!.setupPending;
  }

  String _normalizeSetupTitle(String title) {
    if (title == AppLocalizations.of(context)!.setupSidecarServiceTitle) return _sidecarSetupTitle;
    return title;
  }
}
