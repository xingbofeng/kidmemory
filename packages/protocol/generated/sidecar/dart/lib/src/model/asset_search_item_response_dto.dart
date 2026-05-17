//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/asset_record_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset_search_item_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetSearchItemResponseDto {
  /// Returns a new [AssetSearchItemResponseDto] instance.
  AssetSearchItemResponseDto({

     this.asset,

     this.reasons,
  });

  @JsonKey(

    name: r'asset',
    required: false,
    includeIfNull: false,
  )


  final AssetRecordResponseDto? asset;



  @JsonKey(

    name: r'reasons',
    required: false,
    includeIfNull: false,
  )


  final List<String>? reasons;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetSearchItemResponseDto &&
      other.asset == asset &&
      other.reasons == reasons;

    @override
    int get hashCode =>
        asset.hashCode +
        reasons.hashCode;

  factory AssetSearchItemResponseDto.fromJson(Map<String, dynamic> json) => _$AssetSearchItemResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetSearchItemResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
