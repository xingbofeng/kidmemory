//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commit_upload_item_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommitUploadItemResponseDto {
  /// Returns a new [CommitUploadItemResponseDto] instance.
  CommitUploadItemResponseDto({

    required  this.uploadItemId,

    required  this.status,
  });

  @JsonKey(

    name: r'uploadItemId',
    required: true,
    includeIfNull: false,
  )


  final String uploadItemId;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommitUploadItemResponseDto &&
      other.uploadItemId == uploadItemId &&
      other.status == status;

    @override
    int get hashCode =>
        uploadItemId.hashCode +
        status.hashCode;

  factory CommitUploadItemResponseDto.fromJson(Map<String, dynamic> json) => _$CommitUploadItemResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommitUploadItemResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
