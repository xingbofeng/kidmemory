//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/web_companion_controller_get_session_detail200_response_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_get_session_detail200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerGetSessionDetail200Response {
  /// Returns a new [WebCompanionControllerGetSessionDetail200Response] instance.
  WebCompanionControllerGetSessionDetail200Response({

    required  this.sessionId,

    required  this.items,
  });

  @JsonKey(

    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<WebCompanionControllerGetSessionDetail200ResponseItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerGetSessionDetail200Response &&
      other.sessionId == sessionId &&
      other.items == items;

    @override
    int get hashCode =>
        sessionId.hashCode +
        items.hashCode;

  factory WebCompanionControllerGetSessionDetail200Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerGetSessionDetail200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerGetSessionDetail200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
