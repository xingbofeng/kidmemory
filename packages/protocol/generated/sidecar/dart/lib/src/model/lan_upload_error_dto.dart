//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_upload_error_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanUploadErrorDto {
  /// Returns a new [LanUploadErrorDto] instance.
  LanUploadErrorDto({

    required  this.filename,

    required  this.errorCode,

    required  this.message,
  });

  @JsonKey(

    name: r'filename',
    required: true,
    includeIfNull: false,
  )


  final String filename;



  @JsonKey(

    name: r'errorCode',
    required: true,
    includeIfNull: false,
  )


  final String errorCode;



  @JsonKey(

    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanUploadErrorDto &&
      other.filename == filename &&
      other.errorCode == errorCode &&
      other.message == message;

    @override
    int get hashCode =>
        filename.hashCode +
        errorCode.hashCode +
        message.hashCode;

  factory LanUploadErrorDto.fromJson(Map<String, dynamic> json) => _$LanUploadErrorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanUploadErrorDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
