//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/supabase_storage_config_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'configure_supabase_storage_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfigureSupabaseStorageResponseDto {
  /// Returns a new [ConfigureSupabaseStorageResponseDto] instance.
  ConfigureSupabaseStorageResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,

     this.config,
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

    name: r'config',
    required: false,
    includeIfNull: false,
  )


  final SupabaseStorageConfigResponseDto? config;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConfigureSupabaseStorageResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code &&
      other.config == config;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode +
        config.hashCode;

  factory ConfigureSupabaseStorageResponseDto.fromJson(Map<String, dynamic> json) => _$ConfigureSupabaseStorageResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigureSupabaseStorageResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
