// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_s3_config_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SupabaseS3ConfigResponseDtoCWProxy {
  SupabaseS3ConfigResponseDto endpoint(String? endpoint);

  SupabaseS3ConfigResponseDto region(String? region);

  SupabaseS3ConfigResponseDto accessKeyIdConfigured(
    bool? accessKeyIdConfigured,
  );

  SupabaseS3ConfigResponseDto secretAccessKeyConfigured(
    bool? secretAccessKeyConfigured,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseS3ConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseS3ConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseS3ConfigResponseDto call({
    String? endpoint,
    String? region,
    bool? accessKeyIdConfigured,
    bool? secretAccessKeyConfigured,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSupabaseS3ConfigResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSupabaseS3ConfigResponseDto.copyWith.fieldName(...)`
class _$SupabaseS3ConfigResponseDtoCWProxyImpl
    implements _$SupabaseS3ConfigResponseDtoCWProxy {
  const _$SupabaseS3ConfigResponseDtoCWProxyImpl(this._value);

  final SupabaseS3ConfigResponseDto _value;

  @override
  SupabaseS3ConfigResponseDto endpoint(String? endpoint) =>
      this(endpoint: endpoint);

  @override
  SupabaseS3ConfigResponseDto region(String? region) => this(region: region);

  @override
  SupabaseS3ConfigResponseDto accessKeyIdConfigured(
    bool? accessKeyIdConfigured,
  ) => this(accessKeyIdConfigured: accessKeyIdConfigured);

  @override
  SupabaseS3ConfigResponseDto secretAccessKeyConfigured(
    bool? secretAccessKeyConfigured,
  ) => this(secretAccessKeyConfigured: secretAccessKeyConfigured);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseS3ConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseS3ConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseS3ConfigResponseDto call({
    Object? endpoint = const $CopyWithPlaceholder(),
    Object? region = const $CopyWithPlaceholder(),
    Object? accessKeyIdConfigured = const $CopyWithPlaceholder(),
    Object? secretAccessKeyConfigured = const $CopyWithPlaceholder(),
  }) {
    return SupabaseS3ConfigResponseDto(
      endpoint: endpoint == const $CopyWithPlaceholder()
          ? _value.endpoint
          // ignore: cast_nullable_to_non_nullable
          : endpoint as String?,
      region: region == const $CopyWithPlaceholder()
          ? _value.region
          // ignore: cast_nullable_to_non_nullable
          : region as String?,
      accessKeyIdConfigured:
          accessKeyIdConfigured == const $CopyWithPlaceholder()
          ? _value.accessKeyIdConfigured
          // ignore: cast_nullable_to_non_nullable
          : accessKeyIdConfigured as bool?,
      secretAccessKeyConfigured:
          secretAccessKeyConfigured == const $CopyWithPlaceholder()
          ? _value.secretAccessKeyConfigured
          // ignore: cast_nullable_to_non_nullable
          : secretAccessKeyConfigured as bool?,
    );
  }
}

extension $SupabaseS3ConfigResponseDtoCopyWith on SupabaseS3ConfigResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfSupabaseS3ConfigResponseDto.copyWith(...)` or like so:`instanceOfSupabaseS3ConfigResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SupabaseS3ConfigResponseDtoCWProxy get copyWith =>
      _$SupabaseS3ConfigResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupabaseS3ConfigResponseDto _$SupabaseS3ConfigResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SupabaseS3ConfigResponseDto', json, ($checkedConvert) {
  final val = SupabaseS3ConfigResponseDto(
    endpoint: $checkedConvert('endpoint', (v) => v as String?),
    region: $checkedConvert('region', (v) => v as String?),
    accessKeyIdConfigured: $checkedConvert(
      'accessKeyIdConfigured',
      (v) => v as bool?,
    ),
    secretAccessKeyConfigured: $checkedConvert(
      'secretAccessKeyConfigured',
      (v) => v as bool?,
    ),
  );
  return val;
});

Map<String, dynamic> _$SupabaseS3ConfigResponseDtoToJson(
  SupabaseS3ConfigResponseDto instance,
) => <String, dynamic>{
if (instance.endpoint != null) 'endpoint': instance.endpoint,
if (instance.region != null) 'region': instance.region,
if (instance.accessKeyIdConfigured != null) 'accessKeyIdConfigured': instance.accessKeyIdConfigured,
if (instance.secretAccessKeyConfigured != null) 'secretAccessKeyConfigured': instance.secretAccessKeyConfigured,
};
