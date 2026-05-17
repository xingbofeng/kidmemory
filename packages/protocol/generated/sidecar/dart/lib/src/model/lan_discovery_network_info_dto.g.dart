// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_discovery_network_info_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanDiscoveryNetworkInfoDtoCWProxy {
  LanDiscoveryNetworkInfoDto ip(String ip);

  LanDiscoveryNetworkInfoDto port(int port);

  LanDiscoveryNetworkInfoDto protocol(String protocol);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanDiscoveryNetworkInfoDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanDiscoveryNetworkInfoDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanDiscoveryNetworkInfoDto call({String ip, int port, String protocol});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanDiscoveryNetworkInfoDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanDiscoveryNetworkInfoDto.copyWith.fieldName(...)`
class _$LanDiscoveryNetworkInfoDtoCWProxyImpl
    implements _$LanDiscoveryNetworkInfoDtoCWProxy {
  const _$LanDiscoveryNetworkInfoDtoCWProxyImpl(this._value);

  final LanDiscoveryNetworkInfoDto _value;

  @override
  LanDiscoveryNetworkInfoDto ip(String ip) => this(ip: ip);

  @override
  LanDiscoveryNetworkInfoDto port(int port) => this(port: port);

  @override
  LanDiscoveryNetworkInfoDto protocol(String protocol) =>
      this(protocol: protocol);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanDiscoveryNetworkInfoDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanDiscoveryNetworkInfoDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanDiscoveryNetworkInfoDto call({
    Object? ip = const $CopyWithPlaceholder(),
    Object? port = const $CopyWithPlaceholder(),
    Object? protocol = const $CopyWithPlaceholder(),
  }) {
    return LanDiscoveryNetworkInfoDto(
      ip: ip == const $CopyWithPlaceholder()
          ? _value.ip
          // ignore: cast_nullable_to_non_nullable
          : ip as String,
      port: port == const $CopyWithPlaceholder()
          ? _value.port
          // ignore: cast_nullable_to_non_nullable
          : port as int,
      protocol: protocol == const $CopyWithPlaceholder()
          ? _value.protocol
          // ignore: cast_nullable_to_non_nullable
          : protocol as String,
    );
  }
}

extension $LanDiscoveryNetworkInfoDtoCopyWith on LanDiscoveryNetworkInfoDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanDiscoveryNetworkInfoDto.copyWith(...)` or like so:`instanceOfLanDiscoveryNetworkInfoDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanDiscoveryNetworkInfoDtoCWProxy get copyWith =>
      _$LanDiscoveryNetworkInfoDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanDiscoveryNetworkInfoDto _$LanDiscoveryNetworkInfoDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LanDiscoveryNetworkInfoDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['ip', 'port', 'protocol']);
  final val = LanDiscoveryNetworkInfoDto(
    ip: $checkedConvert('ip', (v) => v as String),
    port: $checkedConvert('port', (v) => (v as num).toInt()),
    protocol: $checkedConvert('protocol', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$LanDiscoveryNetworkInfoDtoToJson(
  LanDiscoveryNetworkInfoDto instance,
) => <String, dynamic>{
  'ip': instance.ip,
  'port': instance.port,
  'protocol': instance.protocol,
};
