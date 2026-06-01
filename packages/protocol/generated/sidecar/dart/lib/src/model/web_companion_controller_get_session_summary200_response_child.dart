//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_get_session_summary200_response_child.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerGetSessionSummary200ResponseChild {
  /// Returns a new [WebCompanionControllerGetSessionSummary200ResponseChild] instance.
  WebCompanionControllerGetSessionSummary200ResponseChild({

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
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerGetSessionSummary200ResponseChild &&
      other.id == id &&
      other.displayName == displayName;

    @override
    int get hashCode =>
        id.hashCode +
        displayName.hashCode;

  factory WebCompanionControllerGetSessionSummary200ResponseChild.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerGetSessionSummary200ResponseChildFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerGetSessionSummary200ResponseChildToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
