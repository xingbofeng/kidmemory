//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/web_companion_controller_get_session_summary200_response_child.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_get_session_summary200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerGetSessionSummary200Response {
  /// Returns a new [WebCompanionControllerGetSessionSummary200Response] instance.
  WebCompanionControllerGetSessionSummary200Response({

    required  this.sessionId,

    required  this.status,

    required  this.child,

    required  this.expiresAt,

    required  this.maxItems,

    required  this.usedItems,

    required  this.providers,
  });

  @JsonKey(

    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(

    name: r'child',
    required: true,
    includeIfNull: false,
  )


  final WebCompanionControllerGetSessionSummary200ResponseChild child;



  @JsonKey(

    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final String expiresAt;



  @JsonKey(

    name: r'maxItems',
    required: true,
    includeIfNull: false,
  )


  final num maxItems;



  @JsonKey(

    name: r'usedItems',
    required: true,
    includeIfNull: false,
  )


  final num usedItems;



  @JsonKey(

    name: r'providers',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> providers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerGetSessionSummary200Response &&
      other.sessionId == sessionId &&
      other.status == status &&
      other.child == child &&
      other.expiresAt == expiresAt &&
      other.maxItems == maxItems &&
      other.usedItems == usedItems &&
      other.providers == providers;

    @override
    int get hashCode =>
        sessionId.hashCode +
        status.hashCode +
        child.hashCode +
        expiresAt.hashCode +
        maxItems.hashCode +
        usedItems.hashCode +
        providers.hashCode;

  factory WebCompanionControllerGetSessionSummary200Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerGetSessionSummary200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerGetSessionSummary200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
