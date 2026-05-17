// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_agent_config_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TestAgentConfigRequestDtoCWProxy {
  TestAgentConfigRequestDto testPrompt(String? testPrompt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TestAgentConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TestAgentConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  TestAgentConfigRequestDto call({String? testPrompt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTestAgentConfigRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTestAgentConfigRequestDto.copyWith.fieldName(...)`
class _$TestAgentConfigRequestDtoCWProxyImpl
    implements _$TestAgentConfigRequestDtoCWProxy {
  const _$TestAgentConfigRequestDtoCWProxyImpl(this._value);

  final TestAgentConfigRequestDto _value;

  @override
  TestAgentConfigRequestDto testPrompt(String? testPrompt) =>
      this(testPrompt: testPrompt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TestAgentConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TestAgentConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  TestAgentConfigRequestDto call({
    Object? testPrompt = const $CopyWithPlaceholder(),
  }) {
    return TestAgentConfigRequestDto(
      testPrompt: testPrompt == const $CopyWithPlaceholder()
          ? _value.testPrompt
          // ignore: cast_nullable_to_non_nullable
          : testPrompt as String?,
    );
  }
}

extension $TestAgentConfigRequestDtoCopyWith on TestAgentConfigRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfTestAgentConfigRequestDto.copyWith(...)` or like so:`instanceOfTestAgentConfigRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TestAgentConfigRequestDtoCWProxy get copyWith =>
      _$TestAgentConfigRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestAgentConfigRequestDto _$TestAgentConfigRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TestAgentConfigRequestDto', json, ($checkedConvert) {
  final val = TestAgentConfigRequestDto(
    testPrompt: $checkedConvert('testPrompt', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$TestAgentConfigRequestDtoToJson(
  TestAgentConfigRequestDto instance,
) => <String, dynamic>{'testPrompt': instance.testPrompt};
