//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'postgres_config_request_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PostgresConfigRequestDto {
  /// Returns a new [PostgresConfigRequestDto] instance.
  PostgresConfigRequestDto({

    required  this.host,

    required  this.port,

    required  this.database,

    required  this.user,

     this.password,
  });

  @JsonKey(

    name: r'host',
    required: true,
    includeIfNull: false,
  )


  final String host;



  @JsonKey(

    name: r'port',
    required: true,
    includeIfNull: false,
  )


  final int port;



  @JsonKey(

    name: r'database',
    required: true,
    includeIfNull: false,
  )


  final String database;



  @JsonKey(

    name: r'user',
    required: true,
    includeIfNull: false,
  )


  final String user;



  @JsonKey(

    name: r'password',
    required: false,
    includeIfNull: false,
  )


  final String? password;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PostgresConfigRequestDto &&
      other.host == host &&
      other.port == port &&
      other.database == database &&
      other.user == user &&
      other.password == password;

    @override
    int get hashCode =>
        host.hashCode +
        port.hashCode +
        database.hashCode +
        user.hashCode +
        password.hashCode;

  factory PostgresConfigRequestDto.fromJson(Map<String, dynamic> json) => _$PostgresConfigRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostgresConfigRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
