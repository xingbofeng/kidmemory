//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_direct_upload_session_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDirectUploadSessionResponseDto {
  /// Returns a new [CreateDirectUploadSessionResponseDto] instance.
  CreateDirectUploadSessionResponseDto({

    required  this.sessionId,

    required  this.childId,

    required  this.bucket,

    required  this.sessionPath,

    required  this.supabaseUrl,

    required  this.anonKey,

    required  this.publicUrl,

    required  this.recommendedClientLimit,

    required  this.expiresAtHintSeconds,

    required  this.token,
  });

  @JsonKey(

    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(

    name: r'bucket',
    required: true,
    includeIfNull: false,
  )


  final String bucket;



  @JsonKey(

    name: r'sessionPath',
    required: true,
    includeIfNull: false,
  )


  final String sessionPath;



  @JsonKey(

    name: r'supabaseUrl',
    required: true,
    includeIfNull: false,
  )


  final String supabaseUrl;



  @JsonKey(

    name: r'anonKey',
    required: true,
    includeIfNull: false,
  )


  final String anonKey;



  @JsonKey(

    name: r'publicUrl',
    required: true,
    includeIfNull: false,
  )


  final String publicUrl;



  @JsonKey(

    name: r'recommendedClientLimit',
    required: true,
    includeIfNull: false,
  )


  final int recommendedClientLimit;



  @JsonKey(

    name: r'expiresAtHintSeconds',
    required: true,
    includeIfNull: false,
  )


  final int expiresAtHintSeconds;



  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateDirectUploadSessionResponseDto &&
      other.sessionId == sessionId &&
      other.childId == childId &&
      other.bucket == bucket &&
      other.sessionPath == sessionPath &&
      other.supabaseUrl == supabaseUrl &&
      other.anonKey == anonKey &&
      other.publicUrl == publicUrl &&
      other.recommendedClientLimit == recommendedClientLimit &&
      other.expiresAtHintSeconds == expiresAtHintSeconds &&
      other.token == token;

    @override
    int get hashCode =>
        sessionId.hashCode +
        childId.hashCode +
        bucket.hashCode +
        sessionPath.hashCode +
        supabaseUrl.hashCode +
        anonKey.hashCode +
        publicUrl.hashCode +
        recommendedClientLimit.hashCode +
        expiresAtHintSeconds.hashCode +
        token.hashCode;

  factory CreateDirectUploadSessionResponseDto.fromJson(Map<String, dynamic> json) => _$CreateDirectUploadSessionResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDirectUploadSessionResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
