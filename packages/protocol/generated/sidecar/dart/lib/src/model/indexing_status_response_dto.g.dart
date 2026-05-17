// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexing_status_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IndexingStatusResponseDtoCWProxy {
  IndexingStatusResponseDto pending(int? pending);

  IndexingStatusResponseDto running(int? running);

  IndexingStatusResponseDto retryWait(int? retryWait);

  IndexingStatusResponseDto failed(int? failed);

  IndexingStatusResponseDto searchable(int? searchable);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndexingStatusResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndexingStatusResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  IndexingStatusResponseDto call({
    int? pending,
    int? running,
    int? retryWait,
    int? failed,
    int? searchable,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIndexingStatusResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIndexingStatusResponseDto.copyWith.fieldName(...)`
class _$IndexingStatusResponseDtoCWProxyImpl
    implements _$IndexingStatusResponseDtoCWProxy {
  const _$IndexingStatusResponseDtoCWProxyImpl(this._value);

  final IndexingStatusResponseDto _value;

  @override
  IndexingStatusResponseDto pending(int? pending) => this(pending: pending);

  @override
  IndexingStatusResponseDto running(int? running) => this(running: running);

  @override
  IndexingStatusResponseDto retryWait(int? retryWait) =>
      this(retryWait: retryWait);

  @override
  IndexingStatusResponseDto failed(int? failed) => this(failed: failed);

  @override
  IndexingStatusResponseDto searchable(int? searchable) =>
      this(searchable: searchable);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndexingStatusResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndexingStatusResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  IndexingStatusResponseDto call({
    Object? pending = const $CopyWithPlaceholder(),
    Object? running = const $CopyWithPlaceholder(),
    Object? retryWait = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
    Object? searchable = const $CopyWithPlaceholder(),
  }) {
    return IndexingStatusResponseDto(
      pending: pending == const $CopyWithPlaceholder()
          ? _value.pending
          // ignore: cast_nullable_to_non_nullable
          : pending as int?,
      running: running == const $CopyWithPlaceholder()
          ? _value.running
          // ignore: cast_nullable_to_non_nullable
          : running as int?,
      retryWait: retryWait == const $CopyWithPlaceholder()
          ? _value.retryWait
          // ignore: cast_nullable_to_non_nullable
          : retryWait as int?,
      failed: failed == const $CopyWithPlaceholder()
          ? _value.failed
          // ignore: cast_nullable_to_non_nullable
          : failed as int?,
      searchable: searchable == const $CopyWithPlaceholder()
          ? _value.searchable
          // ignore: cast_nullable_to_non_nullable
          : searchable as int?,
    );
  }
}

extension $IndexingStatusResponseDtoCopyWith on IndexingStatusResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfIndexingStatusResponseDto.copyWith(...)` or like so:`instanceOfIndexingStatusResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IndexingStatusResponseDtoCWProxy get copyWith =>
      _$IndexingStatusResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndexingStatusResponseDto _$IndexingStatusResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('IndexingStatusResponseDto', json, ($checkedConvert) {
  final val = IndexingStatusResponseDto(
    pending: $checkedConvert('pending', (v) => (v as num?)?.toInt()),
    running: $checkedConvert('running', (v) => (v as num?)?.toInt()),
    retryWait: $checkedConvert('retryWait', (v) => (v as num?)?.toInt()),
    failed: $checkedConvert('failed', (v) => (v as num?)?.toInt()),
    searchable: $checkedConvert('searchable', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$IndexingStatusResponseDtoToJson(
  IndexingStatusResponseDto instance,
) => <String, dynamic>{
if (instance.pending != null) 'pending': instance.pending,
if (instance.running != null) 'running': instance.running,
if (instance.retryWait != null) 'retryWait': instance.retryWait,
if (instance.failed != null) 'failed': instance.failed,
if (instance.searchable != null) 'searchable': instance.searchable,
};
