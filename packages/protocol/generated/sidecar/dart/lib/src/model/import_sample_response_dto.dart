//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_sample_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportSampleResponseDto {
  /// Returns a new [ImportSampleResponseDto] instance.
  ImportSampleResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,

     this.childId,

     this.assetCount,
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

    name: r'childId',
    required: false,
    includeIfNull: false,
  )


  final String? childId;



  @JsonKey(

    name: r'assetCount',
    required: false,
    includeIfNull: false,
  )


  final int? assetCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportSampleResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code &&
      other.childId == childId &&
      other.assetCount == assetCount;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode +
        childId.hashCode +
        assetCount.hashCode;

  factory ImportSampleResponseDto.fromJson(Map<String, dynamic> json) => _$ImportSampleResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImportSampleResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
