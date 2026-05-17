//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_device_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterDeviceRequestDto {
  /// Returns a new [RegisterDeviceRequestDto] instance.
  RegisterDeviceRequestDto({

    required  this.machineId,

     this.deviceName,

     this.platform,
  });

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


  final RegisterDeviceRequestDtoPlatformEnum? platform;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RegisterDeviceRequestDto &&
      other.machineId == machineId &&
      other.deviceName == deviceName &&
      other.platform == platform;

    @override
    int get hashCode =>
        machineId.hashCode +
        deviceName.hashCode +
        platform.hashCode;

  factory RegisterDeviceRequestDto.fromJson(Map<String, dynamic> json) => _$RegisterDeviceRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDeviceRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum RegisterDeviceRequestDtoPlatformEnum {
@JsonValue(r'macos')
macos(r'macos'),
@JsonValue(r'windows')
windows(r'windows'),
@JsonValue(r'linux')
linux(r'linux');

const RegisterDeviceRequestDtoPlatformEnum(this.value);

final String value;

@override
String toString() => value;
}
