//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_commit_upload_item200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCommitUploadItem200Response {
  /// Returns a new [WebCompanionControllerCommitUploadItem200Response] instance.
  WebCompanionControllerCommitUploadItem200Response({

    required  this.uploadItemId,

    required  this.status,

     this.idempotent,
  });

  @JsonKey(

    name: r'uploadItemId',
    required: true,
    includeIfNull: false,
  )


  final String uploadItemId;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(

    name: r'idempotent',
    required: false,
    includeIfNull: false,
  )


  final bool? idempotent;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCommitUploadItem200Response &&
      other.uploadItemId == uploadItemId &&
      other.status == status &&
      other.idempotent == idempotent;

    @override
    int get hashCode =>
        uploadItemId.hashCode +
        status.hashCode +
        idempotent.hashCode;

  factory WebCompanionControllerCommitUploadItem200Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCommitUploadItem200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCommitUploadItem200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
