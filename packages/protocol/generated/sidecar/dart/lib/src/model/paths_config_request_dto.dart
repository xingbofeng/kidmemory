//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paths_config_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PathsConfigRequestDto {
  /// Returns a new [PathsConfigRequestDto] instance.
  PathsConfigRequestDto({

    required  this.dataDir,

    required  this.workspaceDir,

    required  this.exportDir,
  });

  @JsonKey(

    name: r'dataDir',
    required: true,
    includeIfNull: false,
  )


  final String dataDir;



  @JsonKey(

    name: r'workspaceDir',
    required: true,
    includeIfNull: false,
  )


  final String workspaceDir;



  @JsonKey(

    name: r'exportDir',
    required: true,
    includeIfNull: false,
  )


  final String exportDir;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PathsConfigRequestDto &&
      other.dataDir == dataDir &&
      other.workspaceDir == workspaceDir &&
      other.exportDir == exportDir;

    @override
    int get hashCode =>
        dataDir.hashCode +
        workspaceDir.hashCode +
        exportDir.hashCode;

  factory PathsConfigRequestDto.fromJson(Map<String, dynamic> json) => _$PathsConfigRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PathsConfigRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
