//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_summary_response_dto_child.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionSummaryResponseDtoChild {
  /// Returns a new [SessionSummaryResponseDtoChild] instance.
  SessionSummaryResponseDtoChild({

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
    bool operator ==(Object other) => identical(this, other) || other is SessionSummaryResponseDtoChild &&
      other.id == id &&
      other.displayName == displayName;

    @override
    int get hashCode =>
        id.hashCode +
        displayName.hashCode;

  factory SessionSummaryResponseDtoChild.fromJson(Map<String, dynamic> json) => _$SessionSummaryResponseDtoChildFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSummaryResponseDtoChildToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
