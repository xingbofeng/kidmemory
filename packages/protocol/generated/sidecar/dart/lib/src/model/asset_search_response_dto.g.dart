// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_search_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssetSearchResponseDtoCWProxy {
  AssetSearchResponseDto ok(bool? ok);

  AssetSearchResponseDto success(bool? success);

  AssetSearchResponseDto message(String? message);

  AssetSearchResponseDto code(String? code);

  AssetSearchResponseDto total(int? total);

  AssetSearchResponseDto items(List<AssetSearchItemResponseDto>? items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetSearchResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetSearchResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetSearchResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
    int? total,
    List<AssetSearchItemResponseDto>? items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssetSearchResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssetSearchResponseDto.copyWith.fieldName(...)`
class _$AssetSearchResponseDtoCWProxyImpl
    implements _$AssetSearchResponseDtoCWProxy {
  const _$AssetSearchResponseDtoCWProxyImpl(this._value);

  final AssetSearchResponseDto _value;

  @override
  AssetSearchResponseDto ok(bool? ok) => this(ok: ok);

  @override
  AssetSearchResponseDto success(bool? success) => this(success: success);

  @override
  AssetSearchResponseDto message(String? message) => this(message: message);

  @override
  AssetSearchResponseDto code(String? code) => this(code: code);

  @override
  AssetSearchResponseDto total(int? total) => this(total: total);

  @override
  AssetSearchResponseDto items(List<AssetSearchItemResponseDto>? items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssetSearchResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssetSearchResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AssetSearchResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return AssetSearchResponseDto(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool?,
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int?,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<AssetSearchItemResponseDto>?,
    );
  }
}

extension $AssetSearchResponseDtoCopyWith on AssetSearchResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfAssetSearchResponseDto.copyWith(...)` or like so:`instanceOfAssetSearchResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssetSearchResponseDtoCWProxy get copyWith =>
      _$AssetSearchResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetSearchResponseDto _$AssetSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssetSearchResponseDto', json, ($checkedConvert) {
  final val = AssetSearchResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String?),
    total: $checkedConvert('total', (v) => (v as num?)?.toInt()),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) =>
                AssetSearchItemResponseDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssetSearchResponseDtoToJson(
  AssetSearchResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
if (instance.total != null) 'total': instance.total,
if (instance.items?.map((e) => e.toJson()).toList() != null) 'items': instance.items?.map((e) => e.toJson()).toList(),
};
