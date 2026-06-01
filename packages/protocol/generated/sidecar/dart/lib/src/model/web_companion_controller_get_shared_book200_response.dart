//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_get_shared_book200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerGetSharedBook200Response {
  /// Returns a new [WebCompanionControllerGetSharedBook200Response] instance.
  WebCompanionControllerGetSharedBook200Response({

    required  this.id,

    required  this.title,

    required  this.createdAt,

    required  this.status,

     this.description,

    required  this.previewUrl,

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

    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(

    name: r'previewUrl',
    required: true,
    includeIfNull: false,
  )


  final String previewUrl;



  @JsonKey(

    name: r'pageCount',
    required: false,
    includeIfNull: false,
  )


  final num? pageCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerGetSharedBook200Response &&
      other.id == id &&
      other.title == title &&
      other.createdAt == createdAt &&
      other.status == status &&
      other.description == description &&
      other.previewUrl == previewUrl &&
      other.pageCount == pageCount;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        createdAt.hashCode +
        status.hashCode +
        description.hashCode +
        previewUrl.hashCode +
        pageCount.hashCode;

  factory WebCompanionControllerGetSharedBook200Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerGetSharedBook200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerGetSharedBook200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
