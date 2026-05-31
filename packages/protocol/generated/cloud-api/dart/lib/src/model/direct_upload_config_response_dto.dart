//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_config_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadConfigResponseDto {
  /// Returns a new [DirectUploadConfigResponseDto] instance.
  DirectUploadConfigResponseDto({

    required  this.anonKey,
  });

  @JsonKey(

    name: r'anonKey',
    required: true,
    includeIfNull: false,
  )


  final String anonKey;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadConfigResponseDto &&
      other.anonKey == anonKey;

    @override
    int get hashCode =>
        anonKey.hashCode;

  factory DirectUploadConfigResponseDto.fromJson(Map<String, dynamic> json) => _$DirectUploadConfigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadConfigResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
