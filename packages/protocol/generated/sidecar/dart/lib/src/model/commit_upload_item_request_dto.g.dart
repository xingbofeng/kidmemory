// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit_upload_item_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommitUploadItemRequestDtoCWProxy {
  CommitUploadItemRequestDto token(String token);

  CommitUploadItemRequestDto objectKey(String objectKey);

  CommitUploadItemRequestDto sizeBytes(int sizeBytes);

  CommitUploadItemRequestDto contentType(String contentType);

  CommitUploadItemRequestDto remoteEtag(String? remoteEtag);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitUploadItemRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitUploadItemRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitUploadItemRequestDto call({
    String token,
    String objectKey,
    int sizeBytes,
    String contentType,
    String? remoteEtag,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommitUploadItemRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommitUploadItemRequestDto.copyWith.fieldName(...)`
class _$CommitUploadItemRequestDtoCWProxyImpl
    implements _$CommitUploadItemRequestDtoCWProxy {
  const _$CommitUploadItemRequestDtoCWProxyImpl(this._value);

  final CommitUploadItemRequestDto _value;

  @override
  CommitUploadItemRequestDto token(String token) => this(token: token);

  @override
  CommitUploadItemRequestDto objectKey(String objectKey) =>
      this(objectKey: objectKey);

  @override
  CommitUploadItemRequestDto sizeBytes(int sizeBytes) =>
      this(sizeBytes: sizeBytes);

  @override
  CommitUploadItemRequestDto contentType(String contentType) =>
      this(contentType: contentType);

  @override
  CommitUploadItemRequestDto remoteEtag(String? remoteEtag) =>
      this(remoteEtag: remoteEtag);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitUploadItemRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitUploadItemRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitUploadItemRequestDto call({
    Object? token = const $CopyWithPlaceholder(),
    Object? objectKey = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? remoteEtag = const $CopyWithPlaceholder(),
  }) {
    return CommitUploadItemRequestDto(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      objectKey: objectKey == const $CopyWithPlaceholder()
          ? _value.objectKey
          // ignore: cast_nullable_to_non_nullable
          : objectKey as String,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int,
      contentType: contentType == const $CopyWithPlaceholder()
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String,
      remoteEtag: remoteEtag == const $CopyWithPlaceholder()
          ? _value.remoteEtag
          // ignore: cast_nullable_to_non_nullable
          : remoteEtag as String?,
    );
  }
}

extension $CommitUploadItemRequestDtoCopyWith on CommitUploadItemRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfCommitUploadItemRequestDto.copyWith(...)` or like so:`instanceOfCommitUploadItemRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommitUploadItemRequestDtoCWProxy get copyWith =>
      _$CommitUploadItemRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitUploadItemRequestDto _$CommitUploadItemRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CommitUploadItemRequestDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['token', 'objectKey', 'sizeBytes', 'contentType'],
  );
  final val = CommitUploadItemRequestDto(
    token: $checkedConvert('token', (v) => v as String),
    objectKey: $checkedConvert('objectKey', (v) => v as String),
    sizeBytes: $checkedConvert('sizeBytes', (v) => (v as num).toInt()),
    contentType: $checkedConvert('contentType', (v) => v as String),
    remoteEtag: $checkedConvert('remoteEtag', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CommitUploadItemRequestDtoToJson(
  CommitUploadItemRequestDto instance,
) => <String, dynamic>{
  'token': instance.token,
  'objectKey': instance.objectKey,
  'sizeBytes': instance.sizeBytes,
  'contentType': instance.contentType,
if (instance.remoteEtag != null) 'remoteEtag': instance.remoteEtag,
};
