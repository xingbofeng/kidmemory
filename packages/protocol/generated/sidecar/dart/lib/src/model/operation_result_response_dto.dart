//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'operation_result_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OperationResultResponseDto {
  /// Returns a new [OperationResultResponseDto] instance.
  OperationResultResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,
  });

  @JsonKey(

    name: r'ok',
    required: false,
    includeIfNull: false,
  )


  final bool? ok;



  @JsonKey(

    name: r'success',
    required: false,
    includeIfNull: false,
  )


  final bool? success;



  @JsonKey(

    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;



  @JsonKey(

    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OperationResultResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode;

  factory OperationResultResponseDto.fromJson(Map<String, dynamic> json) => _$OperationResultResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OperationResultResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
