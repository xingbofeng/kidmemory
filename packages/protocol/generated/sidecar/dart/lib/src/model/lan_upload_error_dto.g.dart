// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_upload_error_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanUploadErrorDtoCWProxy {
  LanUploadErrorDto filename(String filename);

  LanUploadErrorDto errorCode(String errorCode);

  LanUploadErrorDto message(String message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanUploadErrorDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanUploadErrorDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanUploadErrorDto call({String filename, String errorCode, String message});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanUploadErrorDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanUploadErrorDto.copyWith.fieldName(...)`
class _$LanUploadErrorDtoCWProxyImpl implements _$LanUploadErrorDtoCWProxy {
  const _$LanUploadErrorDtoCWProxyImpl(this._value);

  final LanUploadErrorDto _value;

  @override
  LanUploadErrorDto filename(String filename) => this(filename: filename);

  @override
  LanUploadErrorDto errorCode(String errorCode) => this(errorCode: errorCode);

  @override
  LanUploadErrorDto message(String message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanUploadErrorDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanUploadErrorDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanUploadErrorDto call({
    Object? filename = const $CopyWithPlaceholder(),
    Object? errorCode = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return LanUploadErrorDto(
      filename: filename == const $CopyWithPlaceholder()
          ? _value.filename
          // ignore: cast_nullable_to_non_nullable
          : filename as String,
      errorCode: errorCode == const $CopyWithPlaceholder()
          ? _value.errorCode
          // ignore: cast_nullable_to_non_nullable
          : errorCode as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
    );
  }
}

extension $LanUploadErrorDtoCopyWith on LanUploadErrorDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanUploadErrorDto.copyWith(...)` or like so:`instanceOfLanUploadErrorDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanUploadErrorDtoCWProxy get copyWith =>
      _$LanUploadErrorDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanUploadErrorDto _$LanUploadErrorDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LanUploadErrorDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['filename', 'errorCode', 'message'],
      );
      final val = LanUploadErrorDto(
        filename: $checkedConvert('filename', (v) => v as String),
        errorCode: $checkedConvert('errorCode', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LanUploadErrorDtoToJson(LanUploadErrorDto instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'errorCode': instance.errorCode,
      'message': instance.message,
    };
