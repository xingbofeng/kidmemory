//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_assets_failed_item_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportAssetsFailedItemDto {
  /// Returns a new [ImportAssetsFailedItemDto] instance.
  ImportAssetsFailedItemDto({

     this.reason,
  });

  @JsonKey(

    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportAssetsFailedItemDto &&
      other.reason == reason;

    @override
    int get hashCode =>
        reason.hashCode;

  factory ImportAssetsFailedItemDto.fromJson(Map<String, dynamic> json) => _$ImportAssetsFailedItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImportAssetsFailedItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
