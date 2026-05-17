//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_pair_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanPairRequestDto {
  /// Returns a new [LanPairRequestDto] instance.
  LanPairRequestDto({

    required  this.deviceId,

    required  this.childId,

     this.pairingCode,
  });

  @JsonKey(

    name: r'deviceId',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(

    name: r'pairingCode',
    required: false,
    includeIfNull: false,
  )


  final String? pairingCode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanPairRequestDto &&
      other.deviceId == deviceId &&
      other.childId == childId &&
      other.pairingCode == pairingCode;

    @override
    int get hashCode =>
        deviceId.hashCode +
        childId.hashCode +
        pairingCode.hashCode;

  factory LanPairRequestDto.fromJson(Map<String, dynamic> json) => _$LanPairRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanPairRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
