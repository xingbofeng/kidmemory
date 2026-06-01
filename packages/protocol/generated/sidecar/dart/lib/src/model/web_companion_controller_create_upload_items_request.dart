//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/web_companion_controller_create_upload_items_request_files_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_create_upload_items_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCreateUploadItemsRequest {
  /// Returns a new [WebCompanionControllerCreateUploadItemsRequest] instance.
  WebCompanionControllerCreateUploadItemsRequest({

    required  this.token,

     this.provider,

    required  this.files,
  });

  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(

    name: r'provider',
    required: false,
    includeIfNull: false,
  )


  final String? provider;



  @JsonKey(

    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final List<WebCompanionControllerCreateUploadItemsRequestFilesInner> files;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCreateUploadItemsRequest &&
      other.token == token &&
      other.provider == provider &&
      other.files == files;

    @override
    int get hashCode =>
        token.hashCode +
        provider.hashCode +
        files.hashCode;

  factory WebCompanionControllerCreateUploadItemsRequest.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCreateUploadItemsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCreateUploadItemsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
