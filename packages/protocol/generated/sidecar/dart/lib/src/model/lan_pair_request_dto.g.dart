// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_pair_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanPairRequestDtoCWProxy {
  LanPairRequestDto deviceId(String deviceId);

  LanPairRequestDto childId(String childId);

  LanPairRequestDto pairingCode(String? pairingCode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanPairRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanPairRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanPairRequestDto call({
    String deviceId,
    String childId,
    String? pairingCode,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanPairRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanPairRequestDto.copyWith.fieldName(...)`
class _$LanPairRequestDtoCWProxyImpl implements _$LanPairRequestDtoCWProxy {
  const _$LanPairRequestDtoCWProxyImpl(this._value);

  final LanPairRequestDto _value;

  @override
  LanPairRequestDto deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  LanPairRequestDto childId(String childId) => this(childId: childId);

  @override
  LanPairRequestDto pairingCode(String? pairingCode) =>
      this(pairingCode: pairingCode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanPairRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanPairRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanPairRequestDto call({
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? childId = const $CopyWithPlaceholder(),
    Object? pairingCode = const $CopyWithPlaceholder(),
  }) {
    return LanPairRequestDto(
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String,
      childId: childId == const $CopyWithPlaceholder()
          ? _value.childId
          // ignore: cast_nullable_to_non_nullable
          : childId as String,
      pairingCode: pairingCode == const $CopyWithPlaceholder()
          ? _value.pairingCode
          // ignore: cast_nullable_to_non_nullable
          : pairingCode as String?,
    );
  }
}

extension $LanPairRequestDtoCopyWith on LanPairRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanPairRequestDto.copyWith(...)` or like so:`instanceOfLanPairRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanPairRequestDtoCWProxy get copyWith =>
      _$LanPairRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanPairRequestDto _$LanPairRequestDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LanPairRequestDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['deviceId', 'childId']);
      final val = LanPairRequestDto(
        deviceId: $checkedConvert('deviceId', (v) => v as String),
        childId: $checkedConvert('childId', (v) => v as String),
        pairingCode: $checkedConvert('pairingCode', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LanPairRequestDtoToJson(LanPairRequestDto instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'childId': instance.childId,
if (instance.pairingCode != null) 'pairingCode': instance.pairingCode,
    };
