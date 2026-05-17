//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/session_summary_providers_dto.dart';
import 'package:kidmemory_protocol/src/model/session_summary_response_dto_child.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_summary_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionSummaryResponseDto {
  /// Returns a new [SessionSummaryResponseDto] instance.
  SessionSummaryResponseDto({

    required  this.sessionId,

    required  this.status,

    required  this.child,

    required  this.expiresAt,

    required  this.maxItems,

    required  this.usedItems,

    required  this.providers,
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

    name: r'child',
    required: true,
    includeIfNull: false,
  )


  final SessionSummaryResponseDtoChild child;



  @JsonKey(

    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final String expiresAt;



  @JsonKey(

    name: r'maxItems',
    required: true,
    includeIfNull: false,
  )


  final int maxItems;



  @JsonKey(

    name: r'usedItems',
    required: true,
    includeIfNull: false,
  )


  final int usedItems;



  @JsonKey(

    name: r'providers',
    required: true,
    includeIfNull: false,
  )


  final SessionSummaryProvidersDto providers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SessionSummaryResponseDto &&
      other.sessionId == sessionId &&
      other.status == status &&
      other.child == child &&
      other.expiresAt == expiresAt &&
      other.maxItems == maxItems &&
      other.usedItems == usedItems &&
      other.providers == providers;

    @override
    int get hashCode =>
        sessionId.hashCode +
        status.hashCode +
        child.hashCode +
        expiresAt.hashCode +
        maxItems.hashCode +
        usedItems.hashCode +
        providers.hashCode;

  factory SessionSummaryResponseDto.fromJson(Map<String, dynamic> json) => _$SessionSummaryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSummaryResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
