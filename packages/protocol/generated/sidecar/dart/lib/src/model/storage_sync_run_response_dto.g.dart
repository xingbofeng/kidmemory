// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_sync_run_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StorageSyncRunResponseDtoCWProxy {
  StorageSyncRunResponseDto failed(int? failed);

  StorageSyncRunResponseDto retried(int? retried);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StorageSyncRunResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StorageSyncRunResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  StorageSyncRunResponseDto call({int? failed, int? retried});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStorageSyncRunResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStorageSyncRunResponseDto.copyWith.fieldName(...)`
class _$StorageSyncRunResponseDtoCWProxyImpl
    implements _$StorageSyncRunResponseDtoCWProxy {
  const _$StorageSyncRunResponseDtoCWProxyImpl(this._value);

  final StorageSyncRunResponseDto _value;

  @override
  StorageSyncRunResponseDto failed(int? failed) => this(failed: failed);

  @override
  StorageSyncRunResponseDto retried(int? retried) => this(retried: retried);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StorageSyncRunResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StorageSyncRunResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  StorageSyncRunResponseDto call({
    Object? failed = const $CopyWithPlaceholder(),
    Object? retried = const $CopyWithPlaceholder(),
  }) {
    return StorageSyncRunResponseDto(
      failed: failed == const $CopyWithPlaceholder()
          ? _value.failed
          // ignore: cast_nullable_to_non_nullable
          : failed as int?,
      retried: retried == const $CopyWithPlaceholder()
          ? _value.retried
          // ignore: cast_nullable_to_non_nullable
          : retried as int?,
    );
  }
}

extension $StorageSyncRunResponseDtoCopyWith on StorageSyncRunResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfStorageSyncRunResponseDto.copyWith(...)` or like so:`instanceOfStorageSyncRunResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StorageSyncRunResponseDtoCWProxy get copyWith =>
      _$StorageSyncRunResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageSyncRunResponseDto _$StorageSyncRunResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StorageSyncRunResponseDto', json, ($checkedConvert) {
  final val = StorageSyncRunResponseDto(
    failed: $checkedConvert('failed', (v) => (v as num?)?.toInt()),
    retried: $checkedConvert('retried', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$StorageSyncRunResponseDtoToJson(
  StorageSyncRunResponseDto instance,
) => <String, dynamic>{
if (instance.failed != null) 'failed': instance.failed,
if (instance.retried != null) 'retried': instance.retried,
};
