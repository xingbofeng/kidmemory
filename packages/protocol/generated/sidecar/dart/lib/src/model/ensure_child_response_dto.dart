//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/child_record_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ensure_child_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnsureChildResponseDto {
  /// Returns a new [EnsureChildResponseDto] instance.
  EnsureChildResponseDto({

     this.child,
  });

  @JsonKey(

    name: r'child',
    required: false,
    includeIfNull: false,
  )


  final ChildRecordResponseDto? child;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnsureChildResponseDto &&
      other.child == child;

    @override
    int get hashCode =>
        child.hashCode;

  factory EnsureChildResponseDto.fromJson(Map<String, dynamic> json) => _$EnsureChildResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EnsureChildResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
