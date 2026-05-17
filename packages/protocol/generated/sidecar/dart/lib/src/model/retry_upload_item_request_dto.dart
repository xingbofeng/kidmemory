//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'retry_upload_item_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RetryUploadItemRequestDto {
  /// Returns a new [RetryUploadItemRequestDto] instance.
  RetryUploadItemRequestDto({

    required  this.token,
  });

  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RetryUploadItemRequestDto &&
      other.token == token;

    @override
    int get hashCode =>
        token.hashCode;

  factory RetryUploadItemRequestDto.fromJson(Map<String, dynamic> json) => _$RetryUploadItemRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RetryUploadItemRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
