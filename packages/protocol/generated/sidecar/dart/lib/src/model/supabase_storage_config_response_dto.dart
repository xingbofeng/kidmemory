//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/supabase_s3_config_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'supabase_storage_config_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SupabaseStorageConfigResponseDto {
  /// Returns a new [SupabaseStorageConfigResponseDto] instance.
  SupabaseStorageConfigResponseDto({

     this.configured,

     this.url,

     this.bucket,

     this.serviceRoleKeyConfigured,

     this.publicBaseUrl,

     this.signedUrlTtlSeconds,

     this.s3CredentialsDetected,

     this.authMode,

     this.diagnosticMessage,

     this.s3,
  });

  @JsonKey(

    name: r'configured',
    required: false,
    includeIfNull: false,
  )


  final bool? configured;



  @JsonKey(

    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(

    name: r'bucket',
    required: false,
    includeIfNull: false,
  )


  final String? bucket;



  @JsonKey(

    name: r'serviceRoleKeyConfigured',
    required: false,
    includeIfNull: false,
  )


  final bool? serviceRoleKeyConfigured;



  @JsonKey(

    name: r'publicBaseUrl',
    required: false,
    includeIfNull: false,
  )


  final String? publicBaseUrl;



  @JsonKey(

    name: r'signedUrlTtlSeconds',
    required: false,
    includeIfNull: false,
  )


  final int? signedUrlTtlSeconds;



  @JsonKey(

    name: r's3CredentialsDetected',
    required: false,
    includeIfNull: false,
  )


  final bool? s3CredentialsDetected;



  @JsonKey(

    name: r'authMode',
    required: false,
    includeIfNull: false,
  )


  final String? authMode;



  @JsonKey(

    name: r'diagnosticMessage',
    required: false,
    includeIfNull: false,
  )


  final String? diagnosticMessage;



  @JsonKey(

    name: r's3',
    required: false,
    includeIfNull: false,
  )


  final SupabaseS3ConfigResponseDto? s3;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SupabaseStorageConfigResponseDto &&
      other.configured == configured &&
      other.url == url &&
      other.bucket == bucket &&
      other.serviceRoleKeyConfigured == serviceRoleKeyConfigured &&
      other.publicBaseUrl == publicBaseUrl &&
      other.signedUrlTtlSeconds == signedUrlTtlSeconds &&
      other.s3CredentialsDetected == s3CredentialsDetected &&
      other.authMode == authMode &&
      other.diagnosticMessage == diagnosticMessage &&
      other.s3 == s3;

    @override
    int get hashCode =>
        configured.hashCode +
        url.hashCode +
        bucket.hashCode +
        serviceRoleKeyConfigured.hashCode +
        publicBaseUrl.hashCode +
        signedUrlTtlSeconds.hashCode +
        s3CredentialsDetected.hashCode +
        authMode.hashCode +
        diagnosticMessage.hashCode +
        s3.hashCode;

  factory SupabaseStorageConfigResponseDto.fromJson(Map<String, dynamic> json) => _$SupabaseStorageConfigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupabaseStorageConfigResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
