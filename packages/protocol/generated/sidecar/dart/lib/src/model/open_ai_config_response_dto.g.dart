// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_ai_config_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OpenAiConfigResponseDtoCWProxy {
  OpenAiConfigResponseDto baseUrl(String? baseUrl);

  OpenAiConfigResponseDto model(String? model);

  OpenAiConfigResponseDto apiKeyConfigured(bool? apiKeyConfigured);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OpenAiConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OpenAiConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  OpenAiConfigResponseDto call({
    String? baseUrl,
    String? model,
    bool? apiKeyConfigured,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOpenAiConfigResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOpenAiConfigResponseDto.copyWith.fieldName(...)`
class _$OpenAiConfigResponseDtoCWProxyImpl
    implements _$OpenAiConfigResponseDtoCWProxy {
  const _$OpenAiConfigResponseDtoCWProxyImpl(this._value);

  final OpenAiConfigResponseDto _value;

  @override
  OpenAiConfigResponseDto baseUrl(String? baseUrl) => this(baseUrl: baseUrl);

  @override
  OpenAiConfigResponseDto model(String? model) => this(model: model);

  @override
  OpenAiConfigResponseDto apiKeyConfigured(bool? apiKeyConfigured) =>
      this(apiKeyConfigured: apiKeyConfigured);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OpenAiConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OpenAiConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  OpenAiConfigResponseDto call({
    Object? baseUrl = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
    Object? apiKeyConfigured = const $CopyWithPlaceholder(),
  }) {
    return OpenAiConfigResponseDto(
      baseUrl: baseUrl == const $CopyWithPlaceholder()
          ? _value.baseUrl
          // ignore: cast_nullable_to_non_nullable
          : baseUrl as String?,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String?,
      apiKeyConfigured: apiKeyConfigured == const $CopyWithPlaceholder()
          ? _value.apiKeyConfigured
          // ignore: cast_nullable_to_non_nullable
          : apiKeyConfigured as bool?,
    );
  }
}

extension $OpenAiConfigResponseDtoCopyWith on OpenAiConfigResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfOpenAiConfigResponseDto.copyWith(...)` or like so:`instanceOfOpenAiConfigResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OpenAiConfigResponseDtoCWProxy get copyWith =>
      _$OpenAiConfigResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiConfigResponseDto _$OpenAiConfigResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OpenAiConfigResponseDto', json, ($checkedConvert) {
  final val = OpenAiConfigResponseDto(
    baseUrl: $checkedConvert('baseUrl', (v) => v as String?),
    model: $checkedConvert('model', (v) => v as String?),
    apiKeyConfigured: $checkedConvert('apiKeyConfigured', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$OpenAiConfigResponseDtoToJson(
  OpenAiConfigResponseDto instance,
) => <String, dynamic>{
if (instance.baseUrl != null) 'baseUrl': instance.baseUrl,
if (instance.model != null) 'model': instance.model,
if (instance.apiKeyConfigured != null) 'apiKeyConfigured': instance.apiKeyConfigured,
};
