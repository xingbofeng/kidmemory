//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'agent_config_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AgentConfigResponseDto {
  /// Returns a new [AgentConfigResponseDto] instance.
  AgentConfigResponseDto({

    required  this.id,

    required  this.name,

     this.description,

    required  this.provider,

    required  this.model,

     this.baseUrl,

    required  this.apiKeyConfigured,

    required  this.temperature,

    required  this.maxTokens,

     this.systemPrompt,

    required  this.toolsEnabled,

    required  this.workspaceConfig,

    required  this.isDefault,

    required  this.isActive,

     this.lastTestedAt,

     this.testResult,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



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

    name: r'baseUrl',
    required: false,
    includeIfNull: false,
  )


  final String? baseUrl;



  @JsonKey(

    name: r'apiKeyConfigured',
    required: true,
    includeIfNull: false,
  )


  final bool apiKeyConfigured;



  @JsonKey(

    name: r'temperature',
    required: true,
    includeIfNull: false,
  )


  final num temperature;



  @JsonKey(

    name: r'maxTokens',
    required: true,
    includeIfNull: false,
  )


  final int maxTokens;



  @JsonKey(

    name: r'systemPrompt',
    required: false,
    includeIfNull: false,
  )


  final String? systemPrompt;



  @JsonKey(

    name: r'toolsEnabled',
    required: true,
    includeIfNull: false,
  )


  final List<String> toolsEnabled;



  @JsonKey(

    name: r'workspaceConfig',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> workspaceConfig;



  @JsonKey(

    name: r'isDefault',
    required: true,
    includeIfNull: false,
  )


  final bool isDefault;



  @JsonKey(

    name: r'isActive',
    required: true,
    includeIfNull: false,
  )


  final bool isActive;



  @JsonKey(

    name: r'lastTestedAt',
    required: false,
    includeIfNull: false,
  )


  final String? lastTestedAt;



  @JsonKey(

    name: r'testResult',
    required: false,
    includeIfNull: false,
  )


  final String? testResult;



  @JsonKey(

    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final String createdAt;



  @JsonKey(

    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final String updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AgentConfigResponseDto &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.provider == provider &&
      other.model == model &&
      other.baseUrl == baseUrl &&
      other.apiKeyConfigured == apiKeyConfigured &&
      other.temperature == temperature &&
      other.maxTokens == maxTokens &&
      other.systemPrompt == systemPrompt &&
      other.toolsEnabled == toolsEnabled &&
      other.workspaceConfig == workspaceConfig &&
      other.isDefault == isDefault &&
      other.isActive == isActive &&
      other.lastTestedAt == lastTestedAt &&
      other.testResult == testResult &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        description.hashCode +
        provider.hashCode +
        model.hashCode +
        baseUrl.hashCode +
        apiKeyConfigured.hashCode +
        temperature.hashCode +
        maxTokens.hashCode +
        systemPrompt.hashCode +
        toolsEnabled.hashCode +
        workspaceConfig.hashCode +
        isDefault.hashCode +
        isActive.hashCode +
        lastTestedAt.hashCode +
        testResult.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory AgentConfigResponseDto.fromJson(Map<String, dynamic> json) => _$AgentConfigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AgentConfigResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
