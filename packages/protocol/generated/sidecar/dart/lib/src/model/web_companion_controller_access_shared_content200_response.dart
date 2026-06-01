//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/web_companion_controller_access_shared_content200_response_share_token.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_access_shared_content200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerAccessSharedContent200Response {
  /// Returns a new [WebCompanionControllerAccessSharedContent200Response] instance.
  WebCompanionControllerAccessSharedContent200Response({

    required  this.isValid,

     this.error,

     this.shareToken,
  });

  @JsonKey(

    name: r'isValid',
    required: true,
    includeIfNull: false,
  )


  final bool isValid;



  @JsonKey(

    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(

    name: r'shareToken',
    required: false,
    includeIfNull: false,
  )


  final WebCompanionControllerAccessSharedContent200ResponseShareToken? shareToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerAccessSharedContent200Response &&
      other.isValid == isValid &&
      other.error == error &&
      other.shareToken == shareToken;

    @override
    int get hashCode =>
        isValid.hashCode +
        error.hashCode +
        shareToken.hashCode;

  factory WebCompanionControllerAccessSharedContent200Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerAccessSharedContent200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerAccessSharedContent200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
