// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_pair_endpoints_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanPairEndpointsDtoCWProxy {
  LanPairEndpointsDto upload(String upload);

  LanPairEndpointsDto status(String status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanPairEndpointsDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanPairEndpointsDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanPairEndpointsDto call({String upload, String status});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanPairEndpointsDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanPairEndpointsDto.copyWith.fieldName(...)`
class _$LanPairEndpointsDtoCWProxyImpl implements _$LanPairEndpointsDtoCWProxy {
  const _$LanPairEndpointsDtoCWProxyImpl(this._value);

  final LanPairEndpointsDto _value;

  @override
  LanPairEndpointsDto upload(String upload) => this(upload: upload);

  @override
  LanPairEndpointsDto status(String status) => this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanPairEndpointsDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanPairEndpointsDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanPairEndpointsDto call({
    Object? upload = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return LanPairEndpointsDto(
      upload: upload == const $CopyWithPlaceholder()
          ? _value.upload
          // ignore: cast_nullable_to_non_nullable
          : upload as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
    );
  }
}

extension $LanPairEndpointsDtoCopyWith on LanPairEndpointsDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanPairEndpointsDto.copyWith(...)` or like so:`instanceOfLanPairEndpointsDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanPairEndpointsDtoCWProxy get copyWith =>
      _$LanPairEndpointsDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanPairEndpointsDto _$LanPairEndpointsDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LanPairEndpointsDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['upload', 'status']);
      final val = LanPairEndpointsDto(
        upload: $checkedConvert('upload', (v) => v as String),
        status: $checkedConvert('status', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LanPairEndpointsDtoToJson(
  LanPairEndpointsDto instance,
) => <String, dynamic>{'upload': instance.upload, 'status': instance.status};
