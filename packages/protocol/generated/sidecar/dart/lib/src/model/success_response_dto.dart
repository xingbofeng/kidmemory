//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'success_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuccessResponseDto {
  /// Returns a new [SuccessResponseDto] instance.
  SuccessResponseDto({

    required  this.success,
  });

  @JsonKey(

    name: r'success',
    required: true,
    includeIfNull: false,
  )


  final bool success;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SuccessResponseDto &&
      other.success == success;

    @override
    int get hashCode =>
        success.hashCode;

  factory SuccessResponseDto.fromJson(Map<String, dynamic> json) => _$SuccessResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuccessResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
