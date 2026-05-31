//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trusted_upload_session_child_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TrustedUploadSessionChildDto {
  /// Returns a new [TrustedUploadSessionChildDto] instance.
  TrustedUploadSessionChildDto({

    required  this.id,

    required  this.displayName,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'displayName',
    required: true,
    includeIfNull: false,
  )


  final String displayName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TrustedUploadSessionChildDto &&
      other.id == id &&
      other.displayName == displayName;

    @override
    int get hashCode =>
        id.hashCode +
        displayName.hashCode;

  factory TrustedUploadSessionChildDto.fromJson(Map<String, dynamic> json) => _$TrustedUploadSessionChildDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TrustedUploadSessionChildDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
