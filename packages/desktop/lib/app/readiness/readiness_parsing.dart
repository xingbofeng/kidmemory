part of '../desktop_shell.dart';

class _UiConfigParsed {
  const _UiConfigParsed({
    required this.setupChecks,
    required this.searchTypeOptions,
    required this.templates,
    required this.pageSizes,
    required this.styles,
    required this.exportTargets,
    required this.defaults,
  });

  factory _UiConfigParsed.fromJson(Map<String, dynamic> raw) {
    final setup = _jsonMapAt(raw, 'setup');
    final search = _jsonMapAt(raw, 'search');
    final generate = _jsonMapAt(raw, 'generate');
    final defaults = _jsonMapAt(generate, 'defaults');
    List<_SetupCheckParsed> setupChecks() {
      return _jsonListAt(setup, 'checks')
          .whereType<Map<String, dynamic>>()
          .map(_SetupCheckParsed.fromJson)
          .toList();
    }

    List<_LabeledOptionParsed> typeOptions() {
      return _jsonListAt(search, 'typeOptions')
          .whereType<Map<String, dynamic>>()
          .map(_LabeledOptionParsed.fromJson)
          .toList();
    }

    List<String> stringListAt(String key) {
      return _jsonListAt(generate, key)
          .map((item) => '$item'.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return _UiConfigParsed(
      setupChecks: setupChecks(),
      searchTypeOptions: typeOptions(),
      templates: stringListAt('templates'),
      pageSizes: stringListAt('pageSizes'),
      styles: stringListAt('styles'),
      exportTargets: stringListAt('exportTargets'),
      defaults: _GenerateDefaultsParsed.fromJson(defaults),
    );
  }

  final List<_SetupCheckParsed> setupChecks;
  final List<_LabeledOptionParsed> searchTypeOptions;
  final List<String> templates;
  final List<String> pageSizes;
  final List<String> styles;
  final List<String> exportTargets;
  final _GenerateDefaultsParsed defaults;
}

class _SetupCheckParsed {
  const _SetupCheckParsed({
    required this.title,
    required this.body,
    required this.purpose,
    required this.action,
    required this.state,
    required this.ok,
  });

  factory _SetupCheckParsed.fromJson(Map<String, dynamic> raw) {
    return _SetupCheckParsed(
      title: _stringAt(raw, 'title'),
      body: _stringAt(raw, 'body'),
      purpose: _stringAt(raw, 'purpose'),
      action: _stringAt(raw, 'action'),
      state: _stringAt(raw, 'state'),
      ok: raw['ok'] is bool ? raw['ok'] as bool : null,
    );
  }

  final String title;
  final String body;
  final String purpose;
  final String action;
  final String state;
  final bool? ok;
}

class _LabeledOptionParsed {
  const _LabeledOptionParsed({required this.value, required this.label});

  factory _LabeledOptionParsed.fromJson(Map<String, dynamic> raw) {
    final value = _stringAt(raw, 'value');
    final label = _stringAt(raw, 'label');
    return _LabeledOptionParsed(value: value, label: label);
  }

  final String value;
  final String label;
}

class _GenerateDefaultsParsed {
  const _GenerateDefaultsParsed({
    required this.template,
    required this.pageSize,
    required this.style,
    required this.exportTarget,
  });

  factory _GenerateDefaultsParsed.fromJson(Map<String, dynamic> raw) {
    return _GenerateDefaultsParsed(
      template: _stringAt(raw, 'template'),
      pageSize: _stringAt(raw, 'pageSize'),
      style: _stringAt(raw, 'style'),
      exportTarget: _stringAt(raw, 'exportTarget'),
    );
  }

  final String template;
  final String pageSize;
  final String style;
  final String exportTarget;
}
