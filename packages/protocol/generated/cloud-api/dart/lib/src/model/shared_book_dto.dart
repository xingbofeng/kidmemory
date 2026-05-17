//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shared_book_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SharedBookDto {
  /// Returns a new [SharedBookDto] instance.
  SharedBookDto({

    required  this.id,

    required  this.title,

    required  this.childId,

    required  this.createdAt,

    required  this.status,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'childId',
    required: true,
    includeIfNull: false,
  )


  final String childId;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final String createdAt;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SharedBookDto &&
      other.id == id &&
      other.title == title &&
      other.childId == childId &&
      other.createdAt == createdAt &&
      other.status == status;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        childId.hashCode +
        createdAt.hashCode +
        status.hashCode;

  factory SharedBookDto.fromJson(Map<String, dynamic> json) => _$SharedBookDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SharedBookDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

