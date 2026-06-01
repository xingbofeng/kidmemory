//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_create_session201_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCreateSession201Response {
  /// Returns a new [WebCompanionControllerCreateSession201Response] instance.
  WebCompanionControllerCreateSession201Response({

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


  final num maxItems;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCreateSession201Response &&
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

  factory WebCompanionControllerCreateSession201Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCreateSession201ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCreateSession201ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
