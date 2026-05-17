//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'supabase_s3_config_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SupabaseS3ConfigResponseDto {
  /// Returns a new [SupabaseS3ConfigResponseDto] instance.
  SupabaseS3ConfigResponseDto({

     this.endpoint,

     this.region,

     this.accessKeyIdConfigured,

     this.secretAccessKeyConfigured,
  });

  @JsonKey(

    name: r'endpoint',
    required: false,
    includeIfNull: false,
  )


  final String? endpoint;



  @JsonKey(

    name: r'region',
    required: false,
    includeIfNull: false,
  )


  final String? region;



  @JsonKey(

    name: r'accessKeyIdConfigured',
    required: false,
    includeIfNull: false,
  )


  final bool? accessKeyIdConfigured;



  @JsonKey(

    name: r'secretAccessKeyConfigured',
    required: false,
    includeIfNull: false,
  )


  final bool? secretAccessKeyConfigured;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SupabaseS3ConfigResponseDto &&
      other.endpoint == endpoint &&
      other.region == region &&
      other.accessKeyIdConfigured == accessKeyIdConfigured &&
      other.secretAccessKeyConfigured == secretAccessKeyConfigured;

    @override
    int get hashCode =>
        endpoint.hashCode +
        region.hashCode +
        accessKeyIdConfigured.hashCode +
        secretAccessKeyConfigured.hashCode;

  factory SupabaseS3ConfigResponseDto.fromJson(Map<String, dynamic> json) => _$SupabaseS3ConfigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupabaseS3ConfigResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
