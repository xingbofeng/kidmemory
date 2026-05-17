//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'export_long_image_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExportLongImageRequestDto {
  /// Returns a new [ExportLongImageRequestDto] instance.
  ExportLongImageRequestDto({

    required  this.targetPath,

    required  this.format,
  });

  @JsonKey(

    name: r'targetPath',
    required: true,
    includeIfNull: false,
  )


  final String targetPath;



  @JsonKey(

    name: r'format',
    required: true,
    includeIfNull: false,
  )


  final String format;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ExportLongImageRequestDto &&
      other.targetPath == targetPath &&
      other.format == format;

    @override
    int get hashCode =>
        targetPath.hashCode +
        format.hashCode;

  factory ExportLongImageRequestDto.fromJson(Map<String, dynamic> json) => _$ExportLongImageRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExportLongImageRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
