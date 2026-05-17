//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
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

     this.shareToken,

     this.error,
  });

  @JsonKey(
    
    name: r'isValid',
    required: true,
    includeIfNull: false,
  )


  final bool isValid;



  @JsonKey(
    
    name: r'shareToken',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? shareToken;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareTokenValidationResponseDto &&
      other.isValid == isValid &&
      other.shareToken == shareToken &&
      other.error == error;

    @override
    int get hashCode =>
        isValid.hashCode +
        shareToken.hashCode +
        error.hashCode;

  factory ShareTokenValidationResponseDto.fromJson(Map<String, dynamic> json) => _$ShareTokenValidationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ShareTokenValidationResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

