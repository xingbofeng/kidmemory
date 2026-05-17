// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enqueue_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnqueueResponseDtoCWProxy {
  EnqueueResponseDto enqueued(bool? enqueued);

  EnqueueResponseDto reason(String? reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnqueueResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnqueueResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  EnqueueResponseDto call({bool? enqueued, String? reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnqueueResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnqueueResponseDto.copyWith.fieldName(...)`
class _$EnqueueResponseDtoCWProxyImpl implements _$EnqueueResponseDtoCWProxy {
  const _$EnqueueResponseDtoCWProxyImpl(this._value);

  final EnqueueResponseDto _value;

  @override
  EnqueueResponseDto enqueued(bool? enqueued) => this(enqueued: enqueued);

  @override
  EnqueueResponseDto reason(String? reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnqueueResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnqueueResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  EnqueueResponseDto call({
    Object? enqueued = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return EnqueueResponseDto(
      enqueued: enqueued == const $CopyWithPlaceholder()
          ? _value.enqueued
          // ignore: cast_nullable_to_non_nullable
          : enqueued as bool?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $EnqueueResponseDtoCopyWith on EnqueueResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfEnqueueResponseDto.copyWith(...)` or like so:`instanceOfEnqueueResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnqueueResponseDtoCWProxy get copyWith =>
      _$EnqueueResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnqueueResponseDto _$EnqueueResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EnqueueResponseDto', json, ($checkedConvert) {
      final val = EnqueueResponseDto(
        enqueued: $checkedConvert('enqueued', (v) => v as bool?),
        reason: $checkedConvert('reason', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$EnqueueResponseDtoToJson(EnqueueResponseDto instance) =>
    <String, dynamic>{
if (instance.enqueued != null) 'enqueued': instance.enqueued,
if (instance.reason != null) 'reason': instance.reason,
    };
