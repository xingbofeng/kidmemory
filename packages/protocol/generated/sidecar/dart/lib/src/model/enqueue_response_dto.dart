//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enqueue_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnqueueResponseDto {
  /// Returns a new [EnqueueResponseDto] instance.
  EnqueueResponseDto({

     this.enqueued,

     this.reason,
  });

  @JsonKey(

    name: r'enqueued',
    required: false,
    includeIfNull: false,
  )


  final bool? enqueued;



  @JsonKey(

    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnqueueResponseDto &&
      other.enqueued == enqueued &&
      other.reason == reason;

    @override
    int get hashCode =>
        enqueued.hashCode +
        reason.hashCode;

  factory EnqueueResponseDto.fromJson(Map<String, dynamic> json) => _$EnqueueResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EnqueueResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
