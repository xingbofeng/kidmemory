//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_session_status_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanSessionStatusResponseDto {
  /// Returns a new [LanSessionStatusResponseDto] instance.
  LanSessionStatusResponseDto({

    required  this.sessionId,

    required  this.status,

    required  this.expiresAt,

    required  this.currentUploads,

    required  this.maxConcurrentUploads,

    required  this.totalUploaded,
  });

  @JsonKey(

    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(

    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final String expiresAt;



  @JsonKey(

    name: r'currentUploads',
    required: true,
    includeIfNull: false,
  )


  final int currentUploads;



  @JsonKey(

    name: r'maxConcurrentUploads',
    required: true,
    includeIfNull: false,
  )


  final int maxConcurrentUploads;



  @JsonKey(

    name: r'totalUploaded',
    required: true,
    includeIfNull: false,
  )


  final int totalUploaded;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanSessionStatusResponseDto &&
      other.sessionId == sessionId &&
      other.status == status &&
      other.expiresAt == expiresAt &&
      other.currentUploads == currentUploads &&
      other.maxConcurrentUploads == maxConcurrentUploads &&
      other.totalUploaded == totalUploaded;

    @override
    int get hashCode =>
        sessionId.hashCode +
        status.hashCode +
        expiresAt.hashCode +
        currentUploads.hashCode +
        maxConcurrentUploads.hashCode +
        totalUploaded.hashCode;

  factory LanSessionStatusResponseDto.fromJson(Map<String, dynamic> json) => _$LanSessionStatusResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanSessionStatusResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
