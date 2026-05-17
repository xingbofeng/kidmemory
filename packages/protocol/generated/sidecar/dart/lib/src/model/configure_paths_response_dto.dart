//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/path_config_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'configure_paths_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfigurePathsResponseDto {
  /// Returns a new [ConfigurePathsResponseDto] instance.
  ConfigurePathsResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,

     this.paths,
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

    name: r'paths',
    required: false,
    includeIfNull: false,
  )


  final PathConfigResponseDto? paths;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConfigurePathsResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code &&
      other.paths == paths;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode +
        paths.hashCode;

  factory ConfigurePathsResponseDto.fromJson(Map<String, dynamic> json) => _$ConfigurePathsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigurePathsResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
