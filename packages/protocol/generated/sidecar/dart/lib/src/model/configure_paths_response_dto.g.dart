// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configure_paths_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfigurePathsResponseDtoCWProxy {
  ConfigurePathsResponseDto ok(bool? ok);

  ConfigurePathsResponseDto success(bool? success);

  ConfigurePathsResponseDto message(String? message);

  ConfigurePathsResponseDto code(String? code);

  ConfigurePathsResponseDto paths(PathConfigResponseDto? paths);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfigurePathsResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfigurePathsResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfigurePathsResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
    PathConfigResponseDto? paths,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfigurePathsResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfigurePathsResponseDto.copyWith.fieldName(...)`
class _$ConfigurePathsResponseDtoCWProxyImpl
    implements _$ConfigurePathsResponseDtoCWProxy {
  const _$ConfigurePathsResponseDtoCWProxyImpl(this._value);

  final ConfigurePathsResponseDto _value;

  @override
  ConfigurePathsResponseDto ok(bool? ok) => this(ok: ok);

  @override
  ConfigurePathsResponseDto success(bool? success) => this(success: success);

  @override
  ConfigurePathsResponseDto message(String? message) => this(message: message);

  @override
  ConfigurePathsResponseDto code(String? code) => this(code: code);

  @override
  ConfigurePathsResponseDto paths(PathConfigResponseDto? paths) =>
      this(paths: paths);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfigurePathsResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfigurePathsResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfigurePathsResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? paths = const $CopyWithPlaceholder(),
  }) {
    return ConfigurePathsResponseDto(
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
      paths: paths == const $CopyWithPlaceholder()
          ? _value.paths
          // ignore: cast_nullable_to_non_nullable
          : paths as PathConfigResponseDto?,
    );
  }
}

extension $ConfigurePathsResponseDtoCopyWith on ConfigurePathsResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfConfigurePathsResponseDto.copyWith(...)` or like so:`instanceOfConfigurePathsResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfigurePathsResponseDtoCWProxy get copyWith =>
      _$ConfigurePathsResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigurePathsResponseDto _$ConfigurePathsResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ConfigurePathsResponseDto', json, ($checkedConvert) {
  final val = ConfigurePathsResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String?),
    paths: $checkedConvert(
      'paths',
      (v) => v == null
          ? null
          : PathConfigResponseDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ConfigurePathsResponseDtoToJson(
  ConfigurePathsResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
if (instance.paths?.toJson() != null) 'paths': instance.paths?.toJson(),
};
