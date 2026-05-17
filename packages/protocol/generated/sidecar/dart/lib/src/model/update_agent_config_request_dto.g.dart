// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_agent_config_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateAgentConfigRequestDtoCWProxy {
  UpdateAgentConfigRequestDto name(String? name);

  UpdateAgentConfigRequestDto description(String? description);

  UpdateAgentConfigRequestDto provider(String? provider);

  UpdateAgentConfigRequestDto model(String? model);

  UpdateAgentConfigRequestDto apiKey(String? apiKey);

  UpdateAgentConfigRequestDto baseUrl(String? baseUrl);

  UpdateAgentConfigRequestDto temperature(num? temperature);

  UpdateAgentConfigRequestDto maxTokens(int? maxTokens);

  UpdateAgentConfigRequestDto systemPrompt(String? systemPrompt);

  UpdateAgentConfigRequestDto toolsEnabled(List<String>? toolsEnabled);

  UpdateAgentConfigRequestDto workspaceConfig(
    Map<String, Object>? workspaceConfig,
  );

  UpdateAgentConfigRequestDto isActive(bool? isActive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateAgentConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateAgentConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateAgentConfigRequestDto call({
    String? name,
    String? description,
    String? provider,
    String? model,
    String? apiKey,
    String? baseUrl,
    num? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? toolsEnabled,
    Map<String, Object>? workspaceConfig,
    bool? isActive,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateAgentConfigRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateAgentConfigRequestDto.copyWith.fieldName(...)`
class _$UpdateAgentConfigRequestDtoCWProxyImpl
    implements _$UpdateAgentConfigRequestDtoCWProxy {
  const _$UpdateAgentConfigRequestDtoCWProxyImpl(this._value);

  final UpdateAgentConfigRequestDto _value;

  @override
  UpdateAgentConfigRequestDto name(String? name) => this(name: name);

  @override
  UpdateAgentConfigRequestDto description(String? description) =>
      this(description: description);

  @override
  UpdateAgentConfigRequestDto provider(String? provider) =>
      this(provider: provider);

  @override
  UpdateAgentConfigRequestDto model(String? model) => this(model: model);

  @override
  UpdateAgentConfigRequestDto apiKey(String? apiKey) => this(apiKey: apiKey);

  @override
  UpdateAgentConfigRequestDto baseUrl(String? baseUrl) =>
      this(baseUrl: baseUrl);

  @override
  UpdateAgentConfigRequestDto temperature(num? temperature) =>
      this(temperature: temperature);

  @override
  UpdateAgentConfigRequestDto maxTokens(int? maxTokens) =>
      this(maxTokens: maxTokens);

  @override
  UpdateAgentConfigRequestDto systemPrompt(String? systemPrompt) =>
      this(systemPrompt: systemPrompt);

  @override
  UpdateAgentConfigRequestDto toolsEnabled(List<String>? toolsEnabled) =>
      this(toolsEnabled: toolsEnabled);

  @override
  UpdateAgentConfigRequestDto workspaceConfig(
    Map<String, Object>? workspaceConfig,
  ) => this(workspaceConfig: workspaceConfig);

  @override
  UpdateAgentConfigRequestDto isActive(bool? isActive) =>
      this(isActive: isActive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateAgentConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateAgentConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateAgentConfigRequestDto call({
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
    Object? isActive = const $CopyWithPlaceholder(),
  }) {
    return UpdateAgentConfigRequestDto(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as String?,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String?,
      apiKey: apiKey == const $CopyWithPlaceholder()
          ? _value.apiKey
          // ignore: cast_nullable_to_non_nullable
          : apiKey as String?,
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
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool?,
    );
  }
}

extension $UpdateAgentConfigRequestDtoCopyWith on UpdateAgentConfigRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateAgentConfigRequestDto.copyWith(...)` or like so:`instanceOfUpdateAgentConfigRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateAgentConfigRequestDtoCWProxy get copyWith =>
      _$UpdateAgentConfigRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAgentConfigRequestDto _$UpdateAgentConfigRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateAgentConfigRequestDto', json, ($checkedConvert) {
  final val = UpdateAgentConfigRequestDto(
    name: $checkedConvert('name', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    provider: $checkedConvert('provider', (v) => v as String?),
    model: $checkedConvert('model', (v) => v as String?),
    apiKey: $checkedConvert('apiKey', (v) => v as String?),
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
    isActive: $checkedConvert('isActive', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$UpdateAgentConfigRequestDtoToJson(
  UpdateAgentConfigRequestDto instance,
) => <String, dynamic>{
if (instance.name != null) 'name': instance.name,
if (instance.description != null) 'description': instance.description,
if (instance.provider != null) 'provider': instance.provider,
if (instance.model != null) 'model': instance.model,
if (instance.apiKey != null) 'apiKey': instance.apiKey,
if (instance.baseUrl != null) 'baseUrl': instance.baseUrl,
if (instance.temperature != null) 'temperature': instance.temperature,
if (instance.maxTokens != null) 'maxTokens': instance.maxTokens,
if (instance.systemPrompt != null) 'systemPrompt': instance.systemPrompt,
if (instance.toolsEnabled != null) 'toolsEnabled': instance.toolsEnabled,
if (instance.workspaceConfig != null) 'workspaceConfig': instance.workspaceConfig,
if (instance.isActive != null) 'isActive': instance.isActive,
};
