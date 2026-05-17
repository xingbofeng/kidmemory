//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artifact_share_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ArtifactShareResponseDto {
  /// Returns a new [ArtifactShareResponseDto] instance.
  ArtifactShareResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,

     this.url,

     this.text,
  });

  @JsonKey(

    name: r'ok',
    required: false,
    includeIfNull: false,
  )


  final bool? ok;



  @JsonKey(

    name: r'success',
    required: false,
    includeIfNull: false,
  )


  final bool? success;



  @JsonKey(

    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;



  @JsonKey(

    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



  @JsonKey(

    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(

    name: r'text',
    required: false,
    includeIfNull: false,
  )


  final String? text;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ArtifactShareResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code &&
      other.url == url &&
      other.text == text;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode +
        url.hashCode +
        text.hashCode;

  factory ArtifactShareResponseDto.fromJson(Map<String, dynamic> json) => _$ArtifactShareResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ArtifactShareResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
