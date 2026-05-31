//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/share_token_access_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'share_token_validation_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShareTokenValidationResponseDto {
  /// Returns a new [ShareTokenValidationResponseDto] instance.
  ShareTokenValidationResponseDto({

    required  this.isValid,

     this.error,

     this.shareToken,
  });

  @JsonKey(

    name: r'isValid',
    required: true,
    includeIfNull: false,
  )


  final bool isValid;



  @JsonKey(

    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(

    name: r'shareToken',
    required: false,
    includeIfNull: false,
  )


  final ShareTokenAccessDto? shareToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareTokenValidationResponseDto &&
      other.isValid == isValid &&
      other.error == error &&
      other.shareToken == shareToken;

    @override
    int get hashCode =>
        isValid.hashCode +
        error.hashCode +
        shareToken.hashCode;

  factory ShareTokenValidationResponseDto.fromJson(Map<String, dynamic> json) => _$ShareTokenValidationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ShareTokenValidationResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
