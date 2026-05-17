// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_result_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OperationResultResponseDtoCWProxy {
  OperationResultResponseDto ok(bool? ok);

  OperationResultResponseDto success(bool? success);

  OperationResultResponseDto message(String? message);

  OperationResultResponseDto code(String? code);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OperationResultResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OperationResultResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  OperationResultResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOperationResultResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOperationResultResponseDto.copyWith.fieldName(...)`
class _$OperationResultResponseDtoCWProxyImpl
    implements _$OperationResultResponseDtoCWProxy {
  const _$OperationResultResponseDtoCWProxyImpl(this._value);

  final OperationResultResponseDto _value;

  @override
  OperationResultResponseDto ok(bool? ok) => this(ok: ok);

  @override
  OperationResultResponseDto success(bool? success) => this(success: success);

  @override
  OperationResultResponseDto message(String? message) => this(message: message);

  @override
  OperationResultResponseDto code(String? code) => this(code: code);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OperationResultResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OperationResultResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  OperationResultResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
  }) {
    return OperationResultResponseDto(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool?,
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
    );
  }
}

extension $OperationResultResponseDtoCopyWith on OperationResultResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfOperationResultResponseDto.copyWith(...)` or like so:`instanceOfOperationResultResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OperationResultResponseDtoCWProxy get copyWith =>
      _$OperationResultResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperationResultResponseDto _$OperationResultResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OperationResultResponseDto', json, ($checkedConvert) {
  final val = OperationResultResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$OperationResultResponseDtoToJson(
  OperationResultResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
};
