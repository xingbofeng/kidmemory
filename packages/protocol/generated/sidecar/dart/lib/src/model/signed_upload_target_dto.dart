//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'signed_upload_target_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SignedUploadTargetDto {
  /// Returns a new [SignedUploadTargetDto] instance.
  SignedUploadTargetDto({

    required  this.method,

    required  this.url,

    required  this.expiresAt,

    required  this.headers,
  });

  @JsonKey(

    name: r'method',
    required: true,
    includeIfNull: false,
  )


  final String method;



  @JsonKey(

    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(

    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final String expiresAt;



  @JsonKey(

    name: r'headers',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> headers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SignedUploadTargetDto &&
      other.method == method &&
      other.url == url &&
      other.expiresAt == expiresAt &&
      other.headers == headers;

    @override
    int get hashCode =>
        method.hashCode +
        url.hashCode +
        expiresAt.hashCode +
        headers.hashCode;

  factory SignedUploadTargetDto.fromJson(Map<String, dynamic> json) => _$SignedUploadTargetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignedUploadTargetDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
