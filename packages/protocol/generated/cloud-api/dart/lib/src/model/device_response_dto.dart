//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceResponseDto {
  /// Returns a new [DeviceResponseDto] instance.
  DeviceResponseDto({

    required  this.id,

    required  this.machineId,

     this.deviceName,

     this.platform,

    required  this.lastHeartbeat,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'machineId',
    required: true,
    includeIfNull: false,
  )


  final String machineId;



  @JsonKey(
    
    name: r'deviceName',
    required: false,
    includeIfNull: false,
  )


  final String? deviceName;



  @JsonKey(
    
    name: r'platform',
    required: false,
    includeIfNull: false,
  )


  final String? platform;



  @JsonKey(
    
    name: r'lastHeartbeat',
    required: true,
    includeIfNull: false,
  )


  final String lastHeartbeat;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final String createdAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final String updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeviceResponseDto &&
      other.id == id &&
      other.machineId == machineId &&
      other.deviceName == deviceName &&
      other.platform == platform &&
      other.lastHeartbeat == lastHeartbeat &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        machineId.hashCode +
        deviceName.hashCode +
        platform.hashCode +
        lastHeartbeat.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory DeviceResponseDto.fromJson(Map<String, dynamic> json) => _$DeviceResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

