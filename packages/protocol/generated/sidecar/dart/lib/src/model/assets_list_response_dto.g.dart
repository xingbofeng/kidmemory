// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets_list_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssetsListResponseDtoCWProxy {
  AssetsListResponseDto assets(List<AssetRecordResponseDto>? assets);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetsListResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetsListResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetsListResponseDto call({List<AssetRecordResponseDto>? assets});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssetsListResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssetsListResponseDto.copyWith.fieldName(...)`
class _$AssetsListResponseDtoCWProxyImpl
    implements _$AssetsListResponseDtoCWProxy {
  const _$AssetsListResponseDtoCWProxyImpl(this._value);

  final AssetsListResponseDto _value;

  @override
  AssetsListResponseDto assets(List<AssetRecordResponseDto>? assets) =>
      this(assets: assets);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetsListResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetsListResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetsListResponseDto call({Object? assets = const $CopyWithPlaceholder()}) {
    return AssetsListResponseDto(
      assets: assets == const $CopyWithPlaceholder()
          ? _value.assets
          // ignore: cast_nullable_to_non_nullable
          : assets as List<AssetRecordResponseDto>?,
    );
  }
}

extension $AssetsListResponseDtoCopyWith on AssetsListResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfAssetsListResponseDto.copyWith(...)` or like so:`instanceOfAssetsListResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssetsListResponseDtoCWProxy get copyWith =>
      _$AssetsListResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetsListResponseDto _$AssetsListResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssetsListResponseDto', json, ($checkedConvert) {
  final val = AssetsListResponseDto(
    assets: $checkedConvert(
      'assets',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => AssetRecordResponseDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssetsListResponseDtoToJson(
  AssetsListResponseDto instance,
) => <String, dynamic>{
if (instance.assets?.map((e) => e.toJson()).toList() != null) 'assets': instance.assets?.map((e) => e.toJson()).toList(),
};
