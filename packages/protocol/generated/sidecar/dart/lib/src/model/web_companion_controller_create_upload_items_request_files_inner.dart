//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_create_upload_items_request_files_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCreateUploadItemsRequestFilesInner {
  /// Returns a new [WebCompanionControllerCreateUploadItemsRequestFilesInner] instance.
  WebCompanionControllerCreateUploadItemsRequestFilesInner({

    required  this.clientFileId,

    required  this.filename,

    required  this.contentType,

    required  this.sizeBytes,
  });

  @JsonKey(

    name: r'clientFileId',
    required: true,
    includeIfNull: false,
  )


  final String clientFileId;



  @JsonKey(

    name: r'filename',
    required: true,
    includeIfNull: false,
  )


  final String filename;



  @JsonKey(

    name: r'contentType',
    required: true,
    includeIfNull: false,
  )


  final String contentType;



  @JsonKey(

    name: r'sizeBytes',
    required: true,
    includeIfNull: false,
  )


  final num sizeBytes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCreateUploadItemsRequestFilesInner &&
      other.clientFileId == clientFileId &&
      other.filename == filename &&
      other.contentType == contentType &&
      other.sizeBytes == sizeBytes;

    @override
    int get hashCode =>
        clientFileId.hashCode +
        filename.hashCode +
        contentType.hashCode +
        sizeBytes.hashCode;

  factory WebCompanionControllerCreateUploadItemsRequestFilesInner.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCreateUploadItemsRequestFilesInnerFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCreateUploadItemsRequestFilesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
