// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_upload_item_file_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateUploadItemFileDtoCWProxy {
  CreateUploadItemFileDto clientFileId(String clientFileId);

  CreateUploadItemFileDto filename(String filename);

  CreateUploadItemFileDto contentType(String contentType);

  CreateUploadItemFileDto sizeBytes(int sizeBytes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateUploadItemFileDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateUploadItemFileDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateUploadItemFileDto call({
    String clientFileId,
    String filename,
    String contentType,
    int sizeBytes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateUploadItemFileDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateUploadItemFileDto.copyWith.fieldName(...)`
class _$CreateUploadItemFileDtoCWProxyImpl
    implements _$CreateUploadItemFileDtoCWProxy {
  const _$CreateUploadItemFileDtoCWProxyImpl(this._value);

  final CreateUploadItemFileDto _value;

  @override
  CreateUploadItemFileDto clientFileId(String clientFileId) =>
      this(clientFileId: clientFileId);

  @override
  CreateUploadItemFileDto filename(String filename) => this(filename: filename);

  @override
  CreateUploadItemFileDto contentType(String contentType) =>
      this(contentType: contentType);

  @override
  CreateUploadItemFileDto sizeBytes(int sizeBytes) =>
      this(sizeBytes: sizeBytes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateUploadItemFileDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateUploadItemFileDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateUploadItemFileDto call({
    Object? clientFileId = const $CopyWithPlaceholder(),
    Object? filename = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
  }) {
    return CreateUploadItemFileDto(
      clientFileId: clientFileId == const $CopyWithPlaceholder()
          ? _value.clientFileId
          // ignore: cast_nullable_to_non_nullable
          : clientFileId as String,
      filename: filename == const $CopyWithPlaceholder()
          ? _value.filename
          // ignore: cast_nullable_to_non_nullable
          : filename as String,
      contentType: contentType == const $CopyWithPlaceholder()
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int,
    );
  }
}

extension $CreateUploadItemFileDtoCopyWith on CreateUploadItemFileDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateUploadItemFileDto.copyWith(...)` or like so:`instanceOfCreateUploadItemFileDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateUploadItemFileDtoCWProxy get copyWith =>
      _$CreateUploadItemFileDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUploadItemFileDto _$CreateUploadItemFileDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateUploadItemFileDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'clientFileId',
      'filename',
      'contentType',
      'sizeBytes',
    ],
  );
  final val = CreateUploadItemFileDto(
    clientFileId: $checkedConvert('clientFileId', (v) => v as String),
    filename: $checkedConvert('filename', (v) => v as String),
    contentType: $checkedConvert('contentType', (v) => v as String),
    sizeBytes: $checkedConvert('sizeBytes', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$CreateUploadItemFileDtoToJson(
  CreateUploadItemFileDto instance,
) => <String, dynamic>{
  'clientFileId': instance.clientFileId,
  'filename': instance.filename,
  'contentType': instance.contentType,
  'sizeBytes': instance.sizeBytes,
};
