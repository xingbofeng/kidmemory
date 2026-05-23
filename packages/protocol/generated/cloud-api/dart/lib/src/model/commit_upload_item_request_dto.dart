//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commit_upload_item_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommitUploadItemRequestDto {
  /// Returns a new [CommitUploadItemRequestDto] instance.
  CommitUploadItemRequestDto({

    required  this.token,

    required  this.objectKey,

    required  this.contentType,

    required  this.sizeBytes,

     this.uploadToken,

     this.checksumSha256,

     this.metadata,
  });

  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(

    name: r'objectKey',
    required: true,
    includeIfNull: false,
  )


  final String objectKey;



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



  @JsonKey(

    name: r'uploadToken',
    required: false,
    includeIfNull: false,
  )


  final String? uploadToken;



  @JsonKey(

    name: r'checksumSha256',
    required: false,
    includeIfNull: false,
  )


  final String? checksumSha256;



  @JsonKey(

    name: r'metadata',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? metadata;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommitUploadItemRequestDto &&
      other.token == token &&
      other.objectKey == objectKey &&
      other.contentType == contentType &&
      other.sizeBytes == sizeBytes &&
      other.uploadToken == uploadToken &&
      other.checksumSha256 == checksumSha256 &&
      other.metadata == metadata;

    @override
    int get hashCode =>
        token.hashCode +
        objectKey.hashCode +
        contentType.hashCode +
        sizeBytes.hashCode +
        uploadToken.hashCode +
        checksumSha256.hashCode +
        metadata.hashCode;

  factory CommitUploadItemRequestDto.fromJson(Map<String, dynamic> json) => _$CommitUploadItemRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommitUploadItemRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
