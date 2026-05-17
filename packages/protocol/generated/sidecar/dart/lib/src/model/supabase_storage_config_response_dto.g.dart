// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_storage_config_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SupabaseStorageConfigResponseDtoCWProxy {
  SupabaseStorageConfigResponseDto configured(bool? configured);

  SupabaseStorageConfigResponseDto url(String? url);

  SupabaseStorageConfigResponseDto bucket(String? bucket);

  SupabaseStorageConfigResponseDto serviceRoleKeyConfigured(
    bool? serviceRoleKeyConfigured,
  );

  SupabaseStorageConfigResponseDto publicBaseUrl(String? publicBaseUrl);

  SupabaseStorageConfigResponseDto signedUrlTtlSeconds(
    int? signedUrlTtlSeconds,
  );

  SupabaseStorageConfigResponseDto s3CredentialsDetected(
    bool? s3CredentialsDetected,
  );

  SupabaseStorageConfigResponseDto authMode(String? authMode);

  SupabaseStorageConfigResponseDto diagnosticMessage(String? diagnosticMessage);

  SupabaseStorageConfigResponseDto s3(SupabaseS3ConfigResponseDto? s3);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseStorageConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseStorageConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseStorageConfigResponseDto call({
    bool? configured,
    String? url,
    String? bucket,
    bool? serviceRoleKeyConfigured,
    String? publicBaseUrl,
    int? signedUrlTtlSeconds,
    bool? s3CredentialsDetected,
    String? authMode,
    String? diagnosticMessage,
    SupabaseS3ConfigResponseDto? s3,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSupabaseStorageConfigResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSupabaseStorageConfigResponseDto.copyWith.fieldName(...)`
class _$SupabaseStorageConfigResponseDtoCWProxyImpl
    implements _$SupabaseStorageConfigResponseDtoCWProxy {
  const _$SupabaseStorageConfigResponseDtoCWProxyImpl(this._value);

  final SupabaseStorageConfigResponseDto _value;

  @override
  SupabaseStorageConfigResponseDto configured(bool? configured) =>
      this(configured: configured);

  @override
  SupabaseStorageConfigResponseDto url(String? url) => this(url: url);

  @override
  SupabaseStorageConfigResponseDto bucket(String? bucket) =>
      this(bucket: bucket);

  @override
  SupabaseStorageConfigResponseDto serviceRoleKeyConfigured(
    bool? serviceRoleKeyConfigured,
  ) => this(serviceRoleKeyConfigured: serviceRoleKeyConfigured);

  @override
  SupabaseStorageConfigResponseDto publicBaseUrl(String? publicBaseUrl) =>
      this(publicBaseUrl: publicBaseUrl);

  @override
  SupabaseStorageConfigResponseDto signedUrlTtlSeconds(
    int? signedUrlTtlSeconds,
  ) => this(signedUrlTtlSeconds: signedUrlTtlSeconds);

  @override
  SupabaseStorageConfigResponseDto s3CredentialsDetected(
    bool? s3CredentialsDetected,
  ) => this(s3CredentialsDetected: s3CredentialsDetected);

  @override
  SupabaseStorageConfigResponseDto authMode(String? authMode) =>
      this(authMode: authMode);

  @override
  SupabaseStorageConfigResponseDto diagnosticMessage(
    String? diagnosticMessage,
  ) => this(diagnosticMessage: diagnosticMessage);

  @override
  SupabaseStorageConfigResponseDto s3(SupabaseS3ConfigResponseDto? s3) =>
      this(s3: s3);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseStorageConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseStorageConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseStorageConfigResponseDto call({
    Object? configured = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? bucket = const $CopyWithPlaceholder(),
    Object? serviceRoleKeyConfigured = const $CopyWithPlaceholder(),
    Object? publicBaseUrl = const $CopyWithPlaceholder(),
    Object? signedUrlTtlSeconds = const $CopyWithPlaceholder(),
    Object? s3CredentialsDetected = const $CopyWithPlaceholder(),
    Object? authMode = const $CopyWithPlaceholder(),
    Object? diagnosticMessage = const $CopyWithPlaceholder(),
    Object? s3 = const $CopyWithPlaceholder(),
  }) {
    return SupabaseStorageConfigResponseDto(
      configured: configured == const $CopyWithPlaceholder()
          ? _value.configured
          // ignore: cast_nullable_to_non_nullable
          : configured as bool?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      bucket: bucket == const $CopyWithPlaceholder()
          ? _value.bucket
          // ignore: cast_nullable_to_non_nullable
          : bucket as String?,
      serviceRoleKeyConfigured:
          serviceRoleKeyConfigured == const $CopyWithPlaceholder()
          ? _value.serviceRoleKeyConfigured
          // ignore: cast_nullable_to_non_nullable
          : serviceRoleKeyConfigured as bool?,
      publicBaseUrl: publicBaseUrl == const $CopyWithPlaceholder()
          ? _value.publicBaseUrl
          // ignore: cast_nullable_to_non_nullable
          : publicBaseUrl as String?,
      signedUrlTtlSeconds: signedUrlTtlSeconds == const $CopyWithPlaceholder()
          ? _value.signedUrlTtlSeconds
          // ignore: cast_nullable_to_non_nullable
          : signedUrlTtlSeconds as int?,
      s3CredentialsDetected:
          s3CredentialsDetected == const $CopyWithPlaceholder()
          ? _value.s3CredentialsDetected
          // ignore: cast_nullable_to_non_nullable
          : s3CredentialsDetected as bool?,
      authMode: authMode == const $CopyWithPlaceholder()
          ? _value.authMode
          // ignore: cast_nullable_to_non_nullable
          : authMode as String?,
      diagnosticMessage: diagnosticMessage == const $CopyWithPlaceholder()
          ? _value.diagnosticMessage
          // ignore: cast_nullable_to_non_nullable
          : diagnosticMessage as String?,
      s3: s3 == const $CopyWithPlaceholder()
          ? _value.s3
          // ignore: cast_nullable_to_non_nullable
          : s3 as SupabaseS3ConfigResponseDto?,
    );
  }
}

extension $SupabaseStorageConfigResponseDtoCopyWith
    on SupabaseStorageConfigResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfSupabaseStorageConfigResponseDto.copyWith(...)` or like so:`instanceOfSupabaseStorageConfigResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SupabaseStorageConfigResponseDtoCWProxy get copyWith =>
      _$SupabaseStorageConfigResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupabaseStorageConfigResponseDto _$SupabaseStorageConfigResponseDtoFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('SupabaseStorageConfigResponseDto', json, ($checkedConvert) {
      final val = SupabaseStorageConfigResponseDto(
        configured: $checkedConvert('configured', (v) => v as bool?),
        url: $checkedConvert('url', (v) => v as String?),
        bucket: $checkedConvert('bucket', (v) => v as String?),
        serviceRoleKeyConfigured: $checkedConvert(
          'serviceRoleKeyConfigured',
          (v) => v as bool?,
        ),
        publicBaseUrl: $checkedConvert('publicBaseUrl', (v) => v as String?),
        signedUrlTtlSeconds: $checkedConvert(
          'signedUrlTtlSeconds',
          (v) => (v as num?)?.toInt(),
        ),
        s3CredentialsDetected: $checkedConvert(
          's3CredentialsDetected',
          (v) => v as bool?,
        ),
        authMode: $checkedConvert('authMode', (v) => v as String?),
        diagnosticMessage: $checkedConvert(
          'diagnosticMessage',
          (v) => v as String?,
        ),
        s3: $checkedConvert(
          's3',
          (v) => v == null
              ? null
              : SupabaseS3ConfigResponseDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SupabaseStorageConfigResponseDtoToJson(
  SupabaseStorageConfigResponseDto instance,
) => <String, dynamic>{
if (instance.configured != null) 'configured': instance.configured,
if (instance.url != null) 'url': instance.url,
if (instance.bucket != null) 'bucket': instance.bucket,
if (instance.serviceRoleKeyConfigured != null) 'serviceRoleKeyConfigured': instance.serviceRoleKeyConfigured,
if (instance.publicBaseUrl != null) 'publicBaseUrl': instance.publicBaseUrl,
if (instance.signedUrlTtlSeconds != null) 'signedUrlTtlSeconds': instance.signedUrlTtlSeconds,
if (instance.s3CredentialsDetected != null) 's3CredentialsDetected': instance.s3CredentialsDetected,
if (instance.authMode != null) 'authMode': instance.authMode,
if (instance.diagnosticMessage != null) 'diagnosticMessage': instance.diagnosticMessage,
if (instance.s3?.toJson() != null) 's3': instance.s3?.toJson(),
};
