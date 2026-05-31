//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'share_token_access_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShareTokenAccessDto {
  /// Returns a new [ShareTokenAccessDto] instance.
  ShareTokenAccessDto({

    required  this.id,

    required  this.childId,

    required  this.resourceType,

     this.resourceId,

    required  this.accessType,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(

    name: r'resourceType',
    required: true,
    includeIfNull: false,
  )


  final ShareTokenAccessDtoResourceTypeEnum resourceType;



  @JsonKey(

    name: r'resourceId',
    required: false,
    includeIfNull: false,
  )


  final String? resourceId;



  @JsonKey(

    name: r'accessType',
    required: true,
    includeIfNull: false,
  )


  final ShareTokenAccessDtoAccessTypeEnum accessType;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareTokenAccessDto &&
      other.id == id &&
      other.childId == childId &&
      other.resourceType == resourceType &&
      other.resourceId == resourceId &&
      other.accessType == accessType;

    @override
    int get hashCode =>
        id.hashCode +
        childId.hashCode +
        resourceType.hashCode +
        resourceId.hashCode +
        accessType.hashCode;

  factory ShareTokenAccessDto.fromJson(Map<String, dynamic> json) => _$ShareTokenAccessDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ShareTokenAccessDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ShareTokenAccessDtoResourceTypeEnum {
@JsonValue(r'specific_book')
specificBook(r'specific_book'),
@JsonValue(r'child_assets')
childAssets(r'child_assets');

const ShareTokenAccessDtoResourceTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ShareTokenAccessDtoAccessTypeEnum {
@JsonValue(r'read')
read(r'read');

const ShareTokenAccessDtoAccessTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
