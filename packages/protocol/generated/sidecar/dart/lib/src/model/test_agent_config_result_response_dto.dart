//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'test_agent_config_result_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TestAgentConfigResultResponseDto {
  /// Returns a new [TestAgentConfigResultResponseDto] instance.
  TestAgentConfigResultResponseDto({

    required  this.success,

     this.responseTime,

     this.errorMessage,

     this.modelUsed,

     this.tokensUsed,
  });

  @JsonKey(

    name: r'success',
    required: true,
    includeIfNull: false,
  )


  final bool success;



  @JsonKey(

    name: r'responseTime',
    required: false,
    includeIfNull: false,
  )


  final int? responseTime;



  @JsonKey(

    name: r'errorMessage',
    required: false,
    includeIfNull: false,
  )


  final String? errorMessage;



  @JsonKey(

    name: r'modelUsed',
    required: false,
    includeIfNull: false,
  )


  final String? modelUsed;



  @JsonKey(

    name: r'tokensUsed',
    required: false,
    includeIfNull: false,
  )


  final int? tokensUsed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TestAgentConfigResultResponseDto &&
      other.success == success &&
      other.responseTime == responseTime &&
      other.errorMessage == errorMessage &&
      other.modelUsed == modelUsed &&
      other.tokensUsed == tokensUsed;

    @override
    int get hashCode =>
        success.hashCode +
        responseTime.hashCode +
        errorMessage.hashCode +
        modelUsed.hashCode +
        tokensUsed.hashCode;

  factory TestAgentConfigResultResponseDto.fromJson(Map<String, dynamic> json) => _$TestAgentConfigResultResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TestAgentConfigResultResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
