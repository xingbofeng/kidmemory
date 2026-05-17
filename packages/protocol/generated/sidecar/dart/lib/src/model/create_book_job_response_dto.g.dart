// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_book_job_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateBookJobResponseDtoCWProxy {
  CreateBookJobResponseDto ok(bool? ok);

  CreateBookJobResponseDto success(bool? success);

  CreateBookJobResponseDto message(String? message);

  CreateBookJobResponseDto code(String? code);

  CreateBookJobResponseDto id(String? id);

  CreateBookJobResponseDto status(String? status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateBookJobResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateBookJobResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateBookJobResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
    String? id,
    String? status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateBookJobResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateBookJobResponseDto.copyWith.fieldName(...)`
class _$CreateBookJobResponseDtoCWProxyImpl
    implements _$CreateBookJobResponseDtoCWProxy {
  const _$CreateBookJobResponseDtoCWProxyImpl(this._value);

  final CreateBookJobResponseDto _value;

  @override
  CreateBookJobResponseDto ok(bool? ok) => this(ok: ok);

  @override
  CreateBookJobResponseDto success(bool? success) => this(success: success);

  @override
  CreateBookJobResponseDto message(String? message) => this(message: message);

  @override
  CreateBookJobResponseDto code(String? code) => this(code: code);

  @override
  CreateBookJobResponseDto id(String? id) => this(id: id);

  @override
  CreateBookJobResponseDto status(String? status) => this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateBookJobResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateBookJobResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateBookJobResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return CreateBookJobResponseDto(
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
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
    );
  }
}

extension $CreateBookJobResponseDtoCopyWith on CreateBookJobResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateBookJobResponseDto.copyWith(...)` or like so:`instanceOfCreateBookJobResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateBookJobResponseDtoCWProxy get copyWith =>
      _$CreateBookJobResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookJobResponseDto _$CreateBookJobResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateBookJobResponseDto', json, ($checkedConvert) {
  final val = CreateBookJobResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String?),
    id: $checkedConvert('id', (v) => v as String?),
    status: $checkedConvert('status', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CreateBookJobResponseDtoToJson(
  CreateBookJobResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
if (instance.id != null) 'id': instance.id,
if (instance.status != null) 'status': instance.status,
};
