//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/provider_availability_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_providers_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadProvidersDto {
  /// Returns a new [DirectUploadProvidersDto] instance.
  DirectUploadProvidersDto({

    required  this.lan,

    required  this.supabase,
  });

  @JsonKey(

    name: r'lan',
    required: true,
    includeIfNull: false,
  )


  final ProviderAvailabilityDto lan;



  @JsonKey(

    name: r'supabase',
    required: true,
    includeIfNull: false,
  )


  final ProviderAvailabilityDto supabase;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadProvidersDto &&
      other.lan == lan &&
      other.supabase == supabase;

    @override
    int get hashCode =>
        lan.hashCode +
        supabase.hashCode;

  factory DirectUploadProvidersDto.fromJson(Map<String, dynamic> json) => _$DirectUploadProvidersDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadProvidersDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
