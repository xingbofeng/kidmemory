//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_controller_create_session_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadControllerCreateSessionRequest {
  /// Returns a new [DirectUploadControllerCreateSessionRequest] instance.
  DirectUploadControllerCreateSessionRequest({

    required  this.childId,
  });

  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadControllerCreateSessionRequest &&
      other.childId == childId;

    @override
    int get hashCode =>
        childId.hashCode;

  factory DirectUploadControllerCreateSessionRequest.fromJson(Map<String, dynamic> json) => _$DirectUploadControllerCreateSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadControllerCreateSessionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
