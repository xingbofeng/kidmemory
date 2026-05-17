// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_upload_items_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateUploadItemsResponseDtoCWProxy {
  CreateUploadItemsResponseDto items(List<UploadItemResponseDto> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateUploadItemsResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateUploadItemsResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateUploadItemsResponseDto call({List<UploadItemResponseDto> items});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateUploadItemsResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateUploadItemsResponseDto.copyWith.fieldName(...)`
class _$CreateUploadItemsResponseDtoCWProxyImpl
    implements _$CreateUploadItemsResponseDtoCWProxy {
  const _$CreateUploadItemsResponseDtoCWProxyImpl(this._value);

  final CreateUploadItemsResponseDto _value;

  @override
  CreateUploadItemsResponseDto items(List<UploadItemResponseDto> items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateUploadItemsResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateUploadItemsResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateUploadItemsResponseDto call({
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return CreateUploadItemsResponseDto(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<UploadItemResponseDto>,
    );
  }
}

extension $CreateUploadItemsResponseDtoCopyWith
    on CreateUploadItemsResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateUploadItemsResponseDto.copyWith(...)` or like so:`instanceOfCreateUploadItemsResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateUploadItemsResponseDtoCWProxy get copyWith =>
      _$CreateUploadItemsResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUploadItemsResponseDto _$CreateUploadItemsResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateUploadItemsResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items']);
  final val = CreateUploadItemsResponseDto(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => UploadItemResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$CreateUploadItemsResponseDtoToJson(
  CreateUploadItemsResponseDto instance,
) => <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
