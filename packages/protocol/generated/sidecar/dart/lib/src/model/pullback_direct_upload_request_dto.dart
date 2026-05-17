//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pullback_direct_upload_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullbackDirectUploadRequestDto {
  /// Returns a new [PullbackDirectUploadRequestDto] instance.
  PullbackDirectUploadRequestDto({

     this.objectKeys,

     this.token,
  });

  @JsonKey(

    name: r'objectKeys',
    required: false,
    includeIfNull: false,
  )


  final List<String>? objectKeys;



  @JsonKey(

    name: r'token',
    required: false,
    includeIfNull: false,
  )


  final String? token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullbackDirectUploadRequestDto &&
      other.objectKeys == objectKeys &&
      other.token == token;

    @override
    int get hashCode =>
        objectKeys.hashCode +
        token.hashCode;

  factory PullbackDirectUploadRequestDto.fromJson(Map<String, dynamic> json) => _$PullbackDirectUploadRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PullbackDirectUploadRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
