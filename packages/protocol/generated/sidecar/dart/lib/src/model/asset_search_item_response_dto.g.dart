// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_search_item_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssetSearchItemResponseDtoCWProxy {
  AssetSearchItemResponseDto asset(AssetRecordResponseDto? asset);

  AssetSearchItemResponseDto reasons(List<String>? reasons);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetSearchItemResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetSearchItemResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetSearchItemResponseDto call({
    AssetRecordResponseDto? asset,
    List<String>? reasons,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssetSearchItemResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssetSearchItemResponseDto.copyWith.fieldName(...)`
class _$AssetSearchItemResponseDtoCWProxyImpl
    implements _$AssetSearchItemResponseDtoCWProxy {
  const _$AssetSearchItemResponseDtoCWProxyImpl(this._value);

  final AssetSearchItemResponseDto _value;

  @override
  AssetSearchItemResponseDto asset(AssetRecordResponseDto? asset) =>
      this(asset: asset);

  @override
  AssetSearchItemResponseDto reasons(List<String>? reasons) =>
      this(reasons: reasons);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetSearchItemResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetSearchItemResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetSearchItemResponseDto call({
    Object? asset = const $CopyWithPlaceholder(),
    Object? reasons = const $CopyWithPlaceholder(),
  }) {
    return AssetSearchItemResponseDto(
      asset: asset == const $CopyWithPlaceholder()
          ? _value.asset
          // ignore: cast_nullable_to_non_nullable
          : asset as AssetRecordResponseDto?,
      reasons: reasons == const $CopyWithPlaceholder()
          ? _value.reasons
          // ignore: cast_nullable_to_non_nullable
          : reasons as List<String>?,
    );
  }
}

extension $AssetSearchItemResponseDtoCopyWith on AssetSearchItemResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfAssetSearchItemResponseDto.copyWith(...)` or like so:`instanceOfAssetSearchItemResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssetSearchItemResponseDtoCWProxy get copyWith =>
      _$AssetSearchItemResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetSearchItemResponseDto _$AssetSearchItemResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssetSearchItemResponseDto', json, ($checkedConvert) {
  final val = AssetSearchItemResponseDto(
    asset: $checkedConvert(
      'asset',
      (v) => v == null
          ? null
          : AssetRecordResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    reasons: $checkedConvert(
      'reasons',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssetSearchItemResponseDtoToJson(
  AssetSearchItemResponseDto instance,
) => <String, dynamic>{
if (instance.asset?.toJson() != null) 'asset': instance.asset?.toJson(),
if (instance.reasons != null) 'reasons': instance.reasons,
};
