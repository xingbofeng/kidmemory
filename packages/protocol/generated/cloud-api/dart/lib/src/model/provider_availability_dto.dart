//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'provider_availability_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProviderAvailabilityDto {
  /// Returns a new [ProviderAvailabilityDto] instance.
  ProviderAvailabilityDto({

    required  this.available,
  });

  @JsonKey(

    name: r'available',
    required: true,
    includeIfNull: false,
  )


  final bool available;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProviderAvailabilityDto &&
      other.available == available;

    @override
    int get hashCode =>
        available.hashCode;

  factory ProviderAvailabilityDto.fromJson(Map<String, dynamic> json) => _$ProviderAvailabilityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderAvailabilityDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
