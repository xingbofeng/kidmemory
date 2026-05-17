// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_upload_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanUploadResponseDtoCWProxy {
  LanUploadResponseDto success(bool success);

  LanUploadResponseDto uploadedFiles(
    List<LanUploadResultFileDto> uploadedFiles,
  );

  LanUploadResponseDto errors(List<LanUploadErrorDto> errors);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanUploadResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanUploadResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanUploadResponseDto call({
    bool success,
    List<LanUploadResultFileDto> uploadedFiles,
    List<LanUploadErrorDto> errors,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanUploadResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanUploadResponseDto.copyWith.fieldName(...)`
class _$LanUploadResponseDtoCWProxyImpl
    implements _$LanUploadResponseDtoCWProxy {
  const _$LanUploadResponseDtoCWProxyImpl(this._value);

  final LanUploadResponseDto _value;

  @override
  LanUploadResponseDto success(bool success) => this(success: success);

  @override
  LanUploadResponseDto uploadedFiles(
    List<LanUploadResultFileDto> uploadedFiles,
  ) => this(uploadedFiles: uploadedFiles);

  @override
  LanUploadResponseDto errors(List<LanUploadErrorDto> errors) =>
      this(errors: errors);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanUploadResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanUploadResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanUploadResponseDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? uploadedFiles = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
  }) {
    return LanUploadResponseDto(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool,
      uploadedFiles: uploadedFiles == const $CopyWithPlaceholder()
          ? _value.uploadedFiles
          // ignore: cast_nullable_to_non_nullable
          : uploadedFiles as List<LanUploadResultFileDto>,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as List<LanUploadErrorDto>,
    );
  }
}

extension $LanUploadResponseDtoCopyWith on LanUploadResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanUploadResponseDto.copyWith(...)` or like so:`instanceOfLanUploadResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanUploadResponseDtoCWProxy get copyWith =>
      _$LanUploadResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanUploadResponseDto _$LanUploadResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LanUploadResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['success', 'uploadedFiles', 'errors']);
  final val = LanUploadResponseDto(
    success: $checkedConvert('success', (v) => v as bool),
    uploadedFiles: $checkedConvert(
      'uploadedFiles',
      (v) => (v as List<dynamic>)
          .map(
            (e) => LanUploadResultFileDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    errors: $checkedConvert(
      'errors',
      (v) => (v as List<dynamic>)
          .map((e) => LanUploadErrorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$LanUploadResponseDtoToJson(
  LanUploadResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'uploadedFiles': instance.uploadedFiles.map((e) => e.toJson()).toList(),
  'errors': instance.errors.map((e) => e.toJson()).toList(),
};
