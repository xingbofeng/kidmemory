//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:kidmemory_protocol/src/model/web_companion_controller_create_upload_items201_response_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_companion_controller_create_upload_items201_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebCompanionControllerCreateUploadItems201Response {
  /// Returns a new [WebCompanionControllerCreateUploadItems201Response] instance.
  WebCompanionControllerCreateUploadItems201Response({

    required  this.items,
  });

  @JsonKey(

    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<WebCompanionControllerCreateUploadItems201ResponseItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WebCompanionControllerCreateUploadItems201Response &&
      other.items == items;

    @override
    int get hashCode =>
        items.hashCode;

  factory WebCompanionControllerCreateUploadItems201Response.fromJson(Map<String, dynamic> json) => _$WebCompanionControllerCreateUploadItems201ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebCompanionControllerCreateUploadItems201ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
