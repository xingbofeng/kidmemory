//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_upload_file_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateUploadFileDto {
  /// Returns a new [CreateUploadFileDto] instance.
  CreateUploadFileDto({

    required  this.clientFileId,

    required  this.filename,

    required  this.contentType,

    required  this.sizeBytes,
  });

  @JsonKey(

    name: r'clientFileId',
    required: true,
    includeIfNull: false,
  )


  final String clientFileId;



  @JsonKey(

    name: r'filename',
    required: true,
    includeIfNull: false,
  )


  final String filename;



  @JsonKey(

    name: r'contentType',
    required: true,
    includeIfNull: false,
  )


  final String contentType;



  @JsonKey(

    name: r'sizeBytes',
    required: true,
    includeIfNull: false,
  )


  final num sizeBytes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateUploadFileDto &&
      other.clientFileId == clientFileId &&
      other.filename == filename &&
      other.contentType == contentType &&
      other.sizeBytes == sizeBytes;

    @override
    int get hashCode =>
        clientFileId.hashCode +
        filename.hashCode +
        contentType.hashCode +
        sizeBytes.hashCode;

  factory CreateUploadFileDto.fromJson(Map<String, dynamic> json) => _$CreateUploadFileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUploadFileDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
