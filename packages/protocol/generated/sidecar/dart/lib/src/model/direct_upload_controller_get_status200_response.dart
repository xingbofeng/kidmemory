//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/direct_upload_controller_get_status200_response_items_inner.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_get_status200_response_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_controller_get_status200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadControllerGetStatus200Response {
  /// Returns a new [DirectUploadControllerGetStatus200Response] instance.
  DirectUploadControllerGetStatus200Response({

    required  this.sessionId,

    required  this.items,

    required  this.summary,
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


  final List<DirectUploadControllerGetStatus200ResponseItemsInner> items;



  @JsonKey(

    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final DirectUploadControllerGetStatus200ResponseSummary summary;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadControllerGetStatus200Response &&
      other.sessionId == sessionId &&
      other.items == items &&
      other.summary == summary;

    @override
    int get hashCode =>
        sessionId.hashCode +
        items.hashCode +
        summary.hashCode;

  factory DirectUploadControllerGetStatus200Response.fromJson(Map<String, dynamic> json) => _$DirectUploadControllerGetStatus200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadControllerGetStatus200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
