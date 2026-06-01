//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/direct_upload_controller_list_objects200_response_objects_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_controller_list_objects200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadControllerListObjects200Response {
  /// Returns a new [DirectUploadControllerListObjects200Response] instance.
  DirectUploadControllerListObjects200Response({

    required  this.sessionId,

    required  this.bucket,

    required  this.objects,
  });

  @JsonKey(

    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'bucket',
    required: true,
    includeIfNull: false,
  )


  final String bucket;



  @JsonKey(

    name: r'objects',
    required: true,
    includeIfNull: false,
  )


  final List<DirectUploadControllerListObjects200ResponseObjectsInner> objects;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadControllerListObjects200Response &&
      other.sessionId == sessionId &&
      other.bucket == bucket &&
      other.objects == objects;

    @override
    int get hashCode =>
        sessionId.hashCode +
        bucket.hashCode +
        objects.hashCode;

  factory DirectUploadControllerListObjects200Response.fromJson(Map<String, dynamic> json) => _$DirectUploadControllerListObjects200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadControllerListObjects200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
