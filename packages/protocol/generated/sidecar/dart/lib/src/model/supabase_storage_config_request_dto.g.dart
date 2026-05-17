// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_storage_config_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SupabaseStorageConfigRequestDtoCWProxy {
  SupabaseStorageConfigRequestDto url(String url);

  SupabaseStorageConfigRequestDto bucket(String bucket);

  SupabaseStorageConfigRequestDto serviceRoleKey(String? serviceRoleKey);

  SupabaseStorageConfigRequestDto publicBaseUrl(String publicBaseUrl);

  SupabaseStorageConfigRequestDto signedUrlTtlSeconds(int signedUrlTtlSeconds);

  SupabaseStorageConfigRequestDto s3Endpoint(String s3Endpoint);

  SupabaseStorageConfigRequestDto s3Region(String s3Region);

  SupabaseStorageConfigRequestDto s3AccessKeyId(String? s3AccessKeyId);

  SupabaseStorageConfigRequestDto s3SecretAccessKey(String? s3SecretAccessKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseStorageConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseStorageConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseStorageConfigRequestDto call({
    String url,
    String bucket,
    String? serviceRoleKey,
    String publicBaseUrl,
    int signedUrlTtlSeconds,
    String s3Endpoint,
    String s3Region,
    String? s3AccessKeyId,
    String? s3SecretAccessKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSupabaseStorageConfigRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSupabaseStorageConfigRequestDto.copyWith.fieldName(...)`
class _$SupabaseStorageConfigRequestDtoCWProxyImpl
    implements _$SupabaseStorageConfigRequestDtoCWProxy {
  const _$SupabaseStorageConfigRequestDtoCWProxyImpl(this._value);

  final SupabaseStorageConfigRequestDto _value;

  @override
  SupabaseStorageConfigRequestDto url(String url) => this(url: url);

  @override
  SupabaseStorageConfigRequestDto bucket(String bucket) => this(bucket: bucket);

  @override
  SupabaseStorageConfigRequestDto serviceRoleKey(String? serviceRoleKey) =>
      this(serviceRoleKey: serviceRoleKey);

  @override
  SupabaseStorageConfigRequestDto publicBaseUrl(String publicBaseUrl) =>
      this(publicBaseUrl: publicBaseUrl);

  @override
  SupabaseStorageConfigRequestDto signedUrlTtlSeconds(
    int signedUrlTtlSeconds,
  ) => this(signedUrlTtlSeconds: signedUrlTtlSeconds);

  @override
  SupabaseStorageConfigRequestDto s3Endpoint(String s3Endpoint) =>
      this(s3Endpoint: s3Endpoint);

  @override
  SupabaseStorageConfigRequestDto s3Region(String s3Region) =>
      this(s3Region: s3Region);

  @override
  SupabaseStorageConfigRequestDto s3AccessKeyId(String? s3AccessKeyId) =>
      this(s3AccessKeyId: s3AccessKeyId);

  @override
  SupabaseStorageConfigRequestDto s3SecretAccessKey(
    String? s3SecretAccessKey,
  ) => this(s3SecretAccessKey: s3SecretAccessKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseStorageConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseStorageConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseStorageConfigRequestDto call({
    Object? url = const $CopyWithPlaceholder(),
    Object? bucket = const $CopyWithPlaceholder(),
    Object? serviceRoleKey = const $CopyWithPlaceholder(),
    Object? publicBaseUrl = const $CopyWithPlaceholder(),
    Object? signedUrlTtlSeconds = const $CopyWithPlaceholder(),
    Object? s3Endpoint = const $CopyWithPlaceholder(),
    Object? s3Region = const $CopyWithPlaceholder(),
    Object? s3AccessKeyId = const $CopyWithPlaceholder(),
    Object? s3SecretAccessKey = const $CopyWithPlaceholder(),
  }) {
    return SupabaseStorageConfigRequestDto(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      bucket: bucket == const $CopyWithPlaceholder()
          ? _value.bucket
          // ignore: cast_nullable_to_non_nullable
          : bucket as String,
      serviceRoleKey: serviceRoleKey == const $CopyWithPlaceholder()
          ? _value.serviceRoleKey
          // ignore: cast_nullable_to_non_nullable
          : serviceRoleKey as String?,
      publicBaseUrl: publicBaseUrl == const $CopyWithPlaceholder()
          ? _value.publicBaseUrl
          // ignore: cast_nullable_to_non_nullable
          : publicBaseUrl as String,
      signedUrlTtlSeconds: signedUrlTtlSeconds == const $CopyWithPlaceholder()
          ? _value.signedUrlTtlSeconds
          // ignore: cast_nullable_to_non_nullable
          : signedUrlTtlSeconds as int,
      s3Endpoint: s3Endpoint == const $CopyWithPlaceholder()
          ? _value.s3Endpoint
          // ignore: cast_nullable_to_non_nullable
          : s3Endpoint as String,
      s3Region: s3Region == const $CopyWithPlaceholder()
          ? _value.s3Region
          // ignore: cast_nullable_to_non_nullable
          : s3Region as String,
      s3AccessKeyId: s3AccessKeyId == const $CopyWithPlaceholder()
          ? _value.s3AccessKeyId
          // ignore: cast_nullable_to_non_nullable
          : s3AccessKeyId as String?,
      s3SecretAccessKey: s3SecretAccessKey == const $CopyWithPlaceholder()
          ? _value.s3SecretAccessKey
          // ignore: cast_nullable_to_non_nullable
          : s3SecretAccessKey as String?,
    );
  }
}

extension $SupabaseStorageConfigRequestDtoCopyWith
    on SupabaseStorageConfigRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfSupabaseStorageConfigRequestDto.copyWith(...)` or like so:`instanceOfSupabaseStorageConfigRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SupabaseStorageConfigRequestDtoCWProxy get copyWith =>
      _$SupabaseStorageConfigRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupabaseStorageConfigRequestDto _$SupabaseStorageConfigRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SupabaseStorageConfigRequestDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'url',
      'bucket',
      'publicBaseUrl',
      'signedUrlTtlSeconds',
      's3Endpoint',
      's3Region',
    ],
  );
  final val = SupabaseStorageConfigRequestDto(
    url: $checkedConvert('url', (v) => v as String),
    bucket: $checkedConvert('bucket', (v) => v as String),
    serviceRoleKey: $checkedConvert('serviceRoleKey', (v) => v as String?),
    publicBaseUrl: $checkedConvert('publicBaseUrl', (v) => v as String),
    signedUrlTtlSeconds: $checkedConvert(
      'signedUrlTtlSeconds',
      (v) => (v as num).toInt(),
    ),
    s3Endpoint: $checkedConvert('s3Endpoint', (v) => v as String),
    s3Region: $checkedConvert('s3Region', (v) => v as String),
    s3AccessKeyId: $checkedConvert('s3AccessKeyId', (v) => v as String?),
    s3SecretAccessKey: $checkedConvert(
      's3SecretAccessKey',
      (v) => v as String?,
    ),
  );
  return val;
});

Map<String, dynamic> _$SupabaseStorageConfigRequestDtoToJson(
  SupabaseStorageConfigRequestDto instance,
) => <String, dynamic>{
  'url': instance.url,
  'bucket': instance.bucket,
if (instance.serviceRoleKey != null) 'serviceRoleKey': instance.serviceRoleKey,
  'publicBaseUrl': instance.publicBaseUrl,
  'signedUrlTtlSeconds': instance.signedUrlTtlSeconds,
  's3Endpoint': instance.s3Endpoint,
  's3Region': instance.s3Region,
if (instance.s3AccessKeyId != null) 's3AccessKeyId': instance.s3AccessKeyId,
if (instance.s3SecretAccessKey != null) 's3SecretAccessKey': instance.s3SecretAccessKey,
};
