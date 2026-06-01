//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_upload_controller_pullback201_response_results_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DirectUploadControllerPullback201ResponseResultsInner {
  /// Returns a new [DirectUploadControllerPullback201ResponseResultsInner] instance.
  DirectUploadControllerPullback201ResponseResultsInner({

    required  this.objectKey,

    required  this.status,

     this.errorCode,

     this.errorMessage,
  });

  @JsonKey(

    name: r'objectKey',
    required: true,
    includeIfNull: false,
  )


  final String objectKey;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final DirectUploadControllerPullback201ResponseResultsInnerStatusEnum status;



  @JsonKey(

    name: r'errorCode',
    required: false,
    includeIfNull: false,
  )


  final String? errorCode;



  @JsonKey(

    name: r'errorMessage',
    required: false,
    includeIfNull: false,
  )


  final String? errorMessage;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DirectUploadControllerPullback201ResponseResultsInner &&
      other.objectKey == objectKey &&
      other.status == status &&
      other.errorCode == errorCode &&
      other.errorMessage == errorMessage;

    @override
    int get hashCode =>
        objectKey.hashCode +
        status.hashCode +
        (errorCode == null ? 0 : errorCode.hashCode) +
        (errorMessage == null ? 0 : errorMessage.hashCode);

  factory DirectUploadControllerPullback201ResponseResultsInner.fromJson(Map<String, dynamic> json) => _$DirectUploadControllerPullback201ResponseResultsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$DirectUploadControllerPullback201ResponseResultsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DirectUploadControllerPullback201ResponseResultsInnerStatusEnum {
@JsonValue(r'ready')
ready(r'ready'),
@JsonValue(r'failed')
failed(r'failed');

const DirectUploadControllerPullback201ResponseResultsInnerStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
