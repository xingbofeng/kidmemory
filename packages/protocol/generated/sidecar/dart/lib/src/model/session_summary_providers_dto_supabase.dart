//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_summary_providers_dto_supabase.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionSummaryProvidersDtoSupabase {
  /// Returns a new [SessionSummaryProvidersDtoSupabase] instance.
  SessionSummaryProvidersDtoSupabase({

     this.available,
  });

  @JsonKey(

    name: r'available',
    required: false,
    includeIfNull: false,
  )


  final bool? available;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SessionSummaryProvidersDtoSupabase &&
      other.available == available;

    @override
    int get hashCode =>
        available.hashCode;

  factory SessionSummaryProvidersDtoSupabase.fromJson(Map<String, dynamic> json) => _$SessionSummaryProvidersDtoSupabaseFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSummaryProvidersDtoSupabaseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
