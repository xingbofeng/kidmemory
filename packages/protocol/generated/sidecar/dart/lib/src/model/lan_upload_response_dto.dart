//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/lan_upload_error_dto.dart';
import 'package:kidmemory_protocol/src/model/lan_upload_result_file_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_upload_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanUploadResponseDto {
  /// Returns a new [LanUploadResponseDto] instance.
  LanUploadResponseDto({

    required  this.success,

    required  this.uploadedFiles,

    required  this.errors,
  });

  @JsonKey(

    name: r'success',
    required: true,
    includeIfNull: false,
  )


  final bool success;



  @JsonKey(

    name: r'uploadedFiles',
    required: true,
    includeIfNull: false,
  )


  final List<LanUploadResultFileDto> uploadedFiles;



  @JsonKey(

    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final List<LanUploadErrorDto> errors;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanUploadResponseDto &&
      other.success == success &&
      other.uploadedFiles == uploadedFiles &&
      other.errors == errors;

    @override
    int get hashCode =>
        success.hashCode +
        uploadedFiles.hashCode +
        errors.hashCode;

  factory LanUploadResponseDto.fromJson(Map<String, dynamic> json) => _$LanUploadResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanUploadResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
