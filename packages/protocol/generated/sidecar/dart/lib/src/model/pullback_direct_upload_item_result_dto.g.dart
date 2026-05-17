// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pullback_direct_upload_item_result_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullbackDirectUploadItemResultDtoCWProxy {
  PullbackDirectUploadItemResultDto objectKey(String objectKey);

  PullbackDirectUploadItemResultDto status(String status);

  PullbackDirectUploadItemResultDto errorCode(String? errorCode);

  PullbackDirectUploadItemResultDto errorMessage(String? errorMessage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullbackDirectUploadItemResultDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullbackDirectUploadItemResultDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PullbackDirectUploadItemResultDto call({
    String objectKey,
    String status,
    String? errorCode,
    String? errorMessage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullbackDirectUploadItemResultDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullbackDirectUploadItemResultDto.copyWith.fieldName(...)`
class _$PullbackDirectUploadItemResultDtoCWProxyImpl
    implements _$PullbackDirectUploadItemResultDtoCWProxy {
  const _$PullbackDirectUploadItemResultDtoCWProxyImpl(this._value);

  final PullbackDirectUploadItemResultDto _value;

  @override
  PullbackDirectUploadItemResultDto objectKey(String objectKey) =>
      this(objectKey: objectKey);

  @override
  PullbackDirectUploadItemResultDto status(String status) =>
      this(status: status);

  @override
  PullbackDirectUploadItemResultDto errorCode(String? errorCode) =>
      this(errorCode: errorCode);

  @override
  PullbackDirectUploadItemResultDto errorMessage(String? errorMessage) =>
      this(errorMessage: errorMessage);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullbackDirectUploadItemResultDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullbackDirectUploadItemResultDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PullbackDirectUploadItemResultDto call({
    Object? objectKey = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? errorCode = const $CopyWithPlaceholder(),
    Object? errorMessage = const $CopyWithPlaceholder(),
  }) {
    return PullbackDirectUploadItemResultDto(
      objectKey: objectKey == const $CopyWithPlaceholder()
          ? _value.objectKey
          // ignore: cast_nullable_to_non_nullable
          : objectKey as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      errorCode: errorCode == const $CopyWithPlaceholder()
          ? _value.errorCode
          // ignore: cast_nullable_to_non_nullable
          : errorCode as String?,
      errorMessage: errorMessage == const $CopyWithPlaceholder()
          ? _value.errorMessage
          // ignore: cast_nullable_to_non_nullable
          : errorMessage as String?,
    );
  }
}

extension $PullbackDirectUploadItemResultDtoCopyWith
    on PullbackDirectUploadItemResultDto {
  /// Returns a callable class that can be used as follows: `instanceOfPullbackDirectUploadItemResultDto.copyWith(...)` or like so:`instanceOfPullbackDirectUploadItemResultDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullbackDirectUploadItemResultDtoCWProxy get copyWith =>
      _$PullbackDirectUploadItemResultDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullbackDirectUploadItemResultDto _$PullbackDirectUploadItemResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PullbackDirectUploadItemResultDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['objectKey', 'status']);
  final val = PullbackDirectUploadItemResultDto(
    objectKey: $checkedConvert('objectKey', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    errorCode: $checkedConvert('errorCode', (v) => v as String?),
    errorMessage: $checkedConvert('errorMessage', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$PullbackDirectUploadItemResultDtoToJson(
  PullbackDirectUploadItemResultDto instance,
) => <String, dynamic>{
  'objectKey': instance.objectKey,
  'status': instance.status,
if (instance.errorCode != null) 'errorCode': instance.errorCode,
if (instance.errorMessage != null) 'errorMessage': instance.errorMessage,
};
