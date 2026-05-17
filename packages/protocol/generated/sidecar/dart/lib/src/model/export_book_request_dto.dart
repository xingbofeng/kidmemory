//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'export_book_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExportBookRequestDto {
  /// Returns a new [ExportBookRequestDto] instance.
  ExportBookRequestDto({

    required  this.targetPath,
  });

  @JsonKey(

    name: r'targetPath',
    required: true,
    includeIfNull: false,
  )


  final String targetPath;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ExportBookRequestDto &&
      other.targetPath == targetPath;

    @override
    int get hashCode =>
        targetPath.hashCode;

  factory ExportBookRequestDto.fromJson(Map<String, dynamic> json) => _$ExportBookRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExportBookRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
