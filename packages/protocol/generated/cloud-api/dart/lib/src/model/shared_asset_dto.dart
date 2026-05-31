//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shared_asset_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SharedAssetDto {
  /// Returns a new [SharedAssetDto] instance.
  SharedAssetDto({

    required  this.id,

    required  this.title,

    required  this.type,

    required  this.createdAt,
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is SharedAssetDto &&
      other.id == id &&
      other.title == title &&
      other.type == type &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        type.hashCode +
        createdAt.hashCode;

  factory SharedAssetDto.fromJson(Map<String, dynamic> json) => _$SharedAssetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SharedAssetDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
