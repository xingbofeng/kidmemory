//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/lan_pair_endpoints_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_pair_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanPairResponseDto {
  /// Returns a new [LanPairResponseDto] instance.
  LanPairResponseDto({

    required  this.success,

    required  this.sessionId,

    required  this.token,

    required  this.expiresAt,

    required  this.endpoints,
  });

  @JsonKey(

    name: r'success',
    required: true,
    includeIfNull: false,
  )


  final bool success;



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

    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final String expiresAt;



  @JsonKey(

    name: r'endpoints',
    required: true,
    includeIfNull: false,
  )


  final LanPairEndpointsDto endpoints;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanPairResponseDto &&
      other.success == success &&
      other.sessionId == sessionId &&
      other.token == token &&
      other.expiresAt == expiresAt &&
      other.endpoints == endpoints;

    @override
    int get hashCode =>
        success.hashCode +
        sessionId.hashCode +
        token.hashCode +
        expiresAt.hashCode +
        endpoints.hashCode;

  factory LanPairResponseDto.fromJson(Map<String, dynamic> json) => _$LanPairResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanPairResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
