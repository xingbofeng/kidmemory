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

    required  this.priority,

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



  @JsonKey(

    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final JobResponseDtoTypeEnum type;



  @JsonKey(

    name: r'payload',
    required: true,
    includeIfNull: true,
  )


  final Map<String, Object>? payload;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final JobResponseDtoStatusEnum status;



  @JsonKey(

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


  final String? claimedAt;



  @JsonKey(

    name: r'completedAt',
    required: false,
    includeIfNull: false,
  )


  final String? completedAt;



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


  final String createdAt;



  @JsonKey(

    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final String updatedAt;





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
        (payload == null ? 0 : payload.hashCode) +
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


enum JobResponseDtoTypeEnum {
@JsonValue(r'book_generation')
bookGeneration(r'book_generation'),
@JsonValue(r'asset_processing')
assetProcessing(r'asset_processing'),
@JsonValue(r'export_pdf')
exportPdf(r'export_pdf'),
@JsonValue(r'export_long_image')
exportLongImage(r'export_long_image'),
@JsonValue(r'import')
import_(r'import'),
@JsonValue(r'sync')
sync_(r'sync'),
@JsonValue(r'export')
export_(r'export'),
@JsonValue(r'cleanup')
cleanup(r'cleanup');

const JobResponseDtoTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum JobResponseDtoStatusEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'claimed')
claimed(r'claimed'),
@JsonValue(r'processing')
processing(r'processing'),
@JsonValue(r'completed')
completed(r'completed'),
@JsonValue(r'failed')
failed(r'failed');

const JobResponseDtoStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
