//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/pullback_direct_upload_item_result_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pullback_direct_upload_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullbackDirectUploadResponseDto {
  /// Returns a new [PullbackDirectUploadResponseDto] instance.
  PullbackDirectUploadResponseDto({

    required  this.sessionId,

    required  this.results,
  });

  @JsonKey(

    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'results',
    required: true,
    includeIfNull: false,
  )


  final List<PullbackDirectUploadItemResultDto> results;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullbackDirectUploadResponseDto &&
      other.sessionId == sessionId &&
      other.results == results;

    @override
    int get hashCode =>
        sessionId.hashCode +
        results.hashCode;

  factory PullbackDirectUploadResponseDto.fromJson(Map<String, dynamic> json) => _$PullbackDirectUploadResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PullbackDirectUploadResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
