// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_discovery_security_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanDiscoverySecurityDtoCWProxy {
  LanDiscoverySecurityDto requiresAuth(bool requiresAuth);

  LanDiscoverySecurityDto supportedMethods(List<String> supportedMethods);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanDiscoverySecurityDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanDiscoverySecurityDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanDiscoverySecurityDto call({
    bool requiresAuth,
    List<String> supportedMethods,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanDiscoverySecurityDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanDiscoverySecurityDto.copyWith.fieldName(...)`
class _$LanDiscoverySecurityDtoCWProxyImpl
    implements _$LanDiscoverySecurityDtoCWProxy {
  const _$LanDiscoverySecurityDtoCWProxyImpl(this._value);

  final LanDiscoverySecurityDto _value;

  @override
  LanDiscoverySecurityDto requiresAuth(bool requiresAuth) =>
      this(requiresAuth: requiresAuth);

  @override
  LanDiscoverySecurityDto supportedMethods(List<String> supportedMethods) =>
      this(supportedMethods: supportedMethods);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanDiscoverySecurityDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanDiscoverySecurityDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanDiscoverySecurityDto call({
    Object? requiresAuth = const $CopyWithPlaceholder(),
    Object? supportedMethods = const $CopyWithPlaceholder(),
  }) {
    return LanDiscoverySecurityDto(
      requiresAuth: requiresAuth == const $CopyWithPlaceholder()
          ? _value.requiresAuth
          // ignore: cast_nullable_to_non_nullable
          : requiresAuth as bool,
      supportedMethods: supportedMethods == const $CopyWithPlaceholder()
          ? _value.supportedMethods
          // ignore: cast_nullable_to_non_nullable
          : supportedMethods as List<String>,
    );
  }
}

extension $LanDiscoverySecurityDtoCopyWith on LanDiscoverySecurityDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanDiscoverySecurityDto.copyWith(...)` or like so:`instanceOfLanDiscoverySecurityDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanDiscoverySecurityDtoCWProxy get copyWith =>
      _$LanDiscoverySecurityDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanDiscoverySecurityDto _$LanDiscoverySecurityDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LanDiscoverySecurityDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['requiresAuth', 'supportedMethods']);
  final val = LanDiscoverySecurityDto(
    requiresAuth: $checkedConvert('requiresAuth', (v) => v as bool),
    supportedMethods: $checkedConvert(
      'supportedMethods',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$LanDiscoverySecurityDtoToJson(
  LanDiscoverySecurityDto instance,
) => <String, dynamic>{
  'requiresAuth': instance.requiresAuth,
  'supportedMethods': instance.supportedMethods,
};
