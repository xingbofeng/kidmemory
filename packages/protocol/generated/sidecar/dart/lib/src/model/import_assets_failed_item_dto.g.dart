// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_assets_failed_item_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportAssetsFailedItemDtoCWProxy {
  ImportAssetsFailedItemDto reason(String? reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportAssetsFailedItemDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportAssetsFailedItemDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportAssetsFailedItemDto call({String? reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportAssetsFailedItemDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportAssetsFailedItemDto.copyWith.fieldName(...)`
class _$ImportAssetsFailedItemDtoCWProxyImpl
    implements _$ImportAssetsFailedItemDtoCWProxy {
  const _$ImportAssetsFailedItemDtoCWProxyImpl(this._value);

  final ImportAssetsFailedItemDto _value;

  @override
  ImportAssetsFailedItemDto reason(String? reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportAssetsFailedItemDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportAssetsFailedItemDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportAssetsFailedItemDto call({
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return ImportAssetsFailedItemDto(
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $ImportAssetsFailedItemDtoCopyWith on ImportAssetsFailedItemDto {
  /// Returns a callable class that can be used as follows: `instanceOfImportAssetsFailedItemDto.copyWith(...)` or like so:`instanceOfImportAssetsFailedItemDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportAssetsFailedItemDtoCWProxy get copyWith =>
      _$ImportAssetsFailedItemDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportAssetsFailedItemDto _$ImportAssetsFailedItemDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportAssetsFailedItemDto', json, ($checkedConvert) {
  final val = ImportAssetsFailedItemDto(
    reason: $checkedConvert('reason', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ImportAssetsFailedItemDtoToJson(
  ImportAssetsFailedItemDto instance,
) => <String, dynamic>{'reason': instance.reason};
