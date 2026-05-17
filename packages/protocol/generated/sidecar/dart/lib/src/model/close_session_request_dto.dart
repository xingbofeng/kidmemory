//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'close_session_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CloseSessionRequestDto {
  /// Returns a new [CloseSessionRequestDto] instance.
  CloseSessionRequestDto({

    required  this.token,
  });

  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CloseSessionRequestDto &&
      other.token == token;

    @override
    int get hashCode =>
        token.hashCode;

  factory CloseSessionRequestDto.fromJson(Map<String, dynamic> json) => _$CloseSessionRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CloseSessionRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
