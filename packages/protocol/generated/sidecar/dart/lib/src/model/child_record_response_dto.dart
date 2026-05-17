//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'child_record_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChildRecordResponseDto {
  /// Returns a new [ChildRecordResponseDto] instance.
  ChildRecordResponseDto({

     this.id,

     this.name,
  });

  @JsonKey(

    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(

    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChildRecordResponseDto &&
      other.id == id &&
      other.name == name;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode;

  factory ChildRecordResponseDto.fromJson(Map<String, dynamic> json) => _$ChildRecordResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChildRecordResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
