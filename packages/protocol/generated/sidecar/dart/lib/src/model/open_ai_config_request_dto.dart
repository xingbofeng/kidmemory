//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'open_ai_config_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OpenAiConfigRequestDto {
  /// Returns a new [OpenAiConfigRequestDto] instance.
  OpenAiConfigRequestDto({

    required  this.baseUrl,

    required  this.model,

     this.apiKey,
  });

  @JsonKey(

    name: r'baseUrl',
    required: true,
    includeIfNull: false,
  )


  final String baseUrl;



  @JsonKey(

    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;



  @JsonKey(

    name: r'apiKey',
    required: false,
    includeIfNull: false,
  )


  final String? apiKey;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OpenAiConfigRequestDto &&
      other.baseUrl == baseUrl &&
      other.model == model &&
      other.apiKey == apiKey;

    @override
    int get hashCode =>
        baseUrl.hashCode +
        model.hashCode +
        apiKey.hashCode;

  factory OpenAiConfigRequestDto.fromJson(Map<String, dynamic> json) => _$OpenAiConfigRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiConfigRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
