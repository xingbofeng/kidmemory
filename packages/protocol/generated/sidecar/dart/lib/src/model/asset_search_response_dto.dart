//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/asset_search_item_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset_search_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetSearchResponseDto {
  /// Returns a new [AssetSearchResponseDto] instance.
  AssetSearchResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,

     this.total,

     this.items,
  });

  @JsonKey(

    name: r'ok',
    required: false,
    includeIfNull: false,
  )


  final bool? ok;



  @JsonKey(

    name: r'success',
    required: false,
    includeIfNull: false,
  )


  final bool? success;



  @JsonKey(

    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;



  @JsonKey(

    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



  @JsonKey(

    name: r'total',
    required: false,
    includeIfNull: false,
  )


  final int? total;



  @JsonKey(

    name: r'items',
    required: false,
    includeIfNull: false,
  )


  final List<AssetSearchItemResponseDto>? items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetSearchResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code &&
      other.total == total &&
      other.items == items;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode +
        total.hashCode +
        items.hashCode;

  factory AssetSearchResponseDto.fromJson(Map<String, dynamic> json) => _$AssetSearchResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetSearchResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
