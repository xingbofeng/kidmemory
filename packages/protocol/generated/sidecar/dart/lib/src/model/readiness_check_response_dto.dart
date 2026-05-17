//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'readiness_check_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReadinessCheckResponseDto {
  /// Returns a new [ReadinessCheckResponseDto] instance.
  ReadinessCheckResponseDto({

     this.ok,

     this.ready,

     this.blocksGeneration,

     this.service,

     this.message,
  });

  @JsonKey(

    name: r'ok',
    required: false,
    includeIfNull: false,
  )


  final bool? ok;



  @JsonKey(

    name: r'ready',
    required: false,
    includeIfNull: false,
  )


  final bool? ready;



  @JsonKey(

    name: r'blocksGeneration',
    required: false,
    includeIfNull: false,
  )


  final bool? blocksGeneration;



  @JsonKey(

    name: r'service',
    required: false,
    includeIfNull: false,
  )


  final String? service;



  @JsonKey(

    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReadinessCheckResponseDto &&
      other.ok == ok &&
      other.ready == ready &&
      other.blocksGeneration == blocksGeneration &&
      other.service == service &&
      other.message == message;

    @override
    int get hashCode =>
        ok.hashCode +
        ready.hashCode +
        blocksGeneration.hashCode +
        service.hashCode +
        message.hashCode;

  factory ReadinessCheckResponseDto.fromJson(Map<String, dynamic> json) => _$ReadinessCheckResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReadinessCheckResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
