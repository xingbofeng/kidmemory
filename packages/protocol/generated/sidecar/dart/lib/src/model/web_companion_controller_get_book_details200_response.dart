//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_get_book_details200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerGetBookDetails200Response {
  /// Returns a new [WebCompanionControllerGetBookDetails200Response] instance.
  WebCompanionControllerGetBookDetails200Response({

    required  this.id,

    required  this.title,

    required  this.childId,

    required  this.createdAt,

    required  this.status,

    required  this.previewUrl,

     this.description,

     this.pageCount,
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

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



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

    name: r'pageCount',
    required: false,
    includeIfNull: false,
  )


  final num? pageCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerGetBookDetails200Response &&
      other.id == id &&
      other.title == title &&
      other.childId == childId &&
      other.createdAt == createdAt &&
      other.status == status &&
      other.previewUrl == previewUrl &&
      other.description == description &&
      other.pageCount == pageCount;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        childId.hashCode +
        createdAt.hashCode +
        status.hashCode +
        previewUrl.hashCode +
        description.hashCode +
        pageCount.hashCode;

  factory WebCompanionControllerGetBookDetails200Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerGetBookDetails200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerGetBookDetails200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
