// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configure_supabase_storage_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfigureSupabaseStorageResponseDtoCWProxy {
  ConfigureSupabaseStorageResponseDto ok(bool? ok);

  ConfigureSupabaseStorageResponseDto success(bool? success);

  ConfigureSupabaseStorageResponseDto message(String? message);

  ConfigureSupabaseStorageResponseDto code(String? code);

  ConfigureSupabaseStorageResponseDto config(
    SupabaseStorageConfigResponseDto? config,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfigureSupabaseStorageResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfigureSupabaseStorageResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfigureSupabaseStorageResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
    SupabaseStorageConfigResponseDto? config,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfigureSupabaseStorageResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfigureSupabaseStorageResponseDto.copyWith.fieldName(...)`
class _$ConfigureSupabaseStorageResponseDtoCWProxyImpl
    implements _$ConfigureSupabaseStorageResponseDtoCWProxy {
  const _$ConfigureSupabaseStorageResponseDtoCWProxyImpl(this._value);

  final ConfigureSupabaseStorageResponseDto _value;

  @override
  ConfigureSupabaseStorageResponseDto ok(bool? ok) => this(ok: ok);

  @override
  ConfigureSupabaseStorageResponseDto success(bool? success) =>
      this(success: success);

  @override
  ConfigureSupabaseStorageResponseDto message(String? message) =>
      this(message: message);

  @override
  ConfigureSupabaseStorageResponseDto code(String? code) => this(code: code);

  @override
  ConfigureSupabaseStorageResponseDto config(
    SupabaseStorageConfigResponseDto? config,
  ) => this(config: config);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfigureSupabaseStorageResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfigureSupabaseStorageResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfigureSupabaseStorageResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? config = const $CopyWithPlaceholder(),
  }) {
    return ConfigureSupabaseStorageResponseDto(
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
      config: config == const $CopyWithPlaceholder()
          ? _value.config
          // ignore: cast_nullable_to_non_nullable
          : config as SupabaseStorageConfigResponseDto?,
    );
  }
}

extension $ConfigureSupabaseStorageResponseDtoCopyWith
    on ConfigureSupabaseStorageResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfConfigureSupabaseStorageResponseDto.copyWith(...)` or like so:`instanceOfConfigureSupabaseStorageResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfigureSupabaseStorageResponseDtoCWProxy get copyWith =>
      _$ConfigureSupabaseStorageResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigureSupabaseStorageResponseDto
_$ConfigureSupabaseStorageResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConfigureSupabaseStorageResponseDto', json, (
      $checkedConvert,
    ) {
      final val = ConfigureSupabaseStorageResponseDto(
        ok: $checkedConvert('ok', (v) => v as bool?),
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        code: $checkedConvert('code', (v) => v as String?),
        config: $checkedConvert(
          'config',
          (v) => v == null
              ? null
              : SupabaseStorageConfigResponseDto.fromJson(
                  v as Map<String, dynamic>,
                ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ConfigureSupabaseStorageResponseDtoToJson(
  ConfigureSupabaseStorageResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
if (instance.config?.toJson() != null) 'config': instance.config?.toJson(),
};
