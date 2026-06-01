//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_get_books_list200_response_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerGetBooksList200ResponseInner {
  /// Returns a new [WebCompanionControllerGetBooksList200ResponseInner] instance.
  WebCompanionControllerGetBooksList200ResponseInner({

    required  this.id,

    required  this.title,

    required  this.childId,

    required  this.createdAt,

    required  this.status,

    required  this.previewUrl,
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerGetBooksList200ResponseInner &&
      other.id == id &&
      other.title == title &&
      other.childId == childId &&
      other.createdAt == createdAt &&
      other.status == status &&
      other.previewUrl == previewUrl;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        childId.hashCode +
        createdAt.hashCode +
        status.hashCode +
        previewUrl.hashCode;

  factory WebCompanionControllerGetBooksList200ResponseInner.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerGetBooksList200ResponseInnerFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerGetBooksList200ResponseInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
