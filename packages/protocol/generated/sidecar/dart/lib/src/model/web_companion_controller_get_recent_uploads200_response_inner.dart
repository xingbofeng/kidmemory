//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_get_recent_uploads200_response_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerGetRecentUploads200ResponseInner {
  /// Returns a new [WebCompanionControllerGetRecentUploads200ResponseInner] instance.
  WebCompanionControllerGetRecentUploads200ResponseInner({

    required  this.id,

    required  this.title,

    required  this.type,

    required  this.childId,

    required  this.createdAt,

    required  this.previewUrl,

     this.description,

    required  this.tags,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final String type;



  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(

    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final String createdAt;



  @JsonKey(

    name: r'previewUrl',
    required: true,
    includeIfNull: false,
  )


  final String previewUrl;



  @JsonKey(

    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(

    name: r'tags',
    required: true,
    includeIfNull: false,
  )


  final List<String> tags;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerGetRecentUploads200ResponseInner &&
      other.id == id &&
      other.title == title &&
      other.type == type &&
      other.childId == childId &&
      other.createdAt == createdAt &&
      other.previewUrl == previewUrl &&
      other.description == description &&
      other.tags == tags;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        type.hashCode +
        childId.hashCode +
        createdAt.hashCode +
        previewUrl.hashCode +
        description.hashCode +
        tags.hashCode;

  factory WebCompanionControllerGetRecentUploads200ResponseInner.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerGetRecentUploads200ResponseInnerFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerGetRecentUploads200ResponseInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
