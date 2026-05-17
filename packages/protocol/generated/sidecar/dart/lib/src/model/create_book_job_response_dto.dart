//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_book_job_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateBookJobResponseDto {
  /// Returns a new [CreateBookJobResponseDto] instance.
  CreateBookJobResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,

     this.id,

     this.status,
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



  @JsonKey(

    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(

    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateBookJobResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code &&
      other.id == id &&
      other.status == status;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode +
        id.hashCode +
        status.hashCode;

  factory CreateBookJobResponseDto.fromJson(Map<String, dynamic> json) => _$CreateBookJobResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookJobResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
