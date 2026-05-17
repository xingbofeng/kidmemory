//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_session_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateSessionRequestDto {
  /// Returns a new [CreateSessionRequestDto] instance.
  CreateSessionRequestDto({

    required  this.childId,

     this.expiresInMinutes,

     this.maxItems,

     this.preferredProviders,
  });

  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(

    name: r'expiresInMinutes',
    required: false,
    includeIfNull: false,
  )


  final int? expiresInMinutes;



  @JsonKey(

    name: r'maxItems',
    required: false,
    includeIfNull: false,
  )


  final int? maxItems;



  @JsonKey(

    name: r'preferredProviders',
    required: false,
    includeIfNull: false,
  )


  final List<String>? preferredProviders;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateSessionRequestDto &&
      other.childId == childId &&
      other.expiresInMinutes == expiresInMinutes &&
      other.maxItems == maxItems &&
      other.preferredProviders == preferredProviders;

    @override
    int get hashCode =>
        childId.hashCode +
        expiresInMinutes.hashCode +
        maxItems.hashCode +
        preferredProviders.hashCode;

  factory CreateSessionRequestDto.fromJson(Map<String, dynamic> json) => _$CreateSessionRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSessionRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
