//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/asset_record_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assets_list_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetsListResponseDto {
  /// Returns a new [AssetsListResponseDto] instance.
  AssetsListResponseDto({

     this.assets,
  });

  @JsonKey(

    name: r'assets',
    required: false,
    includeIfNull: false,
  )


  final List<AssetRecordResponseDto>? assets;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetsListResponseDto &&
      other.assets == assets;

    @override
    int get hashCode =>
        assets.hashCode;

  factory AssetsListResponseDto.fromJson(Map<String, dynamic> json) => _$AssetsListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetsListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
