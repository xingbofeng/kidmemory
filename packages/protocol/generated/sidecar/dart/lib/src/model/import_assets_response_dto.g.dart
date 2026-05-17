// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_assets_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportAssetsResponseDtoCWProxy {
  ImportAssetsResponseDto imported(List<Map<String, Object>>? imported);

  ImportAssetsResponseDto duplicates(List<Map<String, Object>>? duplicates);

  ImportAssetsResponseDto failed(List<ImportAssetsFailedItemDto>? failed);

  ImportAssetsResponseDto skipped(List<Map<String, Object>>? skipped);

  ImportAssetsResponseDto message(String? message);

  ImportAssetsResponseDto title(String? title);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportAssetsResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportAssetsResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportAssetsResponseDto call({
    List<Map<String, Object>>? imported,
    List<Map<String, Object>>? duplicates,
    List<ImportAssetsFailedItemDto>? failed,
    List<Map<String, Object>>? skipped,
    String? message,
    String? title,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportAssetsResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportAssetsResponseDto.copyWith.fieldName(...)`
class _$ImportAssetsResponseDtoCWProxyImpl
    implements _$ImportAssetsResponseDtoCWProxy {
  const _$ImportAssetsResponseDtoCWProxyImpl(this._value);

  final ImportAssetsResponseDto _value;

  @override
  ImportAssetsResponseDto imported(List<Map<String, Object>>? imported) =>
      this(imported: imported);

  @override
  ImportAssetsResponseDto duplicates(List<Map<String, Object>>? duplicates) =>
      this(duplicates: duplicates);

  @override
  ImportAssetsResponseDto failed(List<ImportAssetsFailedItemDto>? failed) =>
      this(failed: failed);

  @override
  ImportAssetsResponseDto skipped(List<Map<String, Object>>? skipped) =>
      this(skipped: skipped);

  @override
  ImportAssetsResponseDto message(String? message) => this(message: message);

  @override
  ImportAssetsResponseDto title(String? title) => this(title: title);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportAssetsResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportAssetsResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportAssetsResponseDto call({
    Object? imported = const $CopyWithPlaceholder(),
    Object? duplicates = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
    Object? skipped = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
  }) {
    return ImportAssetsResponseDto(
      imported: imported == const $CopyWithPlaceholder()
          ? _value.imported
          // ignore: cast_nullable_to_non_nullable
          : imported as List<Map<String, Object>>?,
      duplicates: duplicates == const $CopyWithPlaceholder()
          ? _value.duplicates
          // ignore: cast_nullable_to_non_nullable
          : duplicates as List<Map<String, Object>>?,
      failed: failed == const $CopyWithPlaceholder()
          ? _value.failed
          // ignore: cast_nullable_to_non_nullable
          : failed as List<ImportAssetsFailedItemDto>?,
      skipped: skipped == const $CopyWithPlaceholder()
          ? _value.skipped
          // ignore: cast_nullable_to_non_nullable
          : skipped as List<Map<String, Object>>?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
    );
  }
}

extension $ImportAssetsResponseDtoCopyWith on ImportAssetsResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfImportAssetsResponseDto.copyWith(...)` or like so:`instanceOfImportAssetsResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportAssetsResponseDtoCWProxy get copyWith =>
      _$ImportAssetsResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportAssetsResponseDto _$ImportAssetsResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportAssetsResponseDto', json, ($checkedConvert) {
  final val = ImportAssetsResponseDto(
    imported: $checkedConvert(
      'imported',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, e as Object),
            ),
          )
          .toList(),
    ),
    duplicates: $checkedConvert(
      'duplicates',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, e as Object),
            ),
          )
          .toList(),
    ),
    failed: $checkedConvert(
      'failed',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) =>
                ImportAssetsFailedItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    skipped: $checkedConvert(
      'skipped',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, e as Object),
            ),
          )
          .toList(),
    ),
    message: $checkedConvert('message', (v) => v as String?),
    title: $checkedConvert('title', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ImportAssetsResponseDtoToJson(
  ImportAssetsResponseDto instance,
) => <String, dynamic>{
if (instance.imported != null) 'imported': instance.imported,
if (instance.duplicates != null) 'duplicates': instance.duplicates,
if (instance.failed?.map((e) => e.toJson()).toList() != null) 'failed': instance.failed?.map((e) => e.toJson()).toList(),
if (instance.skipped != null) 'skipped': instance.skipped,
if (instance.message != null) 'message': instance.message,
if (instance.title != null) 'title': instance.title,
};
