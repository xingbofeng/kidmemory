//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_get_shared_assets200_response_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerGetSharedAssets200ResponseInner {
  /// Returns a new [WebCompanionControllerGetSharedAssets200ResponseInner] instance.
  WebCompanionControllerGetSharedAssets200ResponseInner({

    required  this.id,

    required  this.title,

    required  this.type,

    required  this.createdAt,

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

    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final String type;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerGetSharedAssets200ResponseInner &&
      other.id == id &&
      other.title == title &&
      other.type == type &&
      other.createdAt == createdAt &&
      other.previewUrl == previewUrl;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        type.hashCode +
        createdAt.hashCode +
        previewUrl.hashCode;

  factory WebCompanionControllerGetSharedAssets200ResponseInner.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerGetSharedAssets200ResponseInnerFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerGetSharedAssets200ResponseInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
