//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'postgres_config_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PostgresConfigResponseDto {
  /// Returns a new [PostgresConfigResponseDto] instance.
  PostgresConfigResponseDto({

     this.host,

     this.port,

     this.database,

     this.user,
  });

  @JsonKey(

    name: r'host',
    required: false,
    includeIfNull: false,
  )


  final String? host;



  @JsonKey(

    name: r'port',
    required: false,
    includeIfNull: false,
  )


  final int? port;



  @JsonKey(

    name: r'database',
    required: false,
    includeIfNull: false,
  )


  final String? database;



  @JsonKey(

    name: r'user',
    required: false,
    includeIfNull: false,
  )


  final String? user;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PostgresConfigResponseDto &&
      other.host == host &&
      other.port == port &&
      other.database == database &&
      other.user == user;

    @override
    int get hashCode =>
        host.hashCode +
        port.hashCode +
        database.hashCode +
        user.hashCode;

  factory PostgresConfigResponseDto.fromJson(Map<String, dynamic> json) => _$PostgresConfigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostgresConfigResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
