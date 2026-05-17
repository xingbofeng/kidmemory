//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/direct_upload_remote_object_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'list_direct_upload_objects_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ListDirectUploadObjectsResponseDto {
  /// Returns a new [ListDirectUploadObjectsResponseDto] instance.
  ListDirectUploadObjectsResponseDto({

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


  final List<DirectUploadRemoteObjectDto> objects;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ListDirectUploadObjectsResponseDto &&
      other.sessionId == sessionId &&
      other.bucket == bucket &&
      other.objects == objects;

    @override
    int get hashCode =>
        sessionId.hashCode +
        bucket.hashCode +
        objects.hashCode;

  factory ListDirectUploadObjectsResponseDto.fromJson(Map<String, dynamic> json) => _$ListDirectUploadObjectsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ListDirectUploadObjectsResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
