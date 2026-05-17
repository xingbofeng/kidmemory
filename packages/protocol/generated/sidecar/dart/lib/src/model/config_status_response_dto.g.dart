// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_status_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfigStatusResponseDtoCWProxy {
  ConfigStatusResponseDto postgres(PostgresConfigResponseDto? postgres);

  ConfigStatusResponseDto openai(OpenAiConfigResponseDto? openai);

  ConfigStatusResponseDto supabaseStorage(
    SupabaseStorageConfigResponseDto? supabaseStorage,
  );

  ConfigStatusResponseDto paths(PathConfigResponseDto? paths);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfigStatusResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfigStatusResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfigStatusResponseDto call({
    PostgresConfigResponseDto? postgres,
    OpenAiConfigResponseDto? openai,
    SupabaseStorageConfigResponseDto? supabaseStorage,
    PathConfigResponseDto? paths,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfigStatusResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfigStatusResponseDto.copyWith.fieldName(...)`
class _$ConfigStatusResponseDtoCWProxyImpl
    implements _$ConfigStatusResponseDtoCWProxy {
  const _$ConfigStatusResponseDtoCWProxyImpl(this._value);

  final ConfigStatusResponseDto _value;

  @override
  ConfigStatusResponseDto postgres(PostgresConfigResponseDto? postgres) =>
      this(postgres: postgres);

  @override
  ConfigStatusResponseDto openai(OpenAiConfigResponseDto? openai) =>
      this(openai: openai);

  @override
  ConfigStatusResponseDto supabaseStorage(
    SupabaseStorageConfigResponseDto? supabaseStorage,
  ) => this(supabaseStorage: supabaseStorage);

  @override
  ConfigStatusResponseDto paths(PathConfigResponseDto? paths) =>
      this(paths: paths);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfigStatusResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfigStatusResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfigStatusResponseDto call({
    Object? postgres = const $CopyWithPlaceholder(),
    Object? openai = const $CopyWithPlaceholder(),
    Object? supabaseStorage = const $CopyWithPlaceholder(),
    Object? paths = const $CopyWithPlaceholder(),
  }) {
    return ConfigStatusResponseDto(
      postgres: postgres == const $CopyWithPlaceholder()
          ? _value.postgres
          // ignore: cast_nullable_to_non_nullable
          : postgres as PostgresConfigResponseDto?,
      openai: openai == const $CopyWithPlaceholder()
          ? _value.openai
          // ignore: cast_nullable_to_non_nullable
          : openai as OpenAiConfigResponseDto?,
      supabaseStorage: supabaseStorage == const $CopyWithPlaceholder()
          ? _value.supabaseStorage
          // ignore: cast_nullable_to_non_nullable
          : supabaseStorage as SupabaseStorageConfigResponseDto?,
      paths: paths == const $CopyWithPlaceholder()
          ? _value.paths
          // ignore: cast_nullable_to_non_nullable
          : paths as PathConfigResponseDto?,
    );
  }
}

extension $ConfigStatusResponseDtoCopyWith on ConfigStatusResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfConfigStatusResponseDto.copyWith(...)` or like so:`instanceOfConfigStatusResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfigStatusResponseDtoCWProxy get copyWith =>
      _$ConfigStatusResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigStatusResponseDto _$ConfigStatusResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ConfigStatusResponseDto', json, ($checkedConvert) {
  final val = ConfigStatusResponseDto(
    postgres: $checkedConvert(
      'postgres',
      (v) => v == null
          ? null
          : PostgresConfigResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    openai: $checkedConvert(
      'openai',
      (v) => v == null
          ? null
          : OpenAiConfigResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    supabaseStorage: $checkedConvert(
      'supabaseStorage',
      (v) => v == null
          ? null
          : SupabaseStorageConfigResponseDto.fromJson(
              v as Map<String, dynamic>,
            ),
    ),
    paths: $checkedConvert(
      'paths',
      (v) => v == null
          ? null
          : PathConfigResponseDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ConfigStatusResponseDtoToJson(
  ConfigStatusResponseDto instance,
) => <String, dynamic>{
if (instance.postgres?.toJson() != null) 'postgres': instance.postgres?.toJson(),
if (instance.openai?.toJson() != null) 'openai': instance.openai?.toJson(),
if (instance.supabaseStorage?.toJson() != null) 'supabaseStorage': instance.supabaseStorage?.toJson(),
if (instance.paths?.toJson() != null) 'paths': instance.paths?.toJson(),
};
