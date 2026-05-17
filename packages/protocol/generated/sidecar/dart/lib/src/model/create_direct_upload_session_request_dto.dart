//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_direct_upload_session_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDirectUploadSessionRequestDto {
  /// Returns a new [CreateDirectUploadSessionRequestDto] instance.
  CreateDirectUploadSessionRequestDto({

    required  this.childId,
  });

  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateDirectUploadSessionRequestDto &&
      other.childId == childId;

    @override
    int get hashCode =>
        childId.hashCode;

  factory CreateDirectUploadSessionRequestDto.fromJson(Map<String, dynamic> json) => _$CreateDirectUploadSessionRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDirectUploadSessionRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
