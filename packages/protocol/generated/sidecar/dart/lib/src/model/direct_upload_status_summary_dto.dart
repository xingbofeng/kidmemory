//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_status_summary_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadStatusSummaryDto {
  /// Returns a new [DirectUploadStatusSummaryDto] instance.
  DirectUploadStatusSummaryDto({

    required  this.pendingRemote,

    required  this.downloading,

    required  this.ready,

    required  this.failed,
  });

  @JsonKey(

    name: r'pending_remote',
    required: true,
    includeIfNull: false,
  )


  final int pendingRemote;



  @JsonKey(

    name: r'downloading',
    required: true,
    includeIfNull: false,
  )


  final int downloading;



  @JsonKey(

    name: r'ready',
    required: true,
    includeIfNull: false,
  )


  final int ready;



  @JsonKey(

    name: r'failed',
    required: true,
    includeIfNull: false,
  )


  final int failed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadStatusSummaryDto &&
      other.pendingRemote == pendingRemote &&
      other.downloading == downloading &&
      other.ready == ready &&
      other.failed == failed;

    @override
    int get hashCode =>
        pendingRemote.hashCode +
        downloading.hashCode +
        ready.hashCode +
        failed.hashCode;

  factory DirectUploadStatusSummaryDto.fromJson(Map<String, dynamic> json) => _$DirectUploadStatusSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadStatusSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
