// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_upload_result_file_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanUploadResultFileDtoCWProxy {
  LanUploadResultFileDto filename(String filename);

  LanUploadResultFileDto assetId(String assetId);

  LanUploadResultFileDto status(String status);

  LanUploadResultFileDto localPath(String localPath);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanUploadResultFileDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanUploadResultFileDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanUploadResultFileDto call({
    String filename,
    String assetId,
    String status,
    String localPath,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanUploadResultFileDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanUploadResultFileDto.copyWith.fieldName(...)`
class _$LanUploadResultFileDtoCWProxyImpl
    implements _$LanUploadResultFileDtoCWProxy {
  const _$LanUploadResultFileDtoCWProxyImpl(this._value);

  final LanUploadResultFileDto _value;

  @override
  LanUploadResultFileDto filename(String filename) => this(filename: filename);

  @override
  LanUploadResultFileDto assetId(String assetId) => this(assetId: assetId);

  @override
  LanUploadResultFileDto status(String status) => this(status: status);

  @override
  LanUploadResultFileDto localPath(String localPath) =>
      this(localPath: localPath);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanUploadResultFileDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanUploadResultFileDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanUploadResultFileDto call({
    Object? filename = const $CopyWithPlaceholder(),
    Object? assetId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? localPath = const $CopyWithPlaceholder(),
  }) {
    return LanUploadResultFileDto(
      filename: filename == const $CopyWithPlaceholder()
          ? _value.filename
          // ignore: cast_nullable_to_non_nullable
          : filename as String,
      assetId: assetId == const $CopyWithPlaceholder()
          ? _value.assetId
          // ignore: cast_nullable_to_non_nullable
          : assetId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      localPath: localPath == const $CopyWithPlaceholder()
          ? _value.localPath
          // ignore: cast_nullable_to_non_nullable
          : localPath as String,
    );
  }
}

extension $LanUploadResultFileDtoCopyWith on LanUploadResultFileDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanUploadResultFileDto.copyWith(...)` or like so:`instanceOfLanUploadResultFileDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanUploadResultFileDtoCWProxy get copyWith =>
      _$LanUploadResultFileDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanUploadResultFileDto _$LanUploadResultFileDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LanUploadResultFileDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['filename', 'assetId', 'status', 'localPath'],
  );
  final val = LanUploadResultFileDto(
    filename: $checkedConvert('filename', (v) => v as String),
    assetId: $checkedConvert('assetId', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    localPath: $checkedConvert('localPath', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$LanUploadResultFileDtoToJson(
  LanUploadResultFileDto instance,
) => <String, dynamic>{
  'filename': instance.filename,
  'assetId': instance.assetId,
  'status': instance.status,
  'localPath': instance.localPath,
};
