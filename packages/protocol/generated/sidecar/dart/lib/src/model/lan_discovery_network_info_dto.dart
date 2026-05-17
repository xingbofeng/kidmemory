//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_discovery_network_info_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanDiscoveryNetworkInfoDto {
  /// Returns a new [LanDiscoveryNetworkInfoDto] instance.
  LanDiscoveryNetworkInfoDto({

    required  this.ip,

    required  this.port,

    required  this.protocol,
  });

  @JsonKey(

    name: r'ip',
    required: true,
    includeIfNull: false,
  )


  final String ip;



  @JsonKey(

    name: r'port',
    required: true,
    includeIfNull: false,
  )


  final int port;



  @JsonKey(

    name: r'protocol',
    required: true,
    includeIfNull: false,
  )


  final String protocol;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanDiscoveryNetworkInfoDto &&
      other.ip == ip &&
      other.port == port &&
      other.protocol == protocol;

    @override
    int get hashCode =>
        ip.hashCode +
        port.hashCode +
        protocol.hashCode;

  factory LanDiscoveryNetworkInfoDto.fromJson(Map<String, dynamic> json) => _$LanDiscoveryNetworkInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanDiscoveryNetworkInfoDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
