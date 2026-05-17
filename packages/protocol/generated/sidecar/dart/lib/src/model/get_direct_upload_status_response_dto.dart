//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/direct_upload_status_summary_dto.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_status_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_direct_upload_status_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GetDirectUploadStatusResponseDto {
  /// Returns a new [GetDirectUploadStatusResponseDto] instance.
  GetDirectUploadStatusResponseDto({

    required  this.sessionId,

    required  this.items,

    required  this.summary,
  });

  @JsonKey(

    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<DirectUploadStatusItemDto> items;



  @JsonKey(

    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final DirectUploadStatusSummaryDto summary;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GetDirectUploadStatusResponseDto &&
      other.sessionId == sessionId &&
      other.items == items &&
      other.summary == summary;

    @override
    int get hashCode =>
        sessionId.hashCode +
        items.hashCode +
        summary.hashCode;

  factory GetDirectUploadStatusResponseDto.fromJson(Map<String, dynamic> json) => _$GetDirectUploadStatusResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetDirectUploadStatusResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
