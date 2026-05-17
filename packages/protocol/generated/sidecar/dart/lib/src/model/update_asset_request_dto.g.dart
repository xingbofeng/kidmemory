// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_asset_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateAssetRequestDtoCWProxy {
  UpdateAssetRequestDto title(String title);

  UpdateAssetRequestDto description(String description);

  UpdateAssetRequestDto tags(List<String> tags);

  UpdateAssetRequestDto capturedAt(String? capturedAt);

  UpdateAssetRequestDto type(String type);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateAssetRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateAssetRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateAssetRequestDto call({
    String title,
    String description,
    List<String> tags,
    String? capturedAt,
    String type,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateAssetRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateAssetRequestDto.copyWith.fieldName(...)`
class _$UpdateAssetRequestDtoCWProxyImpl
    implements _$UpdateAssetRequestDtoCWProxy {
  const _$UpdateAssetRequestDtoCWProxyImpl(this._value);

  final UpdateAssetRequestDto _value;

  @override
  UpdateAssetRequestDto title(String title) => this(title: title);

  @override
  UpdateAssetRequestDto description(String description) =>
      this(description: description);

  @override
  UpdateAssetRequestDto tags(List<String> tags) => this(tags: tags);

  @override
  UpdateAssetRequestDto capturedAt(String? capturedAt) =>
      this(capturedAt: capturedAt);

  @override
  UpdateAssetRequestDto type(String type) => this(type: type);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateAssetRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateAssetRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateAssetRequestDto call({
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? capturedAt = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
  }) {
    return UpdateAssetRequestDto(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      tags: tags == const $CopyWithPlaceholder()
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as List<String>,
      capturedAt: capturedAt == const $CopyWithPlaceholder()
          ? _value.capturedAt
          // ignore: cast_nullable_to_non_nullable
          : capturedAt as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
    );
  }
}

extension $UpdateAssetRequestDtoCopyWith on UpdateAssetRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateAssetRequestDto.copyWith(...)` or like so:`instanceOfUpdateAssetRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateAssetRequestDtoCWProxy get copyWith =>
      _$UpdateAssetRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAssetRequestDto _$UpdateAssetRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateAssetRequestDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['title', 'description', 'tags', 'type'],
  );
  final val = UpdateAssetRequestDto(
    title: $checkedConvert('title', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    tags: $checkedConvert(
      'tags',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    capturedAt: $checkedConvert('capturedAt', (v) => v as String?),
    type: $checkedConvert('type', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$UpdateAssetRequestDtoToJson(
  UpdateAssetRequestDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'tags': instance.tags,
if (instance.capturedAt != null) 'capturedAt': instance.capturedAt,
  'type': instance.type,
};
