//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_create_upload_items201_response_items_inner_signed_upload.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload {
  /// Returns a new [WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload] instance.
  WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload({

    required  this.method,

    required  this.url,

    required  this.expiresAt,

    required  this.headers,
  });

  @JsonKey(

    name: r'method',
    required: true,
    includeIfNull: false,
  )


  final WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUploadMethodEnum method;



  @JsonKey(

    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(

    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final String expiresAt;



  @JsonKey(

    name: r'headers',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> headers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload &&
      other.method == method &&
      other.url == url &&
      other.expiresAt == expiresAt &&
      other.headers == headers;

    @override
    int get hashCode =>
        method.hashCode +
        url.hashCode +
        expiresAt.hashCode +
        headers.hashCode;

  factory WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUploadFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUploadToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUploadMethodEnum {
@JsonValue(r'PUT')
PUT(r'PUT');

const WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUploadMethodEnum(this.value);

final String value;

@override
String toString() => value;
}
