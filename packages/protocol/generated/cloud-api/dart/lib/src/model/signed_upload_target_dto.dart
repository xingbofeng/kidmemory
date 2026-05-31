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

    required  this.headers,

     this.expiresAt,
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

    name: r'headers',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> headers;



  @JsonKey(

    name: r'expiresAt',
    required: false,
    includeIfNull: false,
  )


  final String? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SignedUploadTargetDto &&
      other.method == method &&
      other.url == url &&
      other.headers == headers &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        method.hashCode +
        url.hashCode +
        headers.hashCode +
        expiresAt.hashCode;

  factory SignedUploadTargetDto.fromJson(Map<String, dynamic> json) => _$SignedUploadTargetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignedUploadTargetDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
