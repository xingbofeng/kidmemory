// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_record_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssetRecordResponseDtoCWProxy {
  AssetRecordResponseDto id(String? id);

  AssetRecordResponseDto title(String? title);

  AssetRecordResponseDto type(String? type);

  AssetRecordResponseDto description(String? description);

  AssetRecordResponseDto tags(List<String>? tags);

  AssetRecordResponseDto capturedAt(String? capturedAt);

  AssetRecordResponseDto imagePath(String? imagePath);

  AssetRecordResponseDto thumbnailPath(String? thumbnailPath);

  AssetRecordResponseDto previewUrl(String? previewUrl);

  AssetRecordResponseDto originalFilename(String? originalFilename);

  AssetRecordResponseDto storageStatus(String? storageStatus);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetRecordResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetRecordResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetRecordResponseDto call({
    String? id,
    String? title,
    String? type,
    String? description,
    List<String>? tags,
    String? capturedAt,
    String? imagePath,
    String? thumbnailPath,
    String? previewUrl,
    String? originalFilename,
    String? storageStatus,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssetRecordResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssetRecordResponseDto.copyWith.fieldName(...)`
class _$AssetRecordResponseDtoCWProxyImpl
    implements _$AssetRecordResponseDtoCWProxy {
  const _$AssetRecordResponseDtoCWProxyImpl(this._value);

  final AssetRecordResponseDto _value;

  @override
  AssetRecordResponseDto id(String? id) => this(id: id);

  @override
  AssetRecordResponseDto title(String? title) => this(title: title);

  @override
  AssetRecordResponseDto type(String? type) => this(type: type);

  @override
  AssetRecordResponseDto description(String? description) =>
      this(description: description);

  @override
  AssetRecordResponseDto tags(List<String>? tags) => this(tags: tags);

  @override
  AssetRecordResponseDto capturedAt(String? capturedAt) =>
      this(capturedAt: capturedAt);

  @override
  AssetRecordResponseDto imagePath(String? imagePath) =>
      this(imagePath: imagePath);

  @override
  AssetRecordResponseDto thumbnailPath(String? thumbnailPath) =>
      this(thumbnailPath: thumbnailPath);

  @override
  AssetRecordResponseDto previewUrl(String? previewUrl) =>
      this(previewUrl: previewUrl);

  @override
  AssetRecordResponseDto originalFilename(String? originalFilename) =>
      this(originalFilename: originalFilename);

  @override
  AssetRecordResponseDto storageStatus(String? storageStatus) =>
      this(storageStatus: storageStatus);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetRecordResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetRecordResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetRecordResponseDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? capturedAt = const $CopyWithPlaceholder(),
    Object? imagePath = const $CopyWithPlaceholder(),
    Object? thumbnailPath = const $CopyWithPlaceholder(),
    Object? previewUrl = const $CopyWithPlaceholder(),
    Object? originalFilename = const $CopyWithPlaceholder(),
    Object? storageStatus = const $CopyWithPlaceholder(),
  }) {
    return AssetRecordResponseDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      tags: tags == const $CopyWithPlaceholder()
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as List<String>?,
      capturedAt: capturedAt == const $CopyWithPlaceholder()
          ? _value.capturedAt
          // ignore: cast_nullable_to_non_nullable
          : capturedAt as String?,
      imagePath: imagePath == const $CopyWithPlaceholder()
          ? _value.imagePath
          // ignore: cast_nullable_to_non_nullable
          : imagePath as String?,
      thumbnailPath: thumbnailPath == const $CopyWithPlaceholder()
          ? _value.thumbnailPath
          // ignore: cast_nullable_to_non_nullable
          : thumbnailPath as String?,
      previewUrl: previewUrl == const $CopyWithPlaceholder()
          ? _value.previewUrl
          // ignore: cast_nullable_to_non_nullable
          : previewUrl as String?,
      originalFilename: originalFilename == const $CopyWithPlaceholder()
          ? _value.originalFilename
          // ignore: cast_nullable_to_non_nullable
          : originalFilename as String?,
      storageStatus: storageStatus == const $CopyWithPlaceholder()
          ? _value.storageStatus
          // ignore: cast_nullable_to_non_nullable
          : storageStatus as String?,
    );
  }
}

extension $AssetRecordResponseDtoCopyWith on AssetRecordResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfAssetRecordResponseDto.copyWith(...)` or like so:`instanceOfAssetRecordResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssetRecordResponseDtoCWProxy get copyWith =>
      _$AssetRecordResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetRecordResponseDto _$AssetRecordResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssetRecordResponseDto', json, ($checkedConvert) {
  final val = AssetRecordResponseDto(
    id: $checkedConvert('id', (v) => v as String?),
    title: $checkedConvert('title', (v) => v as String?),
    type: $checkedConvert('type', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    tags: $checkedConvert(
      'tags',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    capturedAt: $checkedConvert('capturedAt', (v) => v as String?),
    imagePath: $checkedConvert('imagePath', (v) => v as String?),
    thumbnailPath: $checkedConvert('thumbnailPath', (v) => v as String?),
    previewUrl: $checkedConvert('previewUrl', (v) => v as String?),
    originalFilename: $checkedConvert('originalFilename', (v) => v as String?),
    storageStatus: $checkedConvert('storageStatus', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AssetRecordResponseDtoToJson(
  AssetRecordResponseDto instance,
) => <String, dynamic>{
if (instance.id != null) 'id': instance.id,
if (instance.title != null) 'title': instance.title,
if (instance.type != null) 'type': instance.type,
if (instance.description != null) 'description': instance.description,
if (instance.tags != null) 'tags': instance.tags,
if (instance.capturedAt != null) 'capturedAt': instance.capturedAt,
if (instance.imagePath != null) 'imagePath': instance.imagePath,
if (instance.thumbnailPath != null) 'thumbnailPath': instance.thumbnailPath,
if (instance.previewUrl != null) 'previewUrl': instance.previewUrl,
if (instance.originalFilename != null) 'originalFilename': instance.originalFilename,
if (instance.storageStatus != null) 'storageStatus': instance.storageStatus,
};
