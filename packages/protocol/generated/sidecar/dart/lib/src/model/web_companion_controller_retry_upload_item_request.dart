//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_retry_upload_item_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerRetryUploadItemRequest {
  /// Returns a new [WebCompanionControllerRetryUploadItemRequest] instance.
  WebCompanionControllerRetryUploadItemRequest({

    required  this.token,
  });

  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerRetryUploadItemRequest &&
      other.token == token;

    @override
    int get hashCode =>
        token.hashCode;

  factory WebCompanionControllerRetryUploadItemRequest.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerRetryUploadItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerRetryUploadItemRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
