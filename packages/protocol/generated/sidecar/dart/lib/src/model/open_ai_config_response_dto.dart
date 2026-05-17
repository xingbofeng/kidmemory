//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'open_ai_config_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OpenAiConfigResponseDto {
  /// Returns a new [OpenAiConfigResponseDto] instance.
  OpenAiConfigResponseDto({

     this.baseUrl,

     this.model,

     this.apiKeyConfigured,
  });

  @JsonKey(

    name: r'baseUrl',
    required: false,
    includeIfNull: false,
  )


  final String? baseUrl;



  @JsonKey(

    name: r'model',
    required: false,
    includeIfNull: false,
  )


  final String? model;



  @JsonKey(

    name: r'apiKeyConfigured',
    required: false,
    includeIfNull: false,
  )


  final bool? apiKeyConfigured;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OpenAiConfigResponseDto &&
      other.baseUrl == baseUrl &&
      other.model == model &&
      other.apiKeyConfigured == apiKeyConfigured;

    @override
    int get hashCode =>
        baseUrl.hashCode +
        model.hashCode +
        apiKeyConfigured.hashCode;

  factory OpenAiConfigResponseDto.fromJson(Map<String, dynamic> json) => _$OpenAiConfigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiConfigResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
