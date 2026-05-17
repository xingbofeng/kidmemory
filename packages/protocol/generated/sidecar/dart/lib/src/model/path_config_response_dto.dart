//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'path_config_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PathConfigResponseDto {
  /// Returns a new [PathConfigResponseDto] instance.
  PathConfigResponseDto({

     this.dataDir,

     this.workspaceDir,

     this.exportDir,
  });

  @JsonKey(

    name: r'dataDir',
    required: false,
    includeIfNull: false,
  )


  final String? dataDir;



  @JsonKey(

    name: r'workspaceDir',
    required: false,
    includeIfNull: false,
  )


  final String? workspaceDir;



  @JsonKey(

    name: r'exportDir',
    required: false,
    includeIfNull: false,
  )


  final String? exportDir;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PathConfigResponseDto &&
      other.dataDir == dataDir &&
      other.workspaceDir == workspaceDir &&
      other.exportDir == exportDir;

    @override
    int get hashCode =>
        dataDir.hashCode +
        workspaceDir.hashCode +
        exportDir.hashCode;

  factory PathConfigResponseDto.fromJson(Map<String, dynamic> json) => _$PathConfigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PathConfigResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
