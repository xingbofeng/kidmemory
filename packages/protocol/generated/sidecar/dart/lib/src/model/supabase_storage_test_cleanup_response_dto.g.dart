// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_storage_test_cleanup_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SupabaseStorageTestCleanupResponseDtoCWProxy {
  SupabaseStorageTestCleanupResponseDto ok(bool? ok);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseStorageTestCleanupResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseStorageTestCleanupResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseStorageTestCleanupResponseDto call({bool? ok});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSupabaseStorageTestCleanupResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSupabaseStorageTestCleanupResponseDto.copyWith.fieldName(...)`
class _$SupabaseStorageTestCleanupResponseDtoCWProxyImpl
    implements _$SupabaseStorageTestCleanupResponseDtoCWProxy {
  const _$SupabaseStorageTestCleanupResponseDtoCWProxyImpl(this._value);

  final SupabaseStorageTestCleanupResponseDto _value;

  @override
  SupabaseStorageTestCleanupResponseDto ok(bool? ok) => this(ok: ok);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SupabaseStorageTestCleanupResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SupabaseStorageTestCleanupResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SupabaseStorageTestCleanupResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
  }) {
    return SupabaseStorageTestCleanupResponseDto(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool?,
    );
  }
}

extension $SupabaseStorageTestCleanupResponseDtoCopyWith
    on SupabaseStorageTestCleanupResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfSupabaseStorageTestCleanupResponseDto.copyWith(...)` or like so:`instanceOfSupabaseStorageTestCleanupResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SupabaseStorageTestCleanupResponseDtoCWProxy get copyWith =>
      _$SupabaseStorageTestCleanupResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupabaseStorageTestCleanupResponseDto
_$SupabaseStorageTestCleanupResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SupabaseStorageTestCleanupResponseDto', json, (
      $checkedConvert,
    ) {
      final val = SupabaseStorageTestCleanupResponseDto(
        ok: $checkedConvert('ok', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$SupabaseStorageTestCleanupResponseDtoToJson(
  SupabaseStorageTestCleanupResponseDto instance,
) => <String, dynamic>{'ok': instance.ok};
