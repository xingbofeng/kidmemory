//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_discovery_security_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanDiscoverySecurityDto {
  /// Returns a new [LanDiscoverySecurityDto] instance.
  LanDiscoverySecurityDto({

    required  this.requiresAuth,

    required  this.supportedMethods,
  });

  @JsonKey(

    name: r'requiresAuth',
    required: true,
    includeIfNull: false,
  )


  final bool requiresAuth;



  @JsonKey(

    name: r'supportedMethods',
    required: true,
    includeIfNull: false,
  )


  final List<String> supportedMethods;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanDiscoverySecurityDto &&
      other.requiresAuth == requiresAuth &&
      other.supportedMethods == supportedMethods;

    @override
    int get hashCode =>
        requiresAuth.hashCode +
        supportedMethods.hashCode;

  factory LanDiscoverySecurityDto.fromJson(Map<String, dynamic> json) => _$LanDiscoverySecurityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanDiscoverySecurityDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
