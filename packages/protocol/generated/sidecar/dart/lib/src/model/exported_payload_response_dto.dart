//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exported_payload_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExportedPayloadResponseDto {
  /// Returns a new [ExportedPayloadResponseDto] instance.
  ExportedPayloadResponseDto({

     this.ok,

     this.path,

     this.message,
  });

  @JsonKey(

    name: r'ok',
    required: false,
    includeIfNull: false,
  )


  final bool? ok;



  @JsonKey(

    name: r'path',
    required: false,
    includeIfNull: false,
  )


  final String? path;



  @JsonKey(

    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ExportedPayloadResponseDto &&
      other.ok == ok &&
      other.path == path &&
      other.message == message;

    @override
    int get hashCode =>
        ok.hashCode +
        path.hashCode +
        message.hashCode;

  factory ExportedPayloadResponseDto.fromJson(Map<String, dynamic> json) => _$ExportedPayloadResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExportedPayloadResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
