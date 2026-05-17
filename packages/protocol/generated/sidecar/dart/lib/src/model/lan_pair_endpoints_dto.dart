//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lan_pair_endpoints_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LanPairEndpointsDto {
  /// Returns a new [LanPairEndpointsDto] instance.
  LanPairEndpointsDto({

    required  this.upload,

    required  this.status,
  });

  @JsonKey(

    name: r'upload',
    required: true,
    includeIfNull: false,
  )


  final String upload;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LanPairEndpointsDto &&
      other.upload == upload &&
      other.status == status;

    @override
    int get hashCode =>
        upload.hashCode +
        status.hashCode;

  factory LanPairEndpointsDto.fromJson(Map<String, dynamic> json) => _$LanPairEndpointsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanPairEndpointsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
