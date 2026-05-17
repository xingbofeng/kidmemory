//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/signed_upload_target_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_item_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadItemResponseDto {
  /// Returns a new [UploadItemResponseDto] instance.
  UploadItemResponseDto({

    required  this.clientFileId,

    required  this.uploadItemId,

    required  this.assetId,

    required  this.objectKey,

    required  this.status,

     this.signedUpload,
  });

  @JsonKey(

    name: r'clientFileId',
    required: true,
    includeIfNull: false,
  )


  final String clientFileId;



  @JsonKey(

    name: r'uploadItemId',
    required: true,
    includeIfNull: false,
  )


  final String uploadItemId;



  @JsonKey(

    name: r'assetId',
    required: true,
    includeIfNull: false,
  )


  final String assetId;



  @JsonKey(

    name: r'objectKey',
    required: true,
    includeIfNull: false,
  )


  final String objectKey;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(

    name: r'signedUpload',
    required: false,
    includeIfNull: false,
  )


  final SignedUploadTargetDto? signedUpload;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UploadItemResponseDto &&
      other.clientFileId == clientFileId &&
      other.uploadItemId == uploadItemId &&
      other.assetId == assetId &&
      other.objectKey == objectKey &&
      other.status == status &&
      other.signedUpload == signedUpload;

    @override
    int get hashCode =>
        clientFileId.hashCode +
        uploadItemId.hashCode +
        assetId.hashCode +
        objectKey.hashCode +
        status.hashCode +
        signedUpload.hashCode;

  factory UploadItemResponseDto.fromJson(Map<String, dynamic> json) => _$UploadItemResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UploadItemResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
