// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readiness_check_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReadinessCheckResponseDtoCWProxy {
  ReadinessCheckResponseDto ok(bool? ok);

  ReadinessCheckResponseDto ready(bool? ready);

  ReadinessCheckResponseDto blocksGeneration(bool? blocksGeneration);

  ReadinessCheckResponseDto service(String? service);

  ReadinessCheckResponseDto message(String? message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadinessCheckResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadinessCheckResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadinessCheckResponseDto call({
    bool? ok,
    bool? ready,
    bool? blocksGeneration,
    String? service,
    String? message,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReadinessCheckResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReadinessCheckResponseDto.copyWith.fieldName(...)`
class _$ReadinessCheckResponseDtoCWProxyImpl
    implements _$ReadinessCheckResponseDtoCWProxy {
  const _$ReadinessCheckResponseDtoCWProxyImpl(this._value);

  final ReadinessCheckResponseDto _value;

  @override
  ReadinessCheckResponseDto ok(bool? ok) => this(ok: ok);

  @override
  ReadinessCheckResponseDto ready(bool? ready) => this(ready: ready);

  @override
  ReadinessCheckResponseDto blocksGeneration(bool? blocksGeneration) =>
      this(blocksGeneration: blocksGeneration);

  @override
  ReadinessCheckResponseDto service(String? service) => this(service: service);

  @override
  ReadinessCheckResponseDto message(String? message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadinessCheckResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadinessCheckResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadinessCheckResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? ready = const $CopyWithPlaceholder(),
    Object? blocksGeneration = const $CopyWithPlaceholder(),
    Object? service = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return ReadinessCheckResponseDto(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool?,
      ready: ready == const $CopyWithPlaceholder()
          ? _value.ready
          // ignore: cast_nullable_to_non_nullable
          : ready as bool?,
      blocksGeneration: blocksGeneration == const $CopyWithPlaceholder()
          ? _value.blocksGeneration
          // ignore: cast_nullable_to_non_nullable
          : blocksGeneration as bool?,
      service: service == const $CopyWithPlaceholder()
          ? _value.service
          // ignore: cast_nullable_to_non_nullable
          : service as String?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
    );
  }
}

extension $ReadinessCheckResponseDtoCopyWith on ReadinessCheckResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfReadinessCheckResponseDto.copyWith(...)` or like so:`instanceOfReadinessCheckResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReadinessCheckResponseDtoCWProxy get copyWith =>
      _$ReadinessCheckResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadinessCheckResponseDto _$ReadinessCheckResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReadinessCheckResponseDto', json, ($checkedConvert) {
  final val = ReadinessCheckResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    ready: $checkedConvert('ready', (v) => v as bool?),
    blocksGeneration: $checkedConvert('blocksGeneration', (v) => v as bool?),
    service: $checkedConvert('service', (v) => v as String?),
    message: $checkedConvert('message', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ReadinessCheckResponseDtoToJson(
  ReadinessCheckResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.ready != null) 'ready': instance.ready,
if (instance.blocksGeneration != null) 'blocksGeneration': instance.blocksGeneration,
if (instance.service != null) 'service': instance.service,
if (instance.message != null) 'message': instance.message,
};
