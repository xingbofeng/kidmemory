//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset_search_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetSearchRequestDto {
  /// Returns a new [AssetSearchRequestDto] instance.
  AssetSearchRequestDto({

    required  this.childId,

    required  this.query,

    required  this.page,

    required  this.pageSize,

     this.filters,
  });

  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(

    name: r'query',
    required: true,
    includeIfNull: false,
  )


  final String query;



  @JsonKey(

    name: r'page',
    required: true,
    includeIfNull: false,
  )


  final int page;



  @JsonKey(

    name: r'pageSize',
    required: true,
    includeIfNull: false,
  )


  final int pageSize;



  @JsonKey(

    name: r'filters',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? filters;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetSearchRequestDto &&
      other.childId == childId &&
      other.query == query &&
      other.page == page &&
      other.pageSize == pageSize &&
      other.filters == filters;

    @override
    int get hashCode =>
        childId.hashCode +
        query.hashCode +
        page.hashCode +
        pageSize.hashCode +
        filters.hashCode;

  factory AssetSearchRequestDto.fromJson(Map<String, dynamic> json) => _$AssetSearchRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetSearchRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
