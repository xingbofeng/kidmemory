// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exported_payload_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportedPayloadResponseDtoCWProxy {
  ExportedPayloadResponseDto ok(bool? ok);

  ExportedPayloadResponseDto path(String? path);

  ExportedPayloadResponseDto message(String? message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportedPayloadResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportedPayloadResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportedPayloadResponseDto call({bool? ok, String? path, String? message});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportedPayloadResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportedPayloadResponseDto.copyWith.fieldName(...)`
class _$ExportedPayloadResponseDtoCWProxyImpl
    implements _$ExportedPayloadResponseDtoCWProxy {
  const _$ExportedPayloadResponseDtoCWProxyImpl(this._value);

  final ExportedPayloadResponseDto _value;

  @override
  ExportedPayloadResponseDto ok(bool? ok) => this(ok: ok);

  @override
  ExportedPayloadResponseDto path(String? path) => this(path: path);

  @override
  ExportedPayloadResponseDto message(String? message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportedPayloadResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportedPayloadResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportedPayloadResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return ExportedPayloadResponseDto(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool?,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
    );
  }
}

extension $ExportedPayloadResponseDtoCopyWith on ExportedPayloadResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfExportedPayloadResponseDto.copyWith(...)` or like so:`instanceOfExportedPayloadResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportedPayloadResponseDtoCWProxy get copyWith =>
      _$ExportedPayloadResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportedPayloadResponseDto _$ExportedPayloadResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExportedPayloadResponseDto', json, ($checkedConvert) {
  final val = ExportedPayloadResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    path: $checkedConvert('path', (v) => v as String?),
    message: $checkedConvert('message', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ExportedPayloadResponseDtoToJson(
  ExportedPayloadResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.path != null) 'path': instance.path,
if (instance.message != null) 'message': instance.message,
};
