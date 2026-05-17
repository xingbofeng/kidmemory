//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/created_upload_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_upload_items_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateUploadItemsResponseDto {
  /// Returns a new [CreateUploadItemsResponseDto] instance.
  CreateUploadItemsResponseDto({

    required  this.items,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<CreatedUploadItemDto> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateUploadItemsResponseDto &&
      other.items == items;

    @override
    int get hashCode =>
        items.hashCode;

  factory CreateUploadItemsResponseDto.fromJson(Map<String, dynamic> json) => _$CreateUploadItemsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUploadItemsResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

