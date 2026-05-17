// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_search_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssetSearchRequestDtoCWProxy {
  AssetSearchRequestDto childId(String childId);

  AssetSearchRequestDto query(String query);

  AssetSearchRequestDto page(int page);

  AssetSearchRequestDto pageSize(int pageSize);

  AssetSearchRequestDto filters(Map<String, Object>? filters);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetSearchRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetSearchRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetSearchRequestDto call({
    String childId,
    String query,
    int page,
    int pageSize,
    Map<String, Object>? filters,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssetSearchRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssetSearchRequestDto.copyWith.fieldName(...)`
class _$AssetSearchRequestDtoCWProxyImpl
    implements _$AssetSearchRequestDtoCWProxy {
  const _$AssetSearchRequestDtoCWProxyImpl(this._value);

  final AssetSearchRequestDto _value;

  @override
  AssetSearchRequestDto childId(String childId) => this(childId: childId);

  @override
  AssetSearchRequestDto query(String query) => this(query: query);

  @override
  AssetSearchRequestDto page(int page) => this(page: page);

  @override
  AssetSearchRequestDto pageSize(int pageSize) => this(pageSize: pageSize);

  @override
  AssetSearchRequestDto filters(Map<String, Object>? filters) =>
      this(filters: filters);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetSearchRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetSearchRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetSearchRequestDto call({
    Object? childId = const $CopyWithPlaceholder(),
    Object? query = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? pageSize = const $CopyWithPlaceholder(),
    Object? filters = const $CopyWithPlaceholder(),
  }) {
    return AssetSearchRequestDto(
      childId: childId == const $CopyWithPlaceholder()
          ? _value.childId
          // ignore: cast_nullable_to_non_nullable
          : childId as String,
      query: query == const $CopyWithPlaceholder()
          ? _value.query
          // ignore: cast_nullable_to_non_nullable
          : query as String,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as int,
      pageSize: pageSize == const $CopyWithPlaceholder()
          ? _value.pageSize
          // ignore: cast_nullable_to_non_nullable
          : pageSize as int,
      filters: filters == const $CopyWithPlaceholder()
          ? _value.filters
          // ignore: cast_nullable_to_non_nullable
          : filters as Map<String, Object>?,
    );
  }
}

extension $AssetSearchRequestDtoCopyWith on AssetSearchRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfAssetSearchRequestDto.copyWith(...)` or like so:`instanceOfAssetSearchRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssetSearchRequestDtoCWProxy get copyWith =>
      _$AssetSearchRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetSearchRequestDto _$AssetSearchRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssetSearchRequestDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['childId', 'query', 'page', 'pageSize'],
  );
  final val = AssetSearchRequestDto(
    childId: $checkedConvert('childId', (v) => v as String),
    query: $checkedConvert('query', (v) => v as String),
    page: $checkedConvert('page', (v) => (v as num).toInt()),
    pageSize: $checkedConvert('pageSize', (v) => (v as num).toInt()),
    filters: $checkedConvert(
      'filters',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssetSearchRequestDtoToJson(
  AssetSearchRequestDto instance,
) => <String, dynamic>{
  'childId': instance.childId,
  'query': instance.query,
  'page': instance.page,
  'pageSize': instance.pageSize,
if (instance.filters != null) 'filters': instance.filters,
};
