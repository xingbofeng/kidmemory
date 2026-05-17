//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_book_job_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateBookJobRequestDto {
  /// Returns a new [CreateBookJobRequestDto] instance.
  CreateBookJobRequestDto({

    required  this.assetIds,

     this.childId,

     this.coverPolicy,
  });

  @JsonKey(

    name: r'assetIds',
    required: true,
    includeIfNull: false,
  )


  final List<String> assetIds;



  @JsonKey(

    name: r'childId',
    required: false,
    includeIfNull: false,
  )


  final String? childId;



  @JsonKey(

    name: r'coverPolicy',
    required: false,
    includeIfNull: false,
  )


  final String? coverPolicy;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateBookJobRequestDto &&
      other.assetIds == assetIds &&
      other.childId == childId &&
      other.coverPolicy == coverPolicy;

    @override
    int get hashCode =>
        assetIds.hashCode +
        childId.hashCode +
        coverPolicy.hashCode;

  factory CreateBookJobRequestDto.fromJson(Map<String, dynamic> json) => _$CreateBookJobRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookJobRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
