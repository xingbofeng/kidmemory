//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_summary_providers_dto_lan.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionSummaryProvidersDtoLan {
  /// Returns a new [SessionSummaryProvidersDtoLan] instance.
  SessionSummaryProvidersDtoLan({

     this.available,

     this.endpoint,
  });

  @JsonKey(

    name: r'available',
    required: false,
    includeIfNull: false,
  )


  final bool? available;



  @JsonKey(

    name: r'endpoint',
    required: false,
    includeIfNull: false,
  )


  final String? endpoint;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SessionSummaryProvidersDtoLan &&
      other.available == available &&
      other.endpoint == endpoint;

    @override
    int get hashCode =>
        available.hashCode +
        endpoint.hashCode;

  factory SessionSummaryProvidersDtoLan.fromJson(Map<String, dynamic> json) => _$SessionSummaryProvidersDtoLanFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSummaryProvidersDtoLanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
