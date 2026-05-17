//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/exported_payload_response_dto.dart';
import 'package:kidmemory_protocol/src/model/artifact_ref_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_export_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BookExportResponseDto {
  /// Returns a new [BookExportResponseDto] instance.
  BookExportResponseDto({

     this.exported,

     this.artifact,
  });

  @JsonKey(

    name: r'exported',
    required: false,
    includeIfNull: false,
  )


  final ExportedPayloadResponseDto? exported;



  @JsonKey(

    name: r'artifact',
    required: false,
    includeIfNull: false,
  )


  final ArtifactRefResponseDto? artifact;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BookExportResponseDto &&
      other.exported == exported &&
      other.artifact == artifact;

    @override
    int get hashCode =>
        exported.hashCode +
        artifact.hashCode;

  factory BookExportResponseDto.fromJson(Map<String, dynamic> json) => _$BookExportResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookExportResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
