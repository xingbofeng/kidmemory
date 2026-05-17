// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_upload_remote_object_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DirectUploadRemoteObjectDtoCWProxy {
  DirectUploadRemoteObjectDto objectKey(String objectKey);

  DirectUploadRemoteObjectDto size(int size);

  DirectUploadRemoteObjectDto contentType(String contentType);

  DirectUploadRemoteObjectDto lastModified(String lastModified);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DirectUploadRemoteObjectDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DirectUploadRemoteObjectDto(...).copyWith(id: 12, name: "My name")
  /// ````
  DirectUploadRemoteObjectDto call({
    String objectKey,
    int size,
    String contentType,
    String lastModified,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDirectUploadRemoteObjectDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDirectUploadRemoteObjectDto.copyWith.fieldName(...)`
class _$DirectUploadRemoteObjectDtoCWProxyImpl
    implements _$DirectUploadRemoteObjectDtoCWProxy {
  const _$DirectUploadRemoteObjectDtoCWProxyImpl(this._value);

  final DirectUploadRemoteObjectDto _value;

  @override
  DirectUploadRemoteObjectDto objectKey(String objectKey) =>
      this(objectKey: objectKey);

  @override
  DirectUploadRemoteObjectDto size(int size) => this(size: size);

  @override
  DirectUploadRemoteObjectDto contentType(String contentType) =>
      this(contentType: contentType);

  @override
  DirectUploadRemoteObjectDto lastModified(String lastModified) =>
      this(lastModified: lastModified);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DirectUploadRemoteObjectDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DirectUploadRemoteObjectDto(...).copyWith(id: 12, name: "My name")
  /// ````
  DirectUploadRemoteObjectDto call({
    Object? objectKey = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? lastModified = const $CopyWithPlaceholder(),
  }) {
    return DirectUploadRemoteObjectDto(
      objectKey: objectKey == const $CopyWithPlaceholder()
          ? _value.objectKey
          // ignore: cast_nullable_to_non_nullable
          : objectKey as String,
      size: size == const $CopyWithPlaceholder()
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int,
      contentType: contentType == const $CopyWithPlaceholder()
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String,
      lastModified: lastModified == const $CopyWithPlaceholder()
          ? _value.lastModified
          // ignore: cast_nullable_to_non_nullable
          : lastModified as String,
    );
  }
}

extension $DirectUploadRemoteObjectDtoCopyWith on DirectUploadRemoteObjectDto {
  /// Returns a callable class that can be used as follows: `instanceOfDirectUploadRemoteObjectDto.copyWith(...)` or like so:`instanceOfDirectUploadRemoteObjectDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DirectUploadRemoteObjectDtoCWProxy get copyWith =>
      _$DirectUploadRemoteObjectDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectUploadRemoteObjectDto _$DirectUploadRemoteObjectDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DirectUploadRemoteObjectDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['objectKey', 'size', 'contentType', 'lastModified'],
  );
  final val = DirectUploadRemoteObjectDto(
    objectKey: $checkedConvert('objectKey', (v) => v as String),
    size: $checkedConvert('size', (v) => (v as num).toInt()),
    contentType: $checkedConvert('contentType', (v) => v as String),
    lastModified: $checkedConvert('lastModified', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$DirectUploadRemoteObjectDtoToJson(
  DirectUploadRemoteObjectDto instance,
) => <String, dynamic>{
  'objectKey': instance.objectKey,
  'size': instance.size,
  'contentType': instance.contentType,
  'lastModified': instance.lastModified,
};
