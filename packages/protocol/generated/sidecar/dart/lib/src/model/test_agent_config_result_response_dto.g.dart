// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_agent_config_result_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TestAgentConfigResultResponseDtoCWProxy {
  TestAgentConfigResultResponseDto success(bool success);

  TestAgentConfigResultResponseDto responseTime(int? responseTime);

  TestAgentConfigResultResponseDto errorMessage(String? errorMessage);

  TestAgentConfigResultResponseDto modelUsed(String? modelUsed);

  TestAgentConfigResultResponseDto tokensUsed(int? tokensUsed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TestAgentConfigResultResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TestAgentConfigResultResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  TestAgentConfigResultResponseDto call({
    bool success,
    int? responseTime,
    String? errorMessage,
    String? modelUsed,
    int? tokensUsed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTestAgentConfigResultResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTestAgentConfigResultResponseDto.copyWith.fieldName(...)`
class _$TestAgentConfigResultResponseDtoCWProxyImpl
    implements _$TestAgentConfigResultResponseDtoCWProxy {
  const _$TestAgentConfigResultResponseDtoCWProxyImpl(this._value);

  final TestAgentConfigResultResponseDto _value;

  @override
  TestAgentConfigResultResponseDto success(bool success) =>
      this(success: success);

  @override
  TestAgentConfigResultResponseDto responseTime(int? responseTime) =>
      this(responseTime: responseTime);

  @override
  TestAgentConfigResultResponseDto errorMessage(String? errorMessage) =>
      this(errorMessage: errorMessage);

  @override
  TestAgentConfigResultResponseDto modelUsed(String? modelUsed) =>
      this(modelUsed: modelUsed);

  @override
  TestAgentConfigResultResponseDto tokensUsed(int? tokensUsed) =>
      this(tokensUsed: tokensUsed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TestAgentConfigResultResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TestAgentConfigResultResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  TestAgentConfigResultResponseDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? responseTime = const $CopyWithPlaceholder(),
    Object? errorMessage = const $CopyWithPlaceholder(),
    Object? modelUsed = const $CopyWithPlaceholder(),
    Object? tokensUsed = const $CopyWithPlaceholder(),
  }) {
    return TestAgentConfigResultResponseDto(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool,
      responseTime: responseTime == const $CopyWithPlaceholder()
          ? _value.responseTime
          // ignore: cast_nullable_to_non_nullable
          : responseTime as int?,
      errorMessage: errorMessage == const $CopyWithPlaceholder()
          ? _value.errorMessage
          // ignore: cast_nullable_to_non_nullable
          : errorMessage as String?,
      modelUsed: modelUsed == const $CopyWithPlaceholder()
          ? _value.modelUsed
          // ignore: cast_nullable_to_non_nullable
          : modelUsed as String?,
      tokensUsed: tokensUsed == const $CopyWithPlaceholder()
          ? _value.tokensUsed
          // ignore: cast_nullable_to_non_nullable
          : tokensUsed as int?,
    );
  }
}

extension $TestAgentConfigResultResponseDtoCopyWith
    on TestAgentConfigResultResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfTestAgentConfigResultResponseDto.copyWith(...)` or like so:`instanceOfTestAgentConfigResultResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TestAgentConfigResultResponseDtoCWProxy get copyWith =>
      _$TestAgentConfigResultResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestAgentConfigResultResponseDto _$TestAgentConfigResultResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TestAgentConfigResultResponseDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['success']);
  final val = TestAgentConfigResultResponseDto(
    success: $checkedConvert('success', (v) => v as bool),
    responseTime: $checkedConvert('responseTime', (v) => (v as num?)?.toInt()),
    errorMessage: $checkedConvert('errorMessage', (v) => v as String?),
    modelUsed: $checkedConvert('modelUsed', (v) => v as String?),
    tokensUsed: $checkedConvert('tokensUsed', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$TestAgentConfigResultResponseDtoToJson(
  TestAgentConfigResultResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
if (instance.responseTime != null) 'responseTime': instance.responseTime,
if (instance.errorMessage != null) 'errorMessage': instance.errorMessage,
if (instance.modelUsed != null) 'modelUsed': instance.modelUsed,
if (instance.tokensUsed != null) 'tokensUsed': instance.tokensUsed,
};
