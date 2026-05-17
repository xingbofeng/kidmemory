//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reset_sample_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResetSampleResponseDto {
  /// Returns a new [ResetSampleResponseDto] instance.
  ResetSampleResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,

     this.deletedAssets,
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

    name: r'deletedAssets',
    required: false,
    includeIfNull: false,
  )


  final int? deletedAssets;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ResetSampleResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code &&
      other.deletedAssets == deletedAssets;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode +
        deletedAssets.hashCode;

  factory ResetSampleResponseDto.fromJson(Map<String, dynamic> json) => _$ResetSampleResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ResetSampleResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
