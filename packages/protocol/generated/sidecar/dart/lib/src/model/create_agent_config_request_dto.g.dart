// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_agent_config_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateAgentConfigRequestDtoCWProxy {
  CreateAgentConfigRequestDto name(String name);

  CreateAgentConfigRequestDto description(String? description);

  CreateAgentConfigRequestDto provider(String provider);

  CreateAgentConfigRequestDto model(String model);

  CreateAgentConfigRequestDto apiKey(String apiKey);

  CreateAgentConfigRequestDto baseUrl(String? baseUrl);

  CreateAgentConfigRequestDto temperature(num? temperature);

  CreateAgentConfigRequestDto maxTokens(int? maxTokens);

  CreateAgentConfigRequestDto systemPrompt(String? systemPrompt);

  CreateAgentConfigRequestDto toolsEnabled(List<String>? toolsEnabled);

  CreateAgentConfigRequestDto workspaceConfig(
    Map<String, Object>? workspaceConfig,
  );

  CreateAgentConfigRequestDto isDefault(bool? isDefault);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateAgentConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateAgentConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateAgentConfigRequestDto call({
    String name,
    String? description,
    String provider,
    String model,
    String apiKey,
    String? baseUrl,
    num? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? toolsEnabled,
    Map<String, Object>? workspaceConfig,
    bool? isDefault,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateAgentConfigRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateAgentConfigRequestDto.copyWith.fieldName(...)`
class _$CreateAgentConfigRequestDtoCWProxyImpl
    implements _$CreateAgentConfigRequestDtoCWProxy {
  const _$CreateAgentConfigRequestDtoCWProxyImpl(this._value);

  final CreateAgentConfigRequestDto _value;

  @override
  CreateAgentConfigRequestDto name(String name) => this(name: name);

  @override
  CreateAgentConfigRequestDto description(String? description) =>
      this(description: description);

  @override
  CreateAgentConfigRequestDto provider(String provider) =>
      this(provider: provider);

  @override
  CreateAgentConfigRequestDto model(String model) => this(model: model);

  @override
  CreateAgentConfigRequestDto apiKey(String apiKey) => this(apiKey: apiKey);

  @override
  CreateAgentConfigRequestDto baseUrl(String? baseUrl) =>
      this(baseUrl: baseUrl);

  @override
  CreateAgentConfigRequestDto temperature(num? temperature) =>
      this(temperature: temperature);

  @override
  CreateAgentConfigRequestDto maxTokens(int? maxTokens) =>
      this(maxTokens: maxTokens);

  @override
  CreateAgentConfigRequestDto systemPrompt(String? systemPrompt) =>
      this(systemPrompt: systemPrompt);

  @override
  CreateAgentConfigRequestDto toolsEnabled(List<String>? toolsEnabled) =>
      this(toolsEnabled: toolsEnabled);

  @override
  CreateAgentConfigRequestDto workspaceConfig(
    Map<String, Object>? workspaceConfig,
  ) => this(workspaceConfig: workspaceConfig);

  @override
  CreateAgentConfigRequestDto isDefault(bool? isDefault) =>
      this(isDefault: isDefault);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateAgentConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateAgentConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateAgentConfigRequestDto call({
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
    Object? apiKey = const $CopyWithPlaceholder(),
    Object? baseUrl = const $CopyWithPlaceholder(),
    Object? temperature = const $CopyWithPlaceholder(),
    Object? maxTokens = const $CopyWithPlaceholder(),
    Object? systemPrompt = const $CopyWithPlaceholder(),
    Object? toolsEnabled = const $CopyWithPlaceholder(),
    Object? workspaceConfig = const $CopyWithPlaceholder(),
    Object? isDefault = const $CopyWithPlaceholder(),
  }) {
    return CreateAgentConfigRequestDto(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as String,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      apiKey: apiKey == const $CopyWithPlaceholder()
          ? _value.apiKey
          // ignore: cast_nullable_to_non_nullable
          : apiKey as String,
      baseUrl: baseUrl == const $CopyWithPlaceholder()
          ? _value.baseUrl
          // ignore: cast_nullable_to_non_nullable
          : baseUrl as String?,
      temperature: temperature == const $CopyWithPlaceholder()
          ? _value.temperature
          // ignore: cast_nullable_to_non_nullable
          : temperature as num?,
      maxTokens: maxTokens == const $CopyWithPlaceholder()
          ? _value.maxTokens
          // ignore: cast_nullable_to_non_nullable
          : maxTokens as int?,
      systemPrompt: systemPrompt == const $CopyWithPlaceholder()
          ? _value.systemPrompt
          // ignore: cast_nullable_to_non_nullable
          : systemPrompt as String?,
      toolsEnabled: toolsEnabled == const $CopyWithPlaceholder()
          ? _value.toolsEnabled
          // ignore: cast_nullable_to_non_nullable
          : toolsEnabled as List<String>?,
      workspaceConfig: workspaceConfig == const $CopyWithPlaceholder()
          ? _value.workspaceConfig
          // ignore: cast_nullable_to_non_nullable
          : workspaceConfig as Map<String, Object>?,
      isDefault: isDefault == const $CopyWithPlaceholder()
          ? _value.isDefault
          // ignore: cast_nullable_to_non_nullable
          : isDefault as bool?,
    );
  }
}

extension $CreateAgentConfigRequestDtoCopyWith on CreateAgentConfigRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateAgentConfigRequestDto.copyWith(...)` or like so:`instanceOfCreateAgentConfigRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateAgentConfigRequestDtoCWProxy get copyWith =>
      _$CreateAgentConfigRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAgentConfigRequestDto _$CreateAgentConfigRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateAgentConfigRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['name', 'provider', 'model', 'apiKey']);
  final val = CreateAgentConfigRequestDto(
    name: $checkedConvert('name', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String?),
    provider: $checkedConvert('provider', (v) => v as String),
    model: $checkedConvert('model', (v) => v as String),
    apiKey: $checkedConvert('apiKey', (v) => v as String),
    baseUrl: $checkedConvert('baseUrl', (v) => v as String?),
    temperature: $checkedConvert('temperature', (v) => v as num?),
    maxTokens: $checkedConvert('maxTokens', (v) => (v as num?)?.toInt()),
    systemPrompt: $checkedConvert('systemPrompt', (v) => v as String?),
    toolsEnabled: $checkedConvert(
      'toolsEnabled',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    workspaceConfig: $checkedConvert(
      'workspaceConfig',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    isDefault: $checkedConvert('isDefault', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$CreateAgentConfigRequestDtoToJson(
  CreateAgentConfigRequestDto instance,
) => <String, dynamic>{
  'name': instance.name,
if (instance.description != null) 'description': instance.description,
  'provider': instance.provider,
  'model': instance.model,
  'apiKey': instance.apiKey,
if (instance.baseUrl != null) 'baseUrl': instance.baseUrl,
if (instance.temperature != null) 'temperature': instance.temperature,
if (instance.maxTokens != null) 'maxTokens': instance.maxTokens,
if (instance.systemPrompt != null) 'systemPrompt': instance.systemPrompt,
if (instance.toolsEnabled != null) 'toolsEnabled': instance.toolsEnabled,
if (instance.workspaceConfig != null) 'workspaceConfig': instance.workspaceConfig,
if (instance.isDefault != null) 'isDefault': instance.isDefault,
};
