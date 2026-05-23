//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_job_status_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateJobStatusRequestDto {
  /// Returns a new [UpdateJobStatusRequestDto] instance.
  UpdateJobStatusRequestDto({

    required  this.status,

     this.claimedAt,

     this.completedAt,

     this.errorMessage,
  });

  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final UpdateJobStatusRequestDtoStatusEnum status;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateJobStatusRequestDto &&
      other.status == status &&
      other.claimedAt == claimedAt &&
      other.completedAt == completedAt &&
      other.errorMessage == errorMessage;

    @override
    int get hashCode =>
        status.hashCode +
        claimedAt.hashCode +
        completedAt.hashCode +
        errorMessage.hashCode;

  factory UpdateJobStatusRequestDto.fromJson(Map<String, dynamic> json) => _$UpdateJobStatusRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateJobStatusRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UpdateJobStatusRequestDtoStatusEnum {
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

const UpdateJobStatusRequestDtoStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
