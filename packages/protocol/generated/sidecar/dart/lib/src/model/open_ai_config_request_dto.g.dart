// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_ai_config_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OpenAiConfigRequestDtoCWProxy {
  OpenAiConfigRequestDto baseUrl(String baseUrl);

  OpenAiConfigRequestDto model(String model);

  OpenAiConfigRequestDto apiKey(String? apiKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OpenAiConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OpenAiConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  OpenAiConfigRequestDto call({String baseUrl, String model, String? apiKey});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOpenAiConfigRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOpenAiConfigRequestDto.copyWith.fieldName(...)`
class _$OpenAiConfigRequestDtoCWProxyImpl
    implements _$OpenAiConfigRequestDtoCWProxy {
  const _$OpenAiConfigRequestDtoCWProxyImpl(this._value);

  final OpenAiConfigRequestDto _value;

  @override
  OpenAiConfigRequestDto baseUrl(String baseUrl) => this(baseUrl: baseUrl);

  @override
  OpenAiConfigRequestDto model(String model) => this(model: model);

  @override
  OpenAiConfigRequestDto apiKey(String? apiKey) => this(apiKey: apiKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OpenAiConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OpenAiConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  OpenAiConfigRequestDto call({
    Object? baseUrl = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
    Object? apiKey = const $CopyWithPlaceholder(),
  }) {
    return OpenAiConfigRequestDto(
      baseUrl: baseUrl == const $CopyWithPlaceholder()
          ? _value.baseUrl
          // ignore: cast_nullable_to_non_nullable
          : baseUrl as String,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      apiKey: apiKey == const $CopyWithPlaceholder()
          ? _value.apiKey
          // ignore: cast_nullable_to_non_nullable
          : apiKey as String?,
    );
  }
}

extension $OpenAiConfigRequestDtoCopyWith on OpenAiConfigRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfOpenAiConfigRequestDto.copyWith(...)` or like so:`instanceOfOpenAiConfigRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OpenAiConfigRequestDtoCWProxy get copyWith =>
      _$OpenAiConfigRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiConfigRequestDto _$OpenAiConfigRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OpenAiConfigRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['baseUrl', 'model']);
  final val = OpenAiConfigRequestDto(
    baseUrl: $checkedConvert('baseUrl', (v) => v as String),
    model: $checkedConvert('model', (v) => v as String),
    apiKey: $checkedConvert('apiKey', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$OpenAiConfigRequestDtoToJson(
  OpenAiConfigRequestDto instance,
) => <String, dynamic>{
  'baseUrl': instance.baseUrl,
  'model': instance.model,
if (instance.apiKey != null) 'apiKey': instance.apiKey,
};
