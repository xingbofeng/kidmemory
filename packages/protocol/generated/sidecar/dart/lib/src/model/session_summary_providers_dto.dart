//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/session_summary_providers_dto_lan.dart';
import 'package:kidmemory_protocol/src/model/session_summary_providers_dto_supabase.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_summary_providers_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionSummaryProvidersDto {
  /// Returns a new [SessionSummaryProvidersDto] instance.
  SessionSummaryProvidersDto({

     this.lan,

     this.supabase,
  });

  @JsonKey(

    name: r'lan',
    required: false,
    includeIfNull: false,
  )


  final SessionSummaryProvidersDtoLan? lan;



  @JsonKey(

    name: r'supabase',
    required: false,
    includeIfNull: false,
  )


  final SessionSummaryProvidersDtoSupabase? supabase;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SessionSummaryProvidersDto &&
      other.lan == lan &&
      other.supabase == supabase;

    @override
    int get hashCode =>
        lan.hashCode +
        supabase.hashCode;

  factory SessionSummaryProvidersDto.fromJson(Map<String, dynamic> json) => _$SessionSummaryProvidersDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSummaryProvidersDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
