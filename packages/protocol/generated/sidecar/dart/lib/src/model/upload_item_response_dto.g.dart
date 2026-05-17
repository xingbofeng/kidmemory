// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_item_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadItemResponseDtoCWProxy {
  UploadItemResponseDto clientFileId(String clientFileId);

  UploadItemResponseDto uploadItemId(String uploadItemId);

  UploadItemResponseDto assetId(String assetId);

  UploadItemResponseDto objectKey(String objectKey);

  UploadItemResponseDto status(String status);

  UploadItemResponseDto signedUpload(SignedUploadTargetDto? signedUpload);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadItemResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadItemResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadItemResponseDto call({
    String clientFileId,
    String uploadItemId,
    String assetId,
    String objectKey,
    String status,
    SignedUploadTargetDto? signedUpload,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadItemResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadItemResponseDto.copyWith.fieldName(...)`
class _$UploadItemResponseDtoCWProxyImpl
    implements _$UploadItemResponseDtoCWProxy {
  const _$UploadItemResponseDtoCWProxyImpl(this._value);

  final UploadItemResponseDto _value;

  @override
  UploadItemResponseDto clientFileId(String clientFileId) =>
      this(clientFileId: clientFileId);

  @override
  UploadItemResponseDto uploadItemId(String uploadItemId) =>
      this(uploadItemId: uploadItemId);

  @override
  UploadItemResponseDto assetId(String assetId) => this(assetId: assetId);

  @override
  UploadItemResponseDto objectKey(String objectKey) =>
      this(objectKey: objectKey);

  @override
  UploadItemResponseDto status(String status) => this(status: status);

  @override
  UploadItemResponseDto signedUpload(SignedUploadTargetDto? signedUpload) =>
      this(signedUpload: signedUpload);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadItemResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadItemResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadItemResponseDto call({
    Object? clientFileId = const $CopyWithPlaceholder(),
    Object? uploadItemId = const $CopyWithPlaceholder(),
    Object? assetId = const $CopyWithPlaceholder(),
    Object? objectKey = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? signedUpload = const $CopyWithPlaceholder(),
  }) {
    return UploadItemResponseDto(
      clientFileId: clientFileId == const $CopyWithPlaceholder()
          ? _value.clientFileId
          // ignore: cast_nullable_to_non_nullable
          : clientFileId as String,
      uploadItemId: uploadItemId == const $CopyWithPlaceholder()
          ? _value.uploadItemId
          // ignore: cast_nullable_to_non_nullable
          : uploadItemId as String,
      assetId: assetId == const $CopyWithPlaceholder()
          ? _value.assetId
          // ignore: cast_nullable_to_non_nullable
          : assetId as String,
      objectKey: objectKey == const $CopyWithPlaceholder()
          ? _value.objectKey
          // ignore: cast_nullable_to_non_nullable
          : objectKey as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      signedUpload: signedUpload == const $CopyWithPlaceholder()
          ? _value.signedUpload
          // ignore: cast_nullable_to_non_nullable
          : signedUpload as SignedUploadTargetDto?,
    );
  }
}

extension $UploadItemResponseDtoCopyWith on UploadItemResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfUploadItemResponseDto.copyWith(...)` or like so:`instanceOfUploadItemResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadItemResponseDtoCWProxy get copyWith =>
      _$UploadItemResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadItemResponseDto _$UploadItemResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UploadItemResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'clientFileId',
      'uploadItemId',
      'assetId',
      'objectKey',
      'status',
    ],
  );
  final val = UploadItemResponseDto(
    clientFileId: $checkedConvert('clientFileId', (v) => v as String),
    uploadItemId: $checkedConvert('uploadItemId', (v) => v as String),
    assetId: $checkedConvert('assetId', (v) => v as String),
    objectKey: $checkedConvert('objectKey', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    signedUpload: $checkedConvert(
      'signedUpload',
      (v) => v == null
          ? null
          : SignedUploadTargetDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$UploadItemResponseDtoToJson(
  UploadItemResponseDto instance,
) => <String, dynamic>{
  'clientFileId': instance.clientFileId,
  'uploadItemId': instance.uploadItemId,
  'assetId': instance.assetId,
  'objectKey': instance.objectKey,
  'status': instance.status,
if (instance.signedUpload?.toJson() != null) 'signedUpload': instance.signedUpload?.toJson(),
};
