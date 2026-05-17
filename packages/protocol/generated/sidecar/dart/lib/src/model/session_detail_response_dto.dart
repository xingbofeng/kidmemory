//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/upload_item_detail_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_detail_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionDetailResponseDto {
  /// Returns a new [SessionDetailResponseDto] instance.
  SessionDetailResponseDto({

    required  this.sessionId,

    required  this.items,
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


  final List<UploadItemDetailDto> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SessionDetailResponseDto &&
      other.sessionId == sessionId &&
      other.items == items;

    @override
    int get hashCode =>
        sessionId.hashCode +
        items.hashCode;

  factory SessionDetailResponseDto.fromJson(Map<String, dynamic> json) => _$SessionDetailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SessionDetailResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
