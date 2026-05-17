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

    required  this.sizeBytes,

    required  this.contentType,

     this.remoteEtag,
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

    name: r'sizeBytes',
    required: true,
    includeIfNull: false,
  )


  final int sizeBytes;



  @JsonKey(

    name: r'contentType',
    required: true,
    includeIfNull: false,
  )


  final String contentType;



  @JsonKey(

    name: r'remoteEtag',
    required: false,
    includeIfNull: false,
  )


  final String? remoteEtag;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommitUploadItemRequestDto &&
      other.token == token &&
      other.objectKey == objectKey &&
      other.sizeBytes == sizeBytes &&
      other.contentType == contentType &&
      other.remoteEtag == remoteEtag;

    @override
    int get hashCode =>
        token.hashCode +
        objectKey.hashCode +
        sizeBytes.hashCode +
        contentType.hashCode +
        remoteEtag.hashCode;

  factory CommitUploadItemRequestDto.fromJson(Map<String, dynamic> json) => _$CommitUploadItemRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommitUploadItemRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
