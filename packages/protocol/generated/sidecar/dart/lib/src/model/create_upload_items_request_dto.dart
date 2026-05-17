//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/create_upload_item_file_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_upload_items_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateUploadItemsRequestDto {
  /// Returns a new [CreateUploadItemsRequestDto] instance.
  CreateUploadItemsRequestDto({

    required  this.token,

    required  this.files,

    required  this.provider,
  });

  @JsonKey(

    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(

    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final List<CreateUploadItemFileDto> files;



  @JsonKey(

    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final String provider;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateUploadItemsRequestDto &&
      other.token == token &&
      other.files == files &&
      other.provider == provider;

    @override
    int get hashCode =>
        token.hashCode +
        files.hashCode +
        provider.hashCode;

  factory CreateUploadItemsRequestDto.fromJson(Map<String, dynamic> json) => _$CreateUploadItemsRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUploadItemsRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
