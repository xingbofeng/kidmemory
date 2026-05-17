// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_discovery_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanDiscoveryResponseDtoCWProxy {
  LanDiscoveryResponseDto deviceId(String deviceId);

  LanDiscoveryResponseDto deviceName(String deviceName);

  LanDiscoveryResponseDto version(String version);

  LanDiscoveryResponseDto capabilities(List<String> capabilities);

  LanDiscoveryResponseDto networkInfo(LanDiscoveryNetworkInfoDto networkInfo);

  LanDiscoveryResponseDto security(LanDiscoverySecurityDto security);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanDiscoveryResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanDiscoveryResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanDiscoveryResponseDto call({
    String deviceId,
    String deviceName,
    String version,
    List<String> capabilities,
    LanDiscoveryNetworkInfoDto networkInfo,
    LanDiscoverySecurityDto security,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanDiscoveryResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanDiscoveryResponseDto.copyWith.fieldName(...)`
class _$LanDiscoveryResponseDtoCWProxyImpl
    implements _$LanDiscoveryResponseDtoCWProxy {
  const _$LanDiscoveryResponseDtoCWProxyImpl(this._value);

  final LanDiscoveryResponseDto _value;

  @override
  LanDiscoveryResponseDto deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  LanDiscoveryResponseDto deviceName(String deviceName) =>
      this(deviceName: deviceName);

  @override
  LanDiscoveryResponseDto version(String version) => this(version: version);

  @override
  LanDiscoveryResponseDto capabilities(List<String> capabilities) =>
      this(capabilities: capabilities);

  @override
  LanDiscoveryResponseDto networkInfo(LanDiscoveryNetworkInfoDto networkInfo) =>
      this(networkInfo: networkInfo);

  @override
  LanDiscoveryResponseDto security(LanDiscoverySecurityDto security) =>
      this(security: security);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanDiscoveryResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanDiscoveryResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanDiscoveryResponseDto call({
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? deviceName = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? capabilities = const $CopyWithPlaceholder(),
    Object? networkInfo = const $CopyWithPlaceholder(),
    Object? security = const $CopyWithPlaceholder(),
  }) {
    return LanDiscoveryResponseDto(
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String,
      deviceName: deviceName == const $CopyWithPlaceholder()
          ? _value.deviceName
          // ignore: cast_nullable_to_non_nullable
          : deviceName as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String,
      capabilities: capabilities == const $CopyWithPlaceholder()
          ? _value.capabilities
          // ignore: cast_nullable_to_non_nullable
          : capabilities as List<String>,
      networkInfo: networkInfo == const $CopyWithPlaceholder()
          ? _value.networkInfo
          // ignore: cast_nullable_to_non_nullable
          : networkInfo as LanDiscoveryNetworkInfoDto,
      security: security == const $CopyWithPlaceholder()
          ? _value.security
          // ignore: cast_nullable_to_non_nullable
          : security as LanDiscoverySecurityDto,
    );
  }
}

extension $LanDiscoveryResponseDtoCopyWith on LanDiscoveryResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanDiscoveryResponseDto.copyWith(...)` or like so:`instanceOfLanDiscoveryResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanDiscoveryResponseDtoCWProxy get copyWith =>
      _$LanDiscoveryResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanDiscoveryResponseDto _$LanDiscoveryResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LanDiscoveryResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'deviceId',
      'deviceName',
      'version',
      'capabilities',
      'networkInfo',
      'security',
    ],
  );
  final val = LanDiscoveryResponseDto(
    deviceId: $checkedConvert('deviceId', (v) => v as String),
    deviceName: $checkedConvert('deviceName', (v) => v as String),
    version: $checkedConvert('version', (v) => v as String),
    capabilities: $checkedConvert(
      'capabilities',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    networkInfo: $checkedConvert(
      'networkInfo',
      (v) => LanDiscoveryNetworkInfoDto.fromJson(v as Map<String, dynamic>),
    ),
    security: $checkedConvert(
      'security',
      (v) => LanDiscoverySecurityDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$LanDiscoveryResponseDtoToJson(
  LanDiscoveryResponseDto instance,
) => <String, dynamic>{
  'deviceId': instance.deviceId,
  'deviceName': instance.deviceName,
  'version': instance.version,
  'capabilities': instance.capabilities,
  'networkInfo': instance.networkInfo.toJson(),
  'security': instance.security.toJson(),
};
