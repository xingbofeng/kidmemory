//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artifact_ref_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ArtifactRefResponseDto {
  /// Returns a new [ArtifactRefResponseDto] instance.
  ArtifactRefResponseDto({

     this.id,
  });

  @JsonKey(

    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ArtifactRefResponseDto &&
      other.id == id;

    @override
    int get hashCode =>
        id.hashCode;

  factory ArtifactRefResponseDto.fromJson(Map<String, dynamic> json) => _$ArtifactRefResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ArtifactRefResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
