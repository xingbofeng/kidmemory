//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_create_share_token201_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCreateShareToken201Response {
  /// Returns a new [WebCompanionControllerCreateShareToken201Response] instance.
  WebCompanionControllerCreateShareToken201Response({

    required  this.id,

    required  this.token,

    required  this.childId,

    required  this.expiresAt,

    required  this.accessType,

    required  this.resourceType,

     this.resourceId,

     this.maxAccessCount,

    required  this.shareUrl,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(

    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(

    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final String expiresAt;



  @JsonKey(

    name: r'accessType',
    required: true,
    includeIfNull: false,
  )


  final WebCompanionControllerCreateShareToken201ResponseAccessTypeEnum accessType;



  @JsonKey(

    name: r'resourceType',
    required: true,
    includeIfNull: false,
  )


  final WebCompanionControllerCreateShareToken201ResponseResourceTypeEnum resourceType;



  @JsonKey(

    name: r'resourceId',
    required: false,
    includeIfNull: false,
  )


  final String? resourceId;



  @JsonKey(

    name: r'maxAccessCount',
    required: false,
    includeIfNull: false,
  )


  final num? maxAccessCount;



  @JsonKey(

    name: r'shareUrl',
    required: true,
    includeIfNull: false,
  )


  final String shareUrl;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCreateShareToken201Response &&
      other.id == id &&
      other.token == token &&
      other.childId == childId &&
      other.expiresAt == expiresAt &&
      other.accessType == accessType &&
      other.resourceType == resourceType &&
      other.resourceId == resourceId &&
      other.maxAccessCount == maxAccessCount &&
      other.shareUrl == shareUrl;

    @override
    int get hashCode =>
        id.hashCode +
        token.hashCode +
        childId.hashCode +
        expiresAt.hashCode +
        accessType.hashCode +
        resourceType.hashCode +
        resourceId.hashCode +
        maxAccessCount.hashCode +
        shareUrl.hashCode;

  factory WebCompanionControllerCreateShareToken201Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCreateShareToken201ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCreateShareToken201ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WebCompanionControllerCreateShareToken201ResponseAccessTypeEnum {
@JsonValue(r'read_only')
readOnly(r'read_only'),
@JsonValue(r'time_limited')
timeLimited(r'time_limited');

const WebCompanionControllerCreateShareToken201ResponseAccessTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum WebCompanionControllerCreateShareToken201ResponseResourceTypeEnum {
@JsonValue(r'child_assets')
childAssets(r'child_assets'),
@JsonValue(r'specific_book')
specificBook(r'specific_book'),
@JsonValue(r'asset_collection')
assetCollection(r'asset_collection');

const WebCompanionControllerCreateShareToken201ResponseResourceTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
