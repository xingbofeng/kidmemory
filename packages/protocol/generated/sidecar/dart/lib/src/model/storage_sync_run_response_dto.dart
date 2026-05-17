//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'storage_sync_run_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StorageSyncRunResponseDto {
  /// Returns a new [StorageSyncRunResponseDto] instance.
  StorageSyncRunResponseDto({

     this.failed,

     this.retried,
  });

  @JsonKey(

    name: r'failed',
    required: false,
    includeIfNull: false,
  )


  final int? failed;



  @JsonKey(

    name: r'retried',
    required: false,
    includeIfNull: false,
  )


  final int? retried;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StorageSyncRunResponseDto &&
      other.failed == failed &&
      other.retried == retried;

    @override
    int get hashCode =>
        failed.hashCode +
        retried.hashCode;

  factory StorageSyncRunResponseDto.fromJson(Map<String, dynamic> json) => _$StorageSyncRunResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StorageSyncRunResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
