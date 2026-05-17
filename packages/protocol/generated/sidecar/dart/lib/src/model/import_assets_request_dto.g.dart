// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_assets_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportAssetsRequestDtoCWProxy {
  ImportAssetsRequestDto childId(String childId);

  ImportAssetsRequestDto paths(List<String> paths);

  ImportAssetsRequestDto recursive(bool? recursive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportAssetsRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportAssetsRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportAssetsRequestDto call({
    String childId,
    List<String> paths,
    bool? recursive,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportAssetsRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportAssetsRequestDto.copyWith.fieldName(...)`
class _$ImportAssetsRequestDtoCWProxyImpl
    implements _$ImportAssetsRequestDtoCWProxy {
  const _$ImportAssetsRequestDtoCWProxyImpl(this._value);

  final ImportAssetsRequestDto _value;

  @override
  ImportAssetsRequestDto childId(String childId) => this(childId: childId);

  @override
  ImportAssetsRequestDto paths(List<String> paths) => this(paths: paths);

  @override
  ImportAssetsRequestDto recursive(bool? recursive) =>
      this(recursive: recursive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportAssetsRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportAssetsRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportAssetsRequestDto call({
    Object? childId = const $CopyWithPlaceholder(),
    Object? paths = const $CopyWithPlaceholder(),
    Object? recursive = const $CopyWithPlaceholder(),
  }) {
    return ImportAssetsRequestDto(
      childId: childId == const $CopyWithPlaceholder()
          ? _value.childId
          // ignore: cast_nullable_to_non_nullable
          : childId as String,
      paths: paths == const $CopyWithPlaceholder()
          ? _value.paths
          // ignore: cast_nullable_to_non_nullable
          : paths as List<String>,
      recursive: recursive == const $CopyWithPlaceholder()
          ? _value.recursive
          // ignore: cast_nullable_to_non_nullable
          : recursive as bool?,
    );
  }
}

extension $ImportAssetsRequestDtoCopyWith on ImportAssetsRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfImportAssetsRequestDto.copyWith(...)` or like so:`instanceOfImportAssetsRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportAssetsRequestDtoCWProxy get copyWith =>
      _$ImportAssetsRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportAssetsRequestDto _$ImportAssetsRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportAssetsRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['childId', 'paths']);
  final val = ImportAssetsRequestDto(
    childId: $checkedConvert('childId', (v) => v as String),
    paths: $checkedConvert(
      'paths',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    recursive: $checkedConvert('recursive', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$ImportAssetsRequestDtoToJson(
  ImportAssetsRequestDto instance,
) => <String, dynamic>{
  'childId': instance.childId,
  'paths': instance.paths,
if (instance.recursive != null) 'recursive': instance.recursive,
};
