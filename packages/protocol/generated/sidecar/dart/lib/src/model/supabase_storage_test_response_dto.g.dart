// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_storage_test_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SupabaseStorageTestResponseDtoCWProxy {
  SupabaseStorageTestResponseDto ok(bool? ok);

  SupabaseStorageTestResponseDto success(bool? success);

  SupabaseStorageTestResponseDto message(String? message);

  SupabaseStorageTestResponseDto code(String? code);

  SupabaseStorageTestResponseDto cleanup(
    SupabaseStorageTestCleanupResponseDto? cleanup,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseStorageTestResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseStorageTestResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseStorageTestResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
    SupabaseStorageTestCleanupResponseDto? cleanup,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSupabaseStorageTestResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSupabaseStorageTestResponseDto.copyWith.fieldName(...)`
class _$SupabaseStorageTestResponseDtoCWProxyImpl
    implements _$SupabaseStorageTestResponseDtoCWProxy {
  const _$SupabaseStorageTestResponseDtoCWProxyImpl(this._value);

  final SupabaseStorageTestResponseDto _value;

  @override
  SupabaseStorageTestResponseDto ok(bool? ok) => this(ok: ok);

  @override
  SupabaseStorageTestResponseDto success(bool? success) =>
      this(success: success);

  @override
  SupabaseStorageTestResponseDto message(String? message) =>
      this(message: message);

  @override
  SupabaseStorageTestResponseDto code(String? code) => this(code: code);

  @override
  SupabaseStorageTestResponseDto cleanup(
    SupabaseStorageTestCleanupResponseDto? cleanup,
  ) => this(cleanup: cleanup);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseStorageTestResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseStorageTestResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseStorageTestResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? cleanup = const $CopyWithPlaceholder(),
  }) {
    return SupabaseStorageTestResponseDto(
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
      cleanup: cleanup == const $CopyWithPlaceholder()
          ? _value.cleanup
          // ignore: cast_nullable_to_non_nullable
          : cleanup as SupabaseStorageTestCleanupResponseDto?,
    );
  }
}

extension $SupabaseStorageTestResponseDtoCopyWith
    on SupabaseStorageTestResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfSupabaseStorageTestResponseDto.copyWith(...)` or like so:`instanceOfSupabaseStorageTestResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SupabaseStorageTestResponseDtoCWProxy get copyWith =>
      _$SupabaseStorageTestResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupabaseStorageTestResponseDto _$SupabaseStorageTestResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SupabaseStorageTestResponseDto', json, ($checkedConvert) {
  final val = SupabaseStorageTestResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String?),
    cleanup: $checkedConvert(
      'cleanup',
      (v) => v == null
          ? null
          : SupabaseStorageTestCleanupResponseDto.fromJson(
              v as Map<String, dynamic>,
            ),
    ),
  );
  return val;
});

Map<String, dynamic> _$SupabaseStorageTestResponseDtoToJson(
  SupabaseStorageTestResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
if (instance.cleanup?.toJson() != null) 'cleanup': instance.cleanup?.toJson(),
};
