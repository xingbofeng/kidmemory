//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_controller_pullback_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadControllerPullbackRequest {
  /// Returns a new [DirectUploadControllerPullbackRequest] instance.
  DirectUploadControllerPullbackRequest({

    required  this.token,

     this.objectKeys,
  });

  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(

    name: r'objectKeys',
    required: false,
    includeIfNull: false,
  )


  final List<String>? objectKeys;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadControllerPullbackRequest &&
      other.token == token &&
      other.objectKeys == objectKeys;

    @override
    int get hashCode =>
        token.hashCode +
        objectKeys.hashCode;

  factory DirectUploadControllerPullbackRequest.fromJson(Map<String, dynamic> json) => _$DirectUploadControllerPullbackRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadControllerPullbackRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
