//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_sync_status_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateSyncStatusRequestDto {
  /// Returns a new [UpdateSyncStatusRequestDto] instance.
  UpdateSyncStatusRequestDto({

    required  this.status,

     this.syncedAt,

     this.errorMessage,
  });

  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final UpdateSyncStatusRequestDtoStatusEnum status;



  @JsonKey(

    name: r'syncedAt',
    required: false,
    includeIfNull: false,
  )


  final String? syncedAt;



  @JsonKey(

    name: r'errorMessage',
    required: false,
    includeIfNull: false,
  )


  final String? errorMessage;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateSyncStatusRequestDto &&
      other.status == status &&
      other.syncedAt == syncedAt &&
      other.errorMessage == errorMessage;

    @override
    int get hashCode =>
        status.hashCode +
        syncedAt.hashCode +
        errorMessage.hashCode;

  factory UpdateSyncStatusRequestDto.fromJson(Map<String, dynamic> json) => _$UpdateSyncStatusRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSyncStatusRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UpdateSyncStatusRequestDtoStatusEnum {
@JsonValue(r'synced')
synced(r'synced'),
@JsonValue(r'failed')
failed(r'failed');

const UpdateSyncStatusRequestDtoStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
