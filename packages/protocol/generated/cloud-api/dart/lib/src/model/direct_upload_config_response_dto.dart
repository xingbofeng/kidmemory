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

    required  this.provider,

    required  this.uploadMode,
  });

  @JsonKey(

    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final DirectUploadConfigResponseDtoProviderEnum provider;



  @JsonKey(

    name: r'uploadMode',
    required: true,
    includeIfNull: false,
  )


  final DirectUploadConfigResponseDtoUploadModeEnum uploadMode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadConfigResponseDto &&
      other.provider == provider &&
      other.uploadMode == uploadMode;

    @override
    int get hashCode =>
        provider.hashCode +
        uploadMode.hashCode;

  factory DirectUploadConfigResponseDto.fromJson(Map<String, dynamic> json) => _$DirectUploadConfigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadConfigResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DirectUploadConfigResponseDtoProviderEnum {
@JsonValue(r'cos')
cos(r'cos');

const DirectUploadConfigResponseDtoProviderEnum(this.value);

final String value;

@override
String toString() => value;
}



enum DirectUploadConfigResponseDtoUploadModeEnum {
@JsonValue(r'signed-url')
signedUrl(r'signed-url');

const DirectUploadConfigResponseDtoUploadModeEnum(this.value);

final String value;

@override
String toString() => value;
}
