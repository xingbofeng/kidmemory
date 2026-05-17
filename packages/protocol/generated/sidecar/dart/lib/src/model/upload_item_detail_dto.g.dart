// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_item_detail_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadItemDetailDtoCWProxy {
  UploadItemDetailDto uploadItemId(String uploadItemId);

  UploadItemDetailDto assetId(String assetId);

  UploadItemDetailDto filename(String filename);

  UploadItemDetailDto status(String status);

  UploadItemDetailDto provider(String provider);

  UploadItemDetailDto objectKey(String objectKey);

  UploadItemDetailDto errorCode(String? errorCode);

  UploadItemDetailDto createdAt(String createdAt);

  UploadItemDetailDto updatedAt(String updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadItemDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadItemDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadItemDetailDto call({
    String uploadItemId,
    String assetId,
    String filename,
    String status,
    String provider,
    String objectKey,
    String? errorCode,
    String createdAt,
    String updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadItemDetailDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadItemDetailDto.copyWith.fieldName(...)`
class _$UploadItemDetailDtoCWProxyImpl implements _$UploadItemDetailDtoCWProxy {
  const _$UploadItemDetailDtoCWProxyImpl(this._value);

  final UploadItemDetailDto _value;

  @override
  UploadItemDetailDto uploadItemId(String uploadItemId) =>
      this(uploadItemId: uploadItemId);

  @override
  UploadItemDetailDto assetId(String assetId) => this(assetId: assetId);

  @override
  UploadItemDetailDto filename(String filename) => this(filename: filename);

  @override
  UploadItemDetailDto status(String status) => this(status: status);

  @override
  UploadItemDetailDto provider(String provider) => this(provider: provider);

  @override
  UploadItemDetailDto objectKey(String objectKey) => this(objectKey: objectKey);

  @override
  UploadItemDetailDto errorCode(String? errorCode) =>
      this(errorCode: errorCode);

  @override
  UploadItemDetailDto createdAt(String createdAt) => this(createdAt: createdAt);

  @override
  UploadItemDetailDto updatedAt(String updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadItemDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadItemDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadItemDetailDto call({
    Object? uploadItemId = const $CopyWithPlaceholder(),
    Object? assetId = const $CopyWithPlaceholder(),
    Object? filename = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? objectKey = const $CopyWithPlaceholder(),
    Object? errorCode = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return UploadItemDetailDto(
      uploadItemId: uploadItemId == const $CopyWithPlaceholder()
          ? _value.uploadItemId
          // ignore: cast_nullable_to_non_nullable
          : uploadItemId as String,
      assetId: assetId == const $CopyWithPlaceholder()
          ? _value.assetId
          // ignore: cast_nullable_to_non_nullable
          : assetId as String,
      filename: filename == const $CopyWithPlaceholder()
          ? _value.filename
          // ignore: cast_nullable_to_non_nullable
          : filename as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as String,
      objectKey: objectKey == const $CopyWithPlaceholder()
          ? _value.objectKey
          // ignore: cast_nullable_to_non_nullable
          : objectKey as String,
      errorCode: errorCode == const $CopyWithPlaceholder()
          ? _value.errorCode
          // ignore: cast_nullable_to_non_nullable
          : errorCode as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as String,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as String,
    );
  }
}

extension $UploadItemDetailDtoCopyWith on UploadItemDetailDto {
  /// Returns a callable class that can be used as follows: `instanceOfUploadItemDetailDto.copyWith(...)` or like so:`instanceOfUploadItemDetailDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadItemDetailDtoCWProxy get copyWith =>
      _$UploadItemDetailDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadItemDetailDto _$UploadItemDetailDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UploadItemDetailDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'uploadItemId',
          'assetId',
          'filename',
          'status',
          'provider',
          'objectKey',
          'createdAt',
          'updatedAt',
        ],
      );
      final val = UploadItemDetailDto(
        uploadItemId: $checkedConvert('uploadItemId', (v) => v as String),
        assetId: $checkedConvert('assetId', (v) => v as String),
        filename: $checkedConvert('filename', (v) => v as String),
        status: $checkedConvert('status', (v) => v as String),
        provider: $checkedConvert('provider', (v) => v as String),
        objectKey: $checkedConvert('objectKey', (v) => v as String),
        errorCode: $checkedConvert('errorCode', (v) => v as String?),
        createdAt: $checkedConvert('createdAt', (v) => v as String),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$UploadItemDetailDtoToJson(
  UploadItemDetailDto instance,
) => <String, dynamic>{
  'uploadItemId': instance.uploadItemId,
  'assetId': instance.assetId,
  'filename': instance.filename,
  'status': instance.status,
  'provider': instance.provider,
  'objectKey': instance.objectKey,
if (instance.errorCode != null) 'errorCode': instance.errorCode,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
