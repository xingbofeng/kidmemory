// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit_upload_item_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommitUploadItemResponseDtoCWProxy {
  CommitUploadItemResponseDto uploadItemId(String uploadItemId);

  CommitUploadItemResponseDto status(String status);

  CommitUploadItemResponseDto idempotent(bool? idempotent);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitUploadItemResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitUploadItemResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitUploadItemResponseDto call({
    String uploadItemId,
    String status,
    bool? idempotent,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommitUploadItemResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommitUploadItemResponseDto.copyWith.fieldName(...)`
class _$CommitUploadItemResponseDtoCWProxyImpl
    implements _$CommitUploadItemResponseDtoCWProxy {
  const _$CommitUploadItemResponseDtoCWProxyImpl(this._value);

  final CommitUploadItemResponseDto _value;

  @override
  CommitUploadItemResponseDto uploadItemId(String uploadItemId) =>
      this(uploadItemId: uploadItemId);

  @override
  CommitUploadItemResponseDto status(String status) => this(status: status);

  @override
  CommitUploadItemResponseDto idempotent(bool? idempotent) =>
      this(idempotent: idempotent);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitUploadItemResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitUploadItemResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitUploadItemResponseDto call({
    Object? uploadItemId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? idempotent = const $CopyWithPlaceholder(),
  }) {
    return CommitUploadItemResponseDto(
      uploadItemId: uploadItemId == const $CopyWithPlaceholder()
          ? _value.uploadItemId
          // ignore: cast_nullable_to_non_nullable
          : uploadItemId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      idempotent: idempotent == const $CopyWithPlaceholder()
          ? _value.idempotent
          // ignore: cast_nullable_to_non_nullable
          : idempotent as bool?,
    );
  }
}

extension $CommitUploadItemResponseDtoCopyWith on CommitUploadItemResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfCommitUploadItemResponseDto.copyWith(...)` or like so:`instanceOfCommitUploadItemResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommitUploadItemResponseDtoCWProxy get copyWith =>
      _$CommitUploadItemResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitUploadItemResponseDto _$CommitUploadItemResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CommitUploadItemResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['uploadItemId', 'status']);
  final val = CommitUploadItemResponseDto(
    uploadItemId: $checkedConvert('uploadItemId', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    idempotent: $checkedConvert('idempotent', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$CommitUploadItemResponseDtoToJson(
  CommitUploadItemResponseDto instance,
) => <String, dynamic>{
  'uploadItemId': instance.uploadItemId,
  'status': instance.status,
if (instance.idempotent != null) 'idempotent': instance.idempotent,
};
