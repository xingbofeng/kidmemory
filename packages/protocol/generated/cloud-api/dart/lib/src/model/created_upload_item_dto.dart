//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'created_upload_item_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreatedUploadItemDto {
  /// Returns a new [CreatedUploadItemDto] instance.
  CreatedUploadItemDto({

    required  this.clientFileId,

    required  this.uploadItemId,

    required  this.assetId,

    required  this.objectKey,

    required  this.status,
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreatedUploadItemDto &&
      other.clientFileId == clientFileId &&
      other.uploadItemId == uploadItemId &&
      other.assetId == assetId &&
      other.objectKey == objectKey &&
      other.status == status;

    @override
    int get hashCode =>
        clientFileId.hashCode +
        uploadItemId.hashCode +
        assetId.hashCode +
        objectKey.hashCode +
        status.hashCode;

  factory CreatedUploadItemDto.fromJson(Map<String, dynamic> json) => _$CreatedUploadItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatedUploadItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

