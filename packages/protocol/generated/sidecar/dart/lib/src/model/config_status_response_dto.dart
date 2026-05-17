//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/path_config_response_dto.dart';
import 'package:kidmemory_protocol/src/model/open_ai_config_response_dto.dart';
import 'package:kidmemory_protocol/src/model/supabase_storage_config_response_dto.dart';
import 'package:kidmemory_protocol/src/model/postgres_config_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'config_status_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfigStatusResponseDto {
  /// Returns a new [ConfigStatusResponseDto] instance.
  ConfigStatusResponseDto({

     this.postgres,

     this.openai,

     this.supabaseStorage,

     this.paths,
  });

  @JsonKey(

    name: r'postgres',
    required: false,
    includeIfNull: false,
  )


  final PostgresConfigResponseDto? postgres;



  @JsonKey(

    name: r'openai',
    required: false,
    includeIfNull: false,
  )


  final OpenAiConfigResponseDto? openai;



  @JsonKey(

    name: r'supabaseStorage',
    required: false,
    includeIfNull: false,
  )


  final SupabaseStorageConfigResponseDto? supabaseStorage;



  @JsonKey(

    name: r'paths',
    required: false,
    includeIfNull: false,
  )


  final PathConfigResponseDto? paths;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConfigStatusResponseDto &&
      other.postgres == postgres &&
      other.openai == openai &&
      other.supabaseStorage == supabaseStorage &&
      other.paths == paths;

    @override
    int get hashCode =>
        postgres.hashCode +
        openai.hashCode +
        supabaseStorage.hashCode +
        paths.hashCode;

  factory ConfigStatusResponseDto.fromJson(Map<String, dynamic> json) => _$ConfigStatusResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigStatusResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
