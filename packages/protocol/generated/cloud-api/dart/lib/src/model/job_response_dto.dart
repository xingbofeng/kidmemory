//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class JobResponseDto {
  /// Returns a new [JobResponseDto] instance.
  JobResponseDto({

    required  this.id,

     this.deviceId,

    required  this.type,

    required  this.payload,

    required  this.status,

     this.priority = 0,

     this.claimedAt,

     this.completedAt,

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
    
    name: r'deviceId',
    required: false,
    includeIfNull: false,
  )


  final String? deviceId;



      /// Job type
  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final JobResponseDtoTypeEnum type;



      /// Job payload (JSON)
  @JsonKey(
    
    name: r'payload',
    required: true,
    includeIfNull: false,
  )


  final Object payload;



      /// Job status
  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final JobResponseDtoStatusEnum status;



      /// Priority (higher = more urgent)
  @JsonKey(
    defaultValue: 0,
    name: r'priority',
    required: true,
    includeIfNull: false,
  )


  final num priority;



  @JsonKey(
    
    name: r'claimedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? claimedAt;



  @JsonKey(
    
    name: r'completedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? completedAt;



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
    bool operator ==(Object other) => identical(this, other) || other is JobResponseDto &&
      other.id == id &&
      other.deviceId == deviceId &&
      other.type == type &&
      other.payload == payload &&
      other.status == status &&
      other.priority == priority &&
      other.claimedAt == claimedAt &&
      other.completedAt == completedAt &&
      other.errorMessage == errorMessage &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        deviceId.hashCode +
        type.hashCode +
        payload.hashCode +
        status.hashCode +
        priority.hashCode +
        claimedAt.hashCode +
        completedAt.hashCode +
        errorMessage.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory JobResponseDto.fromJson(Map<String, dynamic> json) => _$JobResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$JobResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Job type
enum JobResponseDtoTypeEnum {
    /// Job type
@JsonValue(r'book_generation')
bookGeneration(r'book_generation'),
    /// Job type
@JsonValue(r'asset_processing')
assetProcessing(r'asset_processing'),
    /// Job type
@JsonValue(r'export_pdf')
exportPdf(r'export_pdf'),
    /// Job type
@JsonValue(r'export_long_image')
exportLongImage(r'export_long_image');

const JobResponseDtoTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


/// Job status
enum JobResponseDtoStatusEnum {
    /// Job status
@JsonValue(r'pending')
pending(r'pending'),
    /// Job status
@JsonValue(r'claimed')
claimed(r'claimed'),
    /// Job status
@JsonValue(r'processing')
processing(r'processing'),
    /// Job status
@JsonValue(r'completed')
completed(r'completed'),
    /// Job status
@JsonValue(r'failed')
failed(r'failed');

const JobResponseDtoStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


