//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_session_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateSessionResponseDto {
  /// Returns a new [CreateSessionResponseDto] instance.
  CreateSessionResponseDto({

    required  this.sessionId,

    required  this.token,

    required  this.webUrl,

    required  this.expiresAt,

    required  this.maxItems,
  });

  @JsonKey(

    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final String sessionId;



  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(

    name: r'webUrl',
    required: true,
    includeIfNull: false,
  )


  final String webUrl;



  @JsonKey(

    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final String expiresAt;



  @JsonKey(

    name: r'maxItems',
    required: true,
    includeIfNull: false,
  )


  final int maxItems;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateSessionResponseDto &&
      other.sessionId == sessionId &&
      other.token == token &&
      other.webUrl == webUrl &&
      other.expiresAt == expiresAt &&
      other.maxItems == maxItems;

    @override
    int get hashCode =>
        sessionId.hashCode +
        token.hashCode +
        webUrl.hashCode +
        expiresAt.hashCode +
        maxItems.hashCode;

  factory CreateSessionResponseDto.fromJson(Map<String, dynamic> json) => _$CreateSessionResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSessionResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
