//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/child_record_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'children_list_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChildrenListResponseDto {
  /// Returns a new [ChildrenListResponseDto] instance.
  ChildrenListResponseDto({

     this.children,
  });

  @JsonKey(

    name: r'children',
    required: false,
    includeIfNull: false,
  )


  final List<ChildRecordResponseDto>? children;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChildrenListResponseDto &&
      other.children == children;

    @override
    int get hashCode =>
        children.hashCode;

  factory ChildrenListResponseDto.fromJson(Map<String, dynamic> json) => _$ChildrenListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChildrenListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
