//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'supabase_storage_config_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SupabaseStorageConfigRequestDto {
  /// Returns a new [SupabaseStorageConfigRequestDto] instance.
  SupabaseStorageConfigRequestDto({

    required  this.url,

    required  this.bucket,

     this.serviceRoleKey,

    required  this.publicBaseUrl,

    required  this.signedUrlTtlSeconds,

    required  this.s3Endpoint,

    required  this.s3Region,

     this.s3AccessKeyId,

     this.s3SecretAccessKey,
  });

  @JsonKey(

    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(

    name: r'bucket',
    required: true,
    includeIfNull: false,
  )


  final String bucket;



  @JsonKey(

    name: r'serviceRoleKey',
    required: false,
    includeIfNull: false,
  )


  final String? serviceRoleKey;



  @JsonKey(

    name: r'publicBaseUrl',
    required: true,
    includeIfNull: false,
  )


  final String publicBaseUrl;



  @JsonKey(

    name: r'signedUrlTtlSeconds',
    required: true,
    includeIfNull: false,
  )


  final int signedUrlTtlSeconds;



  @JsonKey(

    name: r's3Endpoint',
    required: true,
    includeIfNull: false,
  )


  final String s3Endpoint;



  @JsonKey(

    name: r's3Region',
    required: true,
    includeIfNull: false,
  )


  final String s3Region;



  @JsonKey(

    name: r's3AccessKeyId',
    required: false,
    includeIfNull: false,
  )


  final String? s3AccessKeyId;



  @JsonKey(

    name: r's3SecretAccessKey',
    required: false,
    includeIfNull: false,
  )


  final String? s3SecretAccessKey;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SupabaseStorageConfigRequestDto &&
      other.url == url &&
      other.bucket == bucket &&
      other.serviceRoleKey == serviceRoleKey &&
      other.publicBaseUrl == publicBaseUrl &&
      other.signedUrlTtlSeconds == signedUrlTtlSeconds &&
      other.s3Endpoint == s3Endpoint &&
      other.s3Region == s3Region &&
      other.s3AccessKeyId == s3AccessKeyId &&
      other.s3SecretAccessKey == s3SecretAccessKey;

    @override
    int get hashCode =>
        url.hashCode +
        bucket.hashCode +
        serviceRoleKey.hashCode +
        publicBaseUrl.hashCode +
        signedUrlTtlSeconds.hashCode +
        s3Endpoint.hashCode +
        s3Region.hashCode +
        s3AccessKeyId.hashCode +
        s3SecretAccessKey.hashCode;

  factory SupabaseStorageConfigRequestDto.fromJson(Map<String, dynamic> json) => _$SupabaseStorageConfigRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupabaseStorageConfigRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
