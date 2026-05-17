// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_direct_upload_objects_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ListDirectUploadObjectsResponseDtoCWProxy {
  ListDirectUploadObjectsResponseDto sessionId(String sessionId);

  ListDirectUploadObjectsResponseDto bucket(String bucket);

  ListDirectUploadObjectsResponseDto objects(
    List<DirectUploadRemoteObjectDto> objects,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ListDirectUploadObjectsResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ListDirectUploadObjectsResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ListDirectUploadObjectsResponseDto call({
    String sessionId,
    String bucket,
    List<DirectUploadRemoteObjectDto> objects,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfListDirectUploadObjectsResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfListDirectUploadObjectsResponseDto.copyWith.fieldName(...)`
class _$ListDirectUploadObjectsResponseDtoCWProxyImpl
    implements _$ListDirectUploadObjectsResponseDtoCWProxy {
  const _$ListDirectUploadObjectsResponseDtoCWProxyImpl(this._value);

  final ListDirectUploadObjectsResponseDto _value;

  @override
  ListDirectUploadObjectsResponseDto sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  ListDirectUploadObjectsResponseDto bucket(String bucket) =>
      this(bucket: bucket);

  @override
  ListDirectUploadObjectsResponseDto objects(
    List<DirectUploadRemoteObjectDto> objects,
  ) => this(objects: objects);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ListDirectUploadObjectsResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ListDirectUploadObjectsResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ListDirectUploadObjectsResponseDto call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? bucket = const $CopyWithPlaceholder(),
    Object? objects = const $CopyWithPlaceholder(),
  }) {
    return ListDirectUploadObjectsResponseDto(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      bucket: bucket == const $CopyWithPlaceholder()
          ? _value.bucket
          // ignore: cast_nullable_to_non_nullable
          : bucket as String,
      objects: objects == const $CopyWithPlaceholder()
          ? _value.objects
          // ignore: cast_nullable_to_non_nullable
          : objects as List<DirectUploadRemoteObjectDto>,
    );
  }
}

extension $ListDirectUploadObjectsResponseDtoCopyWith
    on ListDirectUploadObjectsResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfListDirectUploadObjectsResponseDto.copyWith(...)` or like so:`instanceOfListDirectUploadObjectsResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ListDirectUploadObjectsResponseDtoCWProxy get copyWith =>
      _$ListDirectUploadObjectsResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListDirectUploadObjectsResponseDto _$ListDirectUploadObjectsResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ListDirectUploadObjectsResponseDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['sessionId', 'bucket', 'objects']);
  final val = ListDirectUploadObjectsResponseDto(
    sessionId: $checkedConvert('sessionId', (v) => v as String),
    bucket: $checkedConvert('bucket', (v) => v as String),
    objects: $checkedConvert(
      'objects',
      (v) => (v as List<dynamic>)
          .map(
            (e) =>
                DirectUploadRemoteObjectDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ListDirectUploadObjectsResponseDtoToJson(
  ListDirectUploadObjectsResponseDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'bucket': instance.bucket,
  'objects': instance.objects.map((e) => e.toJson()).toList(),
};
