//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset_record_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetRecordResponseDto {
  /// Returns a new [AssetRecordResponseDto] instance.
  AssetRecordResponseDto({

     this.id,

     this.title,

     this.type,

     this.description,

     this.tags,

     this.capturedAt,

     this.imagePath,

     this.thumbnailPath,

     this.previewUrl,

     this.originalFilename,

     this.storageStatus,
  });

  @JsonKey(

    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(

    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final String? type;



  @JsonKey(

    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(

    name: r'tags',
    required: false,
    includeIfNull: false,
  )


  final List<String>? tags;



  @JsonKey(

    name: r'capturedAt',
    required: false,
    includeIfNull: false,
  )


  final String? capturedAt;



  @JsonKey(

    name: r'imagePath',
    required: false,
    includeIfNull: false,
  )


  final String? imagePath;



  @JsonKey(

    name: r'thumbnailPath',
    required: false,
    includeIfNull: false,
  )


  final String? thumbnailPath;



  @JsonKey(

    name: r'previewUrl',
    required: false,
    includeIfNull: false,
  )


  final String? previewUrl;



  @JsonKey(

    name: r'originalFilename',
    required: false,
    includeIfNull: false,
  )


  final String? originalFilename;



  @JsonKey(

    name: r'storageStatus',
    required: false,
    includeIfNull: false,
  )


  final String? storageStatus;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetRecordResponseDto &&
      other.id == id &&
      other.title == title &&
      other.type == type &&
      other.description == description &&
      other.tags == tags &&
      other.capturedAt == capturedAt &&
      other.imagePath == imagePath &&
      other.thumbnailPath == thumbnailPath &&
      other.previewUrl == previewUrl &&
      other.originalFilename == originalFilename &&
      other.storageStatus == storageStatus;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        type.hashCode +
        description.hashCode +
        tags.hashCode +
        capturedAt.hashCode +
        imagePath.hashCode +
        thumbnailPath.hashCode +
        previewUrl.hashCode +
        originalFilename.hashCode +
        storageStatus.hashCode;

  factory AssetRecordResponseDto.fromJson(Map<String, dynamic> json) => _$AssetRecordResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetRecordResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
