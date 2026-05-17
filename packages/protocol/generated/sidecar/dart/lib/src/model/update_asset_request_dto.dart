//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_asset_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAssetRequestDto {
  /// Returns a new [UpdateAssetRequestDto] instance.
  UpdateAssetRequestDto({

    required  this.title,

    required  this.description,

    required  this.tags,

     this.capturedAt,

    required  this.type,
  });

  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



  @JsonKey(

    name: r'tags',
    required: true,
    includeIfNull: false,
  )


  final List<String> tags;



  @JsonKey(

    name: r'capturedAt',
    required: false,
    includeIfNull: false,
  )


  final String? capturedAt;



  @JsonKey(

    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final String type;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateAssetRequestDto &&
      other.title == title &&
      other.description == description &&
      other.tags == tags &&
      other.capturedAt == capturedAt &&
      other.type == type;

    @override
    int get hashCode =>
        title.hashCode +
        description.hashCode +
        tags.hashCode +
        capturedAt.hashCode +
        type.hashCode;

  factory UpdateAssetRequestDto.fromJson(Map<String, dynamic> json) => _$UpdateAssetRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAssetRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
