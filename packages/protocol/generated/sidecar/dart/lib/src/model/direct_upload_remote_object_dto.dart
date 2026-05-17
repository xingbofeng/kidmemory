//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_remote_object_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadRemoteObjectDto {
  /// Returns a new [DirectUploadRemoteObjectDto] instance.
  DirectUploadRemoteObjectDto({

    required  this.objectKey,

    required  this.size,

    required  this.contentType,

    required  this.lastModified,
  });

  @JsonKey(

    name: r'objectKey',
    required: true,
    includeIfNull: false,
  )


  final String objectKey;



  @JsonKey(

    name: r'size',
    required: true,
    includeIfNull: false,
  )


  final int size;



  @JsonKey(

    name: r'contentType',
    required: true,
    includeIfNull: false,
  )


  final String contentType;



  @JsonKey(

    name: r'lastModified',
    required: true,
    includeIfNull: false,
  )


  final String lastModified;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadRemoteObjectDto &&
      other.objectKey == objectKey &&
      other.size == size &&
      other.contentType == contentType &&
      other.lastModified == lastModified;

    @override
    int get hashCode =>
        objectKey.hashCode +
        size.hashCode +
        contentType.hashCode +
        lastModified.hashCode;

  factory DirectUploadRemoteObjectDto.fromJson(Map<String, dynamic> json) => _$DirectUploadRemoteObjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadRemoteObjectDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
