//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_item_detail_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadItemDetailDto {
  /// Returns a new [UploadItemDetailDto] instance.
  UploadItemDetailDto({

    required  this.uploadItemId,

    required  this.assetId,

    required  this.filename,

    required  this.status,

    required  this.provider,

    required  this.objectKey,

     this.errorCode,

    required  this.createdAt,

    required  this.updatedAt,
  });

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

    name: r'filename',
    required: true,
    includeIfNull: false,
  )


  final String filename;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(

    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final String provider;



  @JsonKey(

    name: r'objectKey',
    required: true,
    includeIfNull: false,
  )


  final String objectKey;



  @JsonKey(

    name: r'errorCode',
    required: false,
    includeIfNull: false,
  )


  final String? errorCode;



  @JsonKey(

    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final String createdAt;



  @JsonKey(

    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final String updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UploadItemDetailDto &&
      other.uploadItemId == uploadItemId &&
      other.assetId == assetId &&
      other.filename == filename &&
      other.status == status &&
      other.provider == provider &&
      other.objectKey == objectKey &&
      other.errorCode == errorCode &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        uploadItemId.hashCode +
        assetId.hashCode +
        filename.hashCode +
        status.hashCode +
        provider.hashCode +
        objectKey.hashCode +
        errorCode.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory UploadItemDetailDto.fromJson(Map<String, dynamic> json) => _$UploadItemDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UploadItemDetailDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
