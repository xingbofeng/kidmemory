//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'supabase_storage_test_cleanup_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SupabaseStorageTestCleanupResponseDto {
  /// Returns a new [SupabaseStorageTestCleanupResponseDto] instance.
  SupabaseStorageTestCleanupResponseDto({

     this.ok,
  });

  @JsonKey(

    name: r'ok',
    required: false,
    includeIfNull: false,
  )


  final bool? ok;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SupabaseStorageTestCleanupResponseDto &&
      other.ok == ok;

    @override
    int get hashCode =>
        ok.hashCode;

  factory SupabaseStorageTestCleanupResponseDto.fromJson(Map<String, dynamic> json) => _$SupabaseStorageTestCleanupResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupabaseStorageTestCleanupResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
