//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
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

    required  this.id,

    required  this.sessionId,

    required  this.childId,

     this.deviceId,

    required  this.objectKey,

    required  this.fileName,

     this.fileSize,

     this.mimeType,

    required  this.status,

     this.uploadedAt,

     this.syncedAt,

     this.errorMessage,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(
    
    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(
    
    name: r'deviceId',
    required: false,
    includeIfNull: false,
  )


  final String? deviceId;



  @JsonKey(
    
    name: r'objectKey',
    required: true,
    includeIfNull: false,
  )


  final String objectKey;



  @JsonKey(
    
    name: r'fileName',
    required: true,
    includeIfNull: false,
  )


  final String fileName;



  @JsonKey(
    
    name: r'fileSize',
    required: false,
    includeIfNull: false,
  )


  final String? fileSize;



  @JsonKey(
    
    name: r'mimeType',
    required: false,
    includeIfNull: false,
  )


  final String? mimeType;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(
    
    name: r'uploadedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? uploadedAt;



  @JsonKey(
    
    name: r'syncedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? syncedAt;



  @JsonKey(
    
    name: r'errorMessage',
    required: false,
    includeIfNull: false,
  )


  final String? errorMessage;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UploadItemResponseDto &&
      other.id == id &&
      other.sessionId == sessionId &&
      other.childId == childId &&
      other.deviceId == deviceId &&
      other.objectKey == objectKey &&
      other.fileName == fileName &&
      other.fileSize == fileSize &&
      other.mimeType == mimeType &&
      other.status == status &&
      other.uploadedAt == uploadedAt &&
      other.syncedAt == syncedAt &&
      other.errorMessage == errorMessage &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        sessionId.hashCode +
        childId.hashCode +
        deviceId.hashCode +
        objectKey.hashCode +
        fileName.hashCode +
        fileSize.hashCode +
        mimeType.hashCode +
        status.hashCode +
        uploadedAt.hashCode +
        syncedAt.hashCode +
        errorMessage.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory UploadItemResponseDto.fromJson(Map<String, dynamic> json) => _$UploadItemResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UploadItemResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

