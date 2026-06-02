//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'creation_controller_create_task_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreationControllerCreateTaskRequest {
  /// Returns a new [CreationControllerCreateTaskRequest] instance.
  CreationControllerCreateTaskRequest({

    required  this.goal,

    required  this.creationType,

    required  this.assetIds,

     this.settings,
  });

  @JsonKey(

    name: r'goal',
    required: true,
    includeIfNull: false,
  )


  final String goal;



  @JsonKey(

    name: r'creationType',
    required: true,
    includeIfNull: false,
  )


  final CreationControllerCreateTaskRequestCreationTypeEnum creationType;



  @JsonKey(

    name: r'assetIds',
    required: true,
    includeIfNull: false,
  )


  final List<String> assetIds;



  @JsonKey(

    name: r'settings',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? settings;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreationControllerCreateTaskRequest &&
      other.goal == goal &&
      other.creationType == creationType &&
      other.assetIds == assetIds &&
      other.settings == settings;

    @override
    int get hashCode =>
        goal.hashCode +
        creationType.hashCode +
        assetIds.hashCode +
        settings.hashCode;

  factory CreationControllerCreateTaskRequest.fromJson(Map<String, dynamic> json) => _$CreationControllerCreateTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreationControllerCreateTaskRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CreationControllerCreateTaskRequestCreationTypeEnum {
@JsonValue(r'storybook')
storybook(r'storybook'),
@JsonValue(r'memory_book')
memoryBook(r'memory_book'),
@JsonValue(r'memoir_video')
memoirVideo(r'memoir_video');

const CreationControllerCreateTaskRequestCreationTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
