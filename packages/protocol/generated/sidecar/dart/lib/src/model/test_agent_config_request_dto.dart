//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'test_agent_config_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TestAgentConfigRequestDto {
  /// Returns a new [TestAgentConfigRequestDto] instance.
  TestAgentConfigRequestDto({

     this.testPrompt,
  });

  @JsonKey(

    name: r'testPrompt',
    required: false,
    includeIfNull: false,
  )


  final String? testPrompt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TestAgentConfigRequestDto &&
      other.testPrompt == testPrompt;

    @override
    int get hashCode =>
        testPrompt.hashCode;

  factory TestAgentConfigRequestDto.fromJson(Map<String, dynamic> json) => _$TestAgentConfigRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TestAgentConfigRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
