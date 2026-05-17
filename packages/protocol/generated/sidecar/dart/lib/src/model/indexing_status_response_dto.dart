//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'indexing_status_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IndexingStatusResponseDto {
  /// Returns a new [IndexingStatusResponseDto] instance.
  IndexingStatusResponseDto({

     this.pending,

     this.running,

     this.retryWait,

     this.failed,

     this.searchable,
  });

  @JsonKey(

    name: r'pending',
    required: false,
    includeIfNull: false,
  )


  final int? pending;



  @JsonKey(

    name: r'running',
    required: false,
    includeIfNull: false,
  )


  final int? running;



  @JsonKey(

    name: r'retryWait',
    required: false,
    includeIfNull: false,
  )


  final int? retryWait;



  @JsonKey(

    name: r'failed',
    required: false,
    includeIfNull: false,
  )


  final int? failed;



  @JsonKey(

    name: r'searchable',
    required: false,
    includeIfNull: false,
  )


  final int? searchable;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IndexingStatusResponseDto &&
      other.pending == pending &&
      other.running == running &&
      other.retryWait == retryWait &&
      other.failed == failed &&
      other.searchable == searchable;

    @override
    int get hashCode =>
        pending.hashCode +
        running.hashCode +
        retryWait.hashCode +
        failed.hashCode +
        searchable.hashCode;

  factory IndexingStatusResponseDto.fromJson(Map<String, dynamic> json) => _$IndexingStatusResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$IndexingStatusResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
