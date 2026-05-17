//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_assets_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportAssetsRequestDto {
  /// Returns a new [ImportAssetsRequestDto] instance.
  ImportAssetsRequestDto({

    required  this.childId,

    required  this.paths,

     this.recursive,
  });

  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(

    name: r'paths',
    required: true,
    includeIfNull: false,
  )


  final List<String> paths;



  @JsonKey(

    name: r'recursive',
    required: false,
    includeIfNull: false,
  )


  final bool? recursive;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportAssetsRequestDto &&
      other.childId == childId &&
      other.paths == paths &&
      other.recursive == recursive;

    @override
    int get hashCode =>
        childId.hashCode +
        paths.hashCode +
        recursive.hashCode;

  factory ImportAssetsRequestDto.fromJson(Map<String, dynamic> json) => _$ImportAssetsRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImportAssetsRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
