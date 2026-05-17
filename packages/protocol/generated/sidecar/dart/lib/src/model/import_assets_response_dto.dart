//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/import_assets_failed_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_assets_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportAssetsResponseDto {
  /// Returns a new [ImportAssetsResponseDto] instance.
  ImportAssetsResponseDto({

     this.imported,

     this.duplicates,

     this.failed,

     this.skipped,

     this.message,

     this.title,
  });

  @JsonKey(

    name: r'imported',
    required: false,
    includeIfNull: false,
  )


  final List<Map<String, Object>>? imported;



  @JsonKey(

    name: r'duplicates',
    required: false,
    includeIfNull: false,
  )


  final List<Map<String, Object>>? duplicates;



  @JsonKey(

    name: r'failed',
    required: false,
    includeIfNull: false,
  )


  final List<ImportAssetsFailedItemDto>? failed;



  @JsonKey(

    name: r'skipped',
    required: false,
    includeIfNull: false,
  )


  final List<Map<String, Object>>? skipped;



  @JsonKey(

    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;



  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportAssetsResponseDto &&
      other.imported == imported &&
      other.duplicates == duplicates &&
      other.failed == failed &&
      other.skipped == skipped &&
      other.message == message &&
      other.title == title;

    @override
    int get hashCode =>
        imported.hashCode +
        duplicates.hashCode +
        failed.hashCode +
        skipped.hashCode +
        message.hashCode +
        title.hashCode;

  factory ImportAssetsResponseDto.fromJson(Map<String, dynamic> json) => _$ImportAssetsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImportAssetsResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
