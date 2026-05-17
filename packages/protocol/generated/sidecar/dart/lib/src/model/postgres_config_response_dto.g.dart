// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postgres_config_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PostgresConfigResponseDtoCWProxy {
  PostgresConfigResponseDto host(String? host);

  PostgresConfigResponseDto port(int? port);

  PostgresConfigResponseDto database(String? database);

  PostgresConfigResponseDto user(String? user);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostgresConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostgresConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PostgresConfigResponseDto call({
    String? host,
    int? port,
    String? database,
    String? user,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostgresConfigResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPostgresConfigResponseDto.copyWith.fieldName(...)`
class _$PostgresConfigResponseDtoCWProxyImpl
    implements _$PostgresConfigResponseDtoCWProxy {
  const _$PostgresConfigResponseDtoCWProxyImpl(this._value);

  final PostgresConfigResponseDto _value;

  @override
  PostgresConfigResponseDto host(String? host) => this(host: host);

  @override
  PostgresConfigResponseDto port(int? port) => this(port: port);

  @override
  PostgresConfigResponseDto database(String? database) =>
      this(database: database);

  @override
  PostgresConfigResponseDto user(String? user) => this(user: user);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostgresConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostgresConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PostgresConfigResponseDto call({
    Object? host = const $CopyWithPlaceholder(),
    Object? port = const $CopyWithPlaceholder(),
    Object? database = const $CopyWithPlaceholder(),
    Object? user = const $CopyWithPlaceholder(),
  }) {
    return PostgresConfigResponseDto(
      host: host == const $CopyWithPlaceholder()
          ? _value.host
          // ignore: cast_nullable_to_non_nullable
          : host as String?,
      port: port == const $CopyWithPlaceholder()
          ? _value.port
          // ignore: cast_nullable_to_non_nullable
          : port as int?,
      database: database == const $CopyWithPlaceholder()
          ? _value.database
          // ignore: cast_nullable_to_non_nullable
          : database as String?,
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as String?,
    );
  }
}

extension $PostgresConfigResponseDtoCopyWith on PostgresConfigResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfPostgresConfigResponseDto.copyWith(...)` or like so:`instanceOfPostgresConfigResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PostgresConfigResponseDtoCWProxy get copyWith =>
      _$PostgresConfigResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostgresConfigResponseDto _$PostgresConfigResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PostgresConfigResponseDto', json, ($checkedConvert) {
  final val = PostgresConfigResponseDto(
    host: $checkedConvert('host', (v) => v as String?),
    port: $checkedConvert('port', (v) => (v as num?)?.toInt()),
    database: $checkedConvert('database', (v) => v as String?),
    user: $checkedConvert('user', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$PostgresConfigResponseDtoToJson(
  PostgresConfigResponseDto instance,
) => <String, dynamic>{
if (instance.host != null) 'host': instance.host,
if (instance.port != null) 'port': instance.port,
if (instance.database != null) 'database': instance.database,
if (instance.user != null) 'user': instance.user,
};
