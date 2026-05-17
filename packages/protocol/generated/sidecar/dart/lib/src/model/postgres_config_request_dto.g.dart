// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postgres_config_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PostgresConfigRequestDtoCWProxy {
  PostgresConfigRequestDto host(String host);

  PostgresConfigRequestDto port(int port);

  PostgresConfigRequestDto database(String database);

  PostgresConfigRequestDto user(String user);

  PostgresConfigRequestDto password(String? password);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostgresConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostgresConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PostgresConfigRequestDto call({
    String host,
    int port,
    String database,
    String user,
    String? password,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostgresConfigRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPostgresConfigRequestDto.copyWith.fieldName(...)`
class _$PostgresConfigRequestDtoCWProxyImpl
    implements _$PostgresConfigRequestDtoCWProxy {
  const _$PostgresConfigRequestDtoCWProxyImpl(this._value);

  final PostgresConfigRequestDto _value;

  @override
  PostgresConfigRequestDto host(String host) => this(host: host);

  @override
  PostgresConfigRequestDto port(int port) => this(port: port);

  @override
  PostgresConfigRequestDto database(String database) =>
      this(database: database);

  @override
  PostgresConfigRequestDto user(String user) => this(user: user);

  @override
  PostgresConfigRequestDto password(String? password) =>
      this(password: password);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostgresConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostgresConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PostgresConfigRequestDto call({
    Object? host = const $CopyWithPlaceholder(),
    Object? port = const $CopyWithPlaceholder(),
    Object? database = const $CopyWithPlaceholder(),
    Object? user = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return PostgresConfigRequestDto(
      host: host == const $CopyWithPlaceholder()
          ? _value.host
          // ignore: cast_nullable_to_non_nullable
          : host as String,
      port: port == const $CopyWithPlaceholder()
          ? _value.port
          // ignore: cast_nullable_to_non_nullable
          : port as int,
      database: database == const $CopyWithPlaceholder()
          ? _value.database
          // ignore: cast_nullable_to_non_nullable
          : database as String,
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as String,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String?,
    );
  }
}

extension $PostgresConfigRequestDtoCopyWith on PostgresConfigRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfPostgresConfigRequestDto.copyWith(...)` or like so:`instanceOfPostgresConfigRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PostgresConfigRequestDtoCWProxy get copyWith =>
      _$PostgresConfigRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostgresConfigRequestDto _$PostgresConfigRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PostgresConfigRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['host', 'port', 'database', 'user']);
  final val = PostgresConfigRequestDto(
    host: $checkedConvert('host', (v) => v as String),
    port: $checkedConvert('port', (v) => (v as num).toInt()),
    database: $checkedConvert('database', (v) => v as String),
    user: $checkedConvert('user', (v) => v as String),
    password: $checkedConvert('password', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$PostgresConfigRequestDtoToJson(
  PostgresConfigRequestDto instance,
) => <String, dynamic>{
  'host': instance.host,
  'port': instance.port,
  'database': instance.database,
  'user': instance.user,
if (instance.password != null) 'password': instance.password,
};
