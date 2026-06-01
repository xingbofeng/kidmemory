//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_close_session201_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCloseSession201Response {
  /// Returns a new [WebCompanionControllerCloseSession201Response] instance.
  WebCompanionControllerCloseSession201Response({

    required  this.success,
  });

  @JsonKey(

    name: r'success',
    required: true,
    includeIfNull: false,
  )


  final bool success;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCloseSession201Response &&
      other.success == success;

    @override
    int get hashCode =>
        success.hashCode;

  factory WebCompanionControllerCloseSession201Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCloseSession201ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCloseSession201ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
