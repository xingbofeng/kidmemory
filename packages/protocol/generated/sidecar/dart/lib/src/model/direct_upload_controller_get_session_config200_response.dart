//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_controller_get_session_config200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadControllerGetSessionConfig200Response {
  /// Returns a new [DirectUploadControllerGetSessionConfig200Response] instance.
  DirectUploadControllerGetSessionConfig200Response({

    required  this.supabaseUrl,

    required  this.anonKey,

    required  this.bucket,

    required  this.recommendedClientLimit,
  });

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

    name: r'bucket',
    required: true,
    includeIfNull: false,
  )


  final String bucket;



  @JsonKey(

    name: r'recommendedClientLimit',
    required: true,
    includeIfNull: false,
  )


  final num recommendedClientLimit;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadControllerGetSessionConfig200Response &&
      other.supabaseUrl == supabaseUrl &&
      other.anonKey == anonKey &&
      other.bucket == bucket &&
      other.recommendedClientLimit == recommendedClientLimit;

    @override
    int get hashCode =>
        supabaseUrl.hashCode +
        anonKey.hashCode +
        bucket.hashCode +
        recommendedClientLimit.hashCode;

  factory DirectUploadControllerGetSessionConfig200Response.fromJson(Map<String, dynamic> json) => _$DirectUploadControllerGetSessionConfig200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadControllerGetSessionConfig200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
