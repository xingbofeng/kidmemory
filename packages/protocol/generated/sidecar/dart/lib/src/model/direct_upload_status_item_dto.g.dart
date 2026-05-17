// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_upload_status_item_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DirectUploadStatusItemDtoCWProxy {
  DirectUploadStatusItemDto objectKey(String objectKey);

  DirectUploadStatusItemDto status(String status);

  DirectUploadStatusItemDto errorCode(String? errorCode);

  DirectUploadStatusItemDto errorMessage(String? errorMessage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DirectUploadStatusItemDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DirectUploadStatusItemDto(...).copyWith(id: 12, name: "My name")
  /// ````
  DirectUploadStatusItemDto call({
    String objectKey,
    String status,
    String? errorCode,
    String? errorMessage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDirectUploadStatusItemDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDirectUploadStatusItemDto.copyWith.fieldName(...)`
class _$DirectUploadStatusItemDtoCWProxyImpl
    implements _$DirectUploadStatusItemDtoCWProxy {
  const _$DirectUploadStatusItemDtoCWProxyImpl(this._value);

  final DirectUploadStatusItemDto _value;

  @override
  DirectUploadStatusItemDto objectKey(String objectKey) =>
      this(objectKey: objectKey);

  @override
  DirectUploadStatusItemDto status(String status) => this(status: status);

  @override
  DirectUploadStatusItemDto errorCode(String? errorCode) =>
      this(errorCode: errorCode);

  @override
  DirectUploadStatusItemDto errorMessage(String? errorMessage) =>
      this(errorMessage: errorMessage);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DirectUploadStatusItemDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DirectUploadStatusItemDto(...).copyWith(id: 12, name: "My name")
  /// ````
  DirectUploadStatusItemDto call({
    Object? objectKey = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? errorCode = const $CopyWithPlaceholder(),
    Object? errorMessage = const $CopyWithPlaceholder(),
  }) {
    return DirectUploadStatusItemDto(
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

extension $DirectUploadStatusItemDtoCopyWith on DirectUploadStatusItemDto {
  /// Returns a callable class that can be used as follows: `instanceOfDirectUploadStatusItemDto.copyWith(...)` or like so:`instanceOfDirectUploadStatusItemDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DirectUploadStatusItemDtoCWProxy get copyWith =>
      _$DirectUploadStatusItemDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectUploadStatusItemDto _$DirectUploadStatusItemDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DirectUploadStatusItemDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['objectKey', 'status']);
  final val = DirectUploadStatusItemDto(
    objectKey: $checkedConvert('objectKey', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    errorCode: $checkedConvert('errorCode', (v) => v as String?),
    errorMessage: $checkedConvert('errorMessage', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$DirectUploadStatusItemDtoToJson(
  DirectUploadStatusItemDto instance,
) => <String, dynamic>{
  'objectKey': instance.objectKey,
  'status': instance.status,
if (instance.errorCode != null) 'errorCode': instance.errorCode,
if (instance.errorMessage != null) 'errorMessage': instance.errorMessage,
};
