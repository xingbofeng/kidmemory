//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_commit_upload_item_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCommitUploadItemRequest {
  /// Returns a new [WebCompanionControllerCommitUploadItemRequest] instance.
  WebCompanionControllerCommitUploadItemRequest({

    required  this.token,

    required  this.objectKey,

     this.sizeBytes,

     this.contentType,

     this.remoteEtag,
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

    name: r'sizeBytes',
    required: false,
    includeIfNull: false,
  )


  final num? sizeBytes;



  @JsonKey(

    name: r'contentType',
    required: false,
    includeIfNull: false,
  )


  final String? contentType;



  @JsonKey(

    name: r'remoteEtag',
    required: false,
    includeIfNull: false,
  )


  final String? remoteEtag;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCommitUploadItemRequest &&
      other.token == token &&
      other.objectKey == objectKey &&
      other.sizeBytes == sizeBytes &&
      other.contentType == contentType &&
      other.remoteEtag == remoteEtag;

    @override
    int get hashCode =>
        token.hashCode +
        objectKey.hashCode +
        sizeBytes.hashCode +
        contentType.hashCode +
        remoteEtag.hashCode;

  factory WebCompanionControllerCommitUploadItemRequest.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCommitUploadItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCommitUploadItemRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
