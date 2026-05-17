//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/lan_discovery_security_dto.dart';
import 'package:kidmemory_protocol/src/model/lan_discovery_network_info_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_discovery_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanDiscoveryResponseDto {
  /// Returns a new [LanDiscoveryResponseDto] instance.
  LanDiscoveryResponseDto({

    required  this.deviceId,

    required  this.deviceName,

    required  this.version,

    required  this.capabilities,

    required  this.networkInfo,

    required  this.security,
  });

  @JsonKey(

    name: r'deviceId',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(

    name: r'deviceName',
    required: true,
    includeIfNull: false,
  )


  final String deviceName;



  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final String version;



  @JsonKey(

    name: r'capabilities',
    required: true,
    includeIfNull: false,
  )


  final List<String> capabilities;



  @JsonKey(

    name: r'networkInfo',
    required: true,
    includeIfNull: false,
  )


  final LanDiscoveryNetworkInfoDto networkInfo;



  @JsonKey(

    name: r'security',
    required: true,
    includeIfNull: false,
  )


  final LanDiscoverySecurityDto security;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanDiscoveryResponseDto &&
      other.deviceId == deviceId &&
      other.deviceName == deviceName &&
      other.version == version &&
      other.capabilities == capabilities &&
      other.networkInfo == networkInfo &&
      other.security == security;

    @override
    int get hashCode =>
        deviceId.hashCode +
        deviceName.hashCode +
        version.hashCode +
        capabilities.hashCode +
        networkInfo.hashCode +
        security.hashCode;

  factory LanDiscoveryResponseDto.fromJson(Map<String, dynamic> json) => _$LanDiscoveryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanDiscoveryResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
