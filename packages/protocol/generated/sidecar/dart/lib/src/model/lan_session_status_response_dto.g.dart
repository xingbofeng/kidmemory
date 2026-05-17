// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_session_status_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanSessionStatusResponseDtoCWProxy {
  LanSessionStatusResponseDto sessionId(String sessionId);

  LanSessionStatusResponseDto status(String status);

  LanSessionStatusResponseDto expiresAt(String expiresAt);

  LanSessionStatusResponseDto currentUploads(int currentUploads);

  LanSessionStatusResponseDto maxConcurrentUploads(int maxConcurrentUploads);

  LanSessionStatusResponseDto totalUploaded(int totalUploaded);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanSessionStatusResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanSessionStatusResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanSessionStatusResponseDto call({
    String sessionId,
    String status,
    String expiresAt,
    int currentUploads,
    int maxConcurrentUploads,
    int totalUploaded,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanSessionStatusResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanSessionStatusResponseDto.copyWith.fieldName(...)`
class _$LanSessionStatusResponseDtoCWProxyImpl
    implements _$LanSessionStatusResponseDtoCWProxy {
  const _$LanSessionStatusResponseDtoCWProxyImpl(this._value);

  final LanSessionStatusResponseDto _value;

  @override
  LanSessionStatusResponseDto sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  LanSessionStatusResponseDto status(String status) => this(status: status);

  @override
  LanSessionStatusResponseDto expiresAt(String expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  LanSessionStatusResponseDto currentUploads(int currentUploads) =>
      this(currentUploads: currentUploads);

  @override
  LanSessionStatusResponseDto maxConcurrentUploads(int maxConcurrentUploads) =>
      this(maxConcurrentUploads: maxConcurrentUploads);

  @override
  LanSessionStatusResponseDto totalUploaded(int totalUploaded) =>
      this(totalUploaded: totalUploaded);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanSessionStatusResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanSessionStatusResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanSessionStatusResponseDto call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? currentUploads = const $CopyWithPlaceholder(),
    Object? maxConcurrentUploads = const $CopyWithPlaceholder(),
    Object? totalUploaded = const $CopyWithPlaceholder(),
  }) {
    return LanSessionStatusResponseDto(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as String,
      currentUploads: currentUploads == const $CopyWithPlaceholder()
          ? _value.currentUploads
          // ignore: cast_nullable_to_non_nullable
          : currentUploads as int,
      maxConcurrentUploads: maxConcurrentUploads == const $CopyWithPlaceholder()
          ? _value.maxConcurrentUploads
          // ignore: cast_nullable_to_non_nullable
          : maxConcurrentUploads as int,
      totalUploaded: totalUploaded == const $CopyWithPlaceholder()
          ? _value.totalUploaded
          // ignore: cast_nullable_to_non_nullable
          : totalUploaded as int,
    );
  }
}

extension $LanSessionStatusResponseDtoCopyWith on LanSessionStatusResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanSessionStatusResponseDto.copyWith(...)` or like so:`instanceOfLanSessionStatusResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanSessionStatusResponseDtoCWProxy get copyWith =>
      _$LanSessionStatusResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanSessionStatusResponseDto _$LanSessionStatusResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LanSessionStatusResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'sessionId',
      'status',
      'expiresAt',
      'currentUploads',
      'maxConcurrentUploads',
      'totalUploaded',
    ],
  );
  final val = LanSessionStatusResponseDto(
    sessionId: $checkedConvert('sessionId', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    expiresAt: $checkedConvert('expiresAt', (v) => v as String),
    currentUploads: $checkedConvert(
      'currentUploads',
      (v) => (v as num).toInt(),
    ),
    maxConcurrentUploads: $checkedConvert(
      'maxConcurrentUploads',
      (v) => (v as num).toInt(),
    ),
    totalUploaded: $checkedConvert('totalUploaded', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$LanSessionStatusResponseDtoToJson(
  LanSessionStatusResponseDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'status': instance.status,
  'expiresAt': instance.expiresAt,
  'currentUploads': instance.currentUploads,
  'maxConcurrentUploads': instance.maxConcurrentUploads,
  'totalUploaded': instance.totalUploaded,
};
