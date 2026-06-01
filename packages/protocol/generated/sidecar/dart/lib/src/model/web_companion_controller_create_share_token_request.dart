//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_create_share_token_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCreateShareTokenRequest {
  /// Returns a new [WebCompanionControllerCreateShareTokenRequest] instance.
  WebCompanionControllerCreateShareTokenRequest({

     this.childId,

    required  this.resourceType,

     this.resourceId,

     this.expiresInHours,

     this.maxAccessCount,

     this.accessType,
  });

  @JsonKey(

    name: r'childId',
    required: false,
    includeIfNull: false,
  )


  final String? childId;



  @JsonKey(

    name: r'resourceType',
    required: true,
    includeIfNull: false,
  )


  final WebCompanionControllerCreateShareTokenRequestResourceTypeEnum resourceType;



  @JsonKey(

    name: r'resourceId',
    required: false,
    includeIfNull: false,
  )


  final String? resourceId;



  @JsonKey(

    name: r'expiresInHours',
    required: false,
    includeIfNull: false,
  )


  final num? expiresInHours;



  @JsonKey(

    name: r'maxAccessCount',
    required: false,
    includeIfNull: false,
  )


  final num? maxAccessCount;



  @JsonKey(

    name: r'accessType',
    required: false,
    includeIfNull: false,
  )


  final WebCompanionControllerCreateShareTokenRequestAccessTypeEnum? accessType;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCreateShareTokenRequest &&
      other.childId == childId &&
      other.resourceType == resourceType &&
      other.resourceId == resourceId &&
      other.expiresInHours == expiresInHours &&
      other.maxAccessCount == maxAccessCount &&
      other.accessType == accessType;

    @override
    int get hashCode =>
        childId.hashCode +
        resourceType.hashCode +
        resourceId.hashCode +
        expiresInHours.hashCode +
        maxAccessCount.hashCode +
        accessType.hashCode;

  factory WebCompanionControllerCreateShareTokenRequest.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCreateShareTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCreateShareTokenRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WebCompanionControllerCreateShareTokenRequestResourceTypeEnum {
@JsonValue(r'child_assets')
childAssets(r'child_assets'),
@JsonValue(r'specific_book')
specificBook(r'specific_book'),
@JsonValue(r'asset_collection')
assetCollection(r'asset_collection');

const WebCompanionControllerCreateShareTokenRequestResourceTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum WebCompanionControllerCreateShareTokenRequestAccessTypeEnum {
@JsonValue(r'read_only')
readOnly(r'read_only'),
@JsonValue(r'time_limited')
timeLimited(r'time_limited');

const WebCompanionControllerCreateShareTokenRequestAccessTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
