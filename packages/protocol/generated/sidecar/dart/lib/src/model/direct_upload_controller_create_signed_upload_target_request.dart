//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_controller_create_signed_upload_target_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadControllerCreateSignedUploadTargetRequest {
  /// Returns a new [DirectUploadControllerCreateSignedUploadTargetRequest] instance.
  DirectUploadControllerCreateSignedUploadTargetRequest({

    required  this.token,

    required  this.objectKey,

     this.contentType,

     this.sizeBytes,
  });

  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(

    name: r'objectKey',
    required: true,
    includeIfNull: false,
  )


  final String objectKey;



  @JsonKey(

    name: r'contentType',
    required: false,
    includeIfNull: false,
  )


  final String? contentType;



  @JsonKey(

    name: r'sizeBytes',
    required: false,
    includeIfNull: false,
  )


  final num? sizeBytes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadControllerCreateSignedUploadTargetRequest &&
      other.token == token &&
      other.objectKey == objectKey &&
      other.contentType == contentType &&
      other.sizeBytes == sizeBytes;

    @override
    int get hashCode =>
        token.hashCode +
        objectKey.hashCode +
        contentType.hashCode +
        sizeBytes.hashCode;

  factory DirectUploadControllerCreateSignedUploadTargetRequest.fromJson(Map<String, dynamic> json) => _$DirectUploadControllerCreateSignedUploadTargetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadControllerCreateSignedUploadTargetRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
