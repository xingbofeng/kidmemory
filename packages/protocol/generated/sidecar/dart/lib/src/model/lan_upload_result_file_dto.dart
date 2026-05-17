//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_upload_result_file_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanUploadResultFileDto {
  /// Returns a new [LanUploadResultFileDto] instance.
  LanUploadResultFileDto({

    required  this.filename,

    required  this.assetId,

    required  this.status,

    required  this.localPath,
  });

  @JsonKey(

    name: r'filename',
    required: true,
    includeIfNull: false,
  )


  final String filename;



  @JsonKey(

    name: r'assetId',
    required: true,
    includeIfNull: false,
  )


  final String assetId;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(

    name: r'localPath',
    required: true,
    includeIfNull: false,
  )


  final String localPath;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanUploadResultFileDto &&
      other.filename == filename &&
      other.assetId == assetId &&
      other.status == status &&
      other.localPath == localPath;

    @override
    int get hashCode =>
        filename.hashCode +
        assetId.hashCode +
        status.hashCode +
        localPath.hashCode;

  factory LanUploadResultFileDto.fromJson(Map<String, dynamic> json) => _$LanUploadResultFileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanUploadResultFileDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
