//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pullback_direct_upload_item_result_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullbackDirectUploadItemResultDto {
  /// Returns a new [PullbackDirectUploadItemResultDto] instance.
  PullbackDirectUploadItemResultDto({

    required  this.objectKey,

    required  this.status,

     this.errorCode,

     this.errorMessage,
  });

  @JsonKey(

    name: r'objectKey',
    required: true,
    includeIfNull: false,
  )


  final String objectKey;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(

    name: r'errorCode',
    required: false,
    includeIfNull: false,
  )


  final String? errorCode;



  @JsonKey(

    name: r'errorMessage',
    required: false,
    includeIfNull: false,
  )


  final String? errorMessage;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullbackDirectUploadItemResultDto &&
      other.objectKey == objectKey &&
      other.status == status &&
      other.errorCode == errorCode &&
      other.errorMessage == errorMessage;

    @override
    int get hashCode =>
        objectKey.hashCode +
        status.hashCode +
        (errorCode == null ? 0 : errorCode.hashCode) +
        (errorMessage == null ? 0 : errorMessage.hashCode);

  factory PullbackDirectUploadItemResultDto.fromJson(Map<String, dynamic> json) => _$PullbackDirectUploadItemResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PullbackDirectUploadItemResultDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
