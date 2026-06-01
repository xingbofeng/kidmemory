//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/direct_upload_controller_pullback201_response_results_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_controller_pullback201_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadControllerPullback201Response {
  /// Returns a new [DirectUploadControllerPullback201Response] instance.
  DirectUploadControllerPullback201Response({

    required  this.sessionId,

    required  this.results,
  });

  @JsonKey(

    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'results',
    required: true,
    includeIfNull: false,
  )


  final List<DirectUploadControllerPullback201ResponseResultsInner> results;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadControllerPullback201Response &&
      other.sessionId == sessionId &&
      other.results == results;

    @override
    int get hashCode =>
        sessionId.hashCode +
        results.hashCode;

  factory DirectUploadControllerPullback201Response.fromJson(Map<String, dynamic> json) => _$DirectUploadControllerPullback201ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadControllerPullback201ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
