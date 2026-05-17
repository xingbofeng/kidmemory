//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_agent_config_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateAgentConfigRequestDto {
  /// Returns a new [CreateAgentConfigRequestDto] instance.
  CreateAgentConfigRequestDto({

    required  this.name,

     this.description,

    required  this.provider,

    required  this.model,

    required  this.apiKey,

     this.baseUrl,

     this.temperature,

     this.maxTokens,

     this.systemPrompt,

     this.toolsEnabled,

     this.workspaceConfig,

     this.isDefault,
  });

  @JsonKey(

    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(

    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(

    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final String provider;



  @JsonKey(

    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;



  @JsonKey(

    name: r'apiKey',
    required: true,
    includeIfNull: false,
  )


  final String apiKey;



  @JsonKey(

    name: r'baseUrl',
    required: false,
    includeIfNull: false,
  )


  final String? baseUrl;



  @JsonKey(

    name: r'temperature',
    required: false,
    includeIfNull: false,
  )


  final num? temperature;



  @JsonKey(

    name: r'maxTokens',
    required: false,
    includeIfNull: false,
  )


  final int? maxTokens;



  @JsonKey(

    name: r'systemPrompt',
    required: false,
    includeIfNull: false,
  )


  final String? systemPrompt;



  @JsonKey(

    name: r'toolsEnabled',
    required: false,
    includeIfNull: false,
  )


  final List<String>? toolsEnabled;



  @JsonKey(

    name: r'workspaceConfig',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? workspaceConfig;



  @JsonKey(

    name: r'isDefault',
    required: false,
    includeIfNull: false,
  )


  final bool? isDefault;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateAgentConfigRequestDto &&
      other.name == name &&
      other.description == description &&
      other.provider == provider &&
      other.model == model &&
      other.apiKey == apiKey &&
      other.baseUrl == baseUrl &&
      other.temperature == temperature &&
      other.maxTokens == maxTokens &&
      other.systemPrompt == systemPrompt &&
      other.toolsEnabled == toolsEnabled &&
      other.workspaceConfig == workspaceConfig &&
      other.isDefault == isDefault;

    @override
    int get hashCode =>
        name.hashCode +
        description.hashCode +
        provider.hashCode +
        model.hashCode +
        apiKey.hashCode +
        baseUrl.hashCode +
        temperature.hashCode +
        maxTokens.hashCode +
        systemPrompt.hashCode +
        toolsEnabled.hashCode +
        workspaceConfig.hashCode +
        isDefault.hashCode;

  factory CreateAgentConfigRequestDto.fromJson(Map<String, dynamic> json) => _$CreateAgentConfigRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAgentConfigRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
