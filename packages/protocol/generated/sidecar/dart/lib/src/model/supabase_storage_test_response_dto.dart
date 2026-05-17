//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/supabase_storage_test_cleanup_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'supabase_storage_test_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SupabaseStorageTestResponseDto {
  /// Returns a new [SupabaseStorageTestResponseDto] instance.
  SupabaseStorageTestResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,

     this.cleanup,
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

    name: r'cleanup',
    required: false,
    includeIfNull: false,
  )


  final SupabaseStorageTestCleanupResponseDto? cleanup;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SupabaseStorageTestResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code &&
      other.cleanup == cleanup;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode +
        cleanup.hashCode;

  factory SupabaseStorageTestResponseDto.fromJson(Map<String, dynamic> json) => _$SupabaseStorageTestResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupabaseStorageTestResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
