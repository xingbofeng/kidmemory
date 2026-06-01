//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_access_shared_content200_response_share_token.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerAccessSharedContent200ResponseShareToken {
  /// Returns a new [WebCompanionControllerAccessSharedContent200ResponseShareToken] instance.
  WebCompanionControllerAccessSharedContent200ResponseShareToken({

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


  final WebCompanionControllerAccessSharedContent200ResponseShareTokenResourceTypeEnum resourceType;



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


  final WebCompanionControllerAccessSharedContent200ResponseShareTokenAccessTypeEnum accessType;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerAccessSharedContent200ResponseShareToken &&
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

  factory WebCompanionControllerAccessSharedContent200ResponseShareToken.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerAccessSharedContent200ResponseShareTokenFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerAccessSharedContent200ResponseShareTokenToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WebCompanionControllerAccessSharedContent200ResponseShareTokenResourceTypeEnum {
@JsonValue(r'child_assets')
childAssets(r'child_assets'),
@JsonValue(r'specific_book')
specificBook(r'specific_book'),
@JsonValue(r'asset_collection')
assetCollection(r'asset_collection');

const WebCompanionControllerAccessSharedContent200ResponseShareTokenResourceTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum WebCompanionControllerAccessSharedContent200ResponseShareTokenAccessTypeEnum {
@JsonValue(r'read_only')
readOnly(r'read_only'),
@JsonValue(r'time_limited')
timeLimited(r'time_limited');

const WebCompanionControllerAccessSharedContent200ResponseShareTokenAccessTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
