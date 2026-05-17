//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_agent_config_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAgentConfigRequestDto {
  /// Returns a new [UpdateAgentConfigRequestDto] instance.
  UpdateAgentConfigRequestDto({

     this.name,

     this.description,

     this.provider,

     this.model,

     this.apiKey,

     this.baseUrl,

     this.temperature,

     this.maxTokens,

     this.systemPrompt,

     this.toolsEnabled,

     this.workspaceConfig,

     this.isActive,
  });

  @JsonKey(

    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(

    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(

    name: r'provider',
    required: false,
    includeIfNull: false,
  )


  final String? provider;



  @JsonKey(

    name: r'model',
    required: false,
    includeIfNull: false,
  )


  final String? model;



  @JsonKey(

    name: r'apiKey',
    required: false,
    includeIfNull: false,
  )


  final String? apiKey;



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

    name: r'isActive',
    required: false,
    includeIfNull: false,
  )


  final bool? isActive;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateAgentConfigRequestDto &&
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
      other.isActive == isActive;

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
        isActive.hashCode;

  factory UpdateAgentConfigRequestDto.fromJson(Map<String, dynamic> json) => _$UpdateAgentConfigRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAgentConfigRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
