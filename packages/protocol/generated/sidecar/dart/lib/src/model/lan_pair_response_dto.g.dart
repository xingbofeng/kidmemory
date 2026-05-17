// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_pair_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LanPairResponseDtoCWProxy {
  LanPairResponseDto success(bool success);

  LanPairResponseDto sessionId(String sessionId);

  LanPairResponseDto token(String token);

  LanPairResponseDto expiresAt(String expiresAt);

  LanPairResponseDto endpoints(LanPairEndpointsDto endpoints);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanPairResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanPairResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanPairResponseDto call({
    bool success,
    String sessionId,
    String token,
    String expiresAt,
    LanPairEndpointsDto endpoints,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLanPairResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLanPairResponseDto.copyWith.fieldName(...)`
class _$LanPairResponseDtoCWProxyImpl implements _$LanPairResponseDtoCWProxy {
  const _$LanPairResponseDtoCWProxyImpl(this._value);

  final LanPairResponseDto _value;

  @override
  LanPairResponseDto success(bool success) => this(success: success);

  @override
  LanPairResponseDto sessionId(String sessionId) => this(sessionId: sessionId);

  @override
  LanPairResponseDto token(String token) => this(token: token);

  @override
  LanPairResponseDto expiresAt(String expiresAt) => this(expiresAt: expiresAt);

  @override
  LanPairResponseDto endpoints(LanPairEndpointsDto endpoints) =>
      this(endpoints: endpoints);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LanPairResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LanPairResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  LanPairResponseDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? endpoints = const $CopyWithPlaceholder(),
  }) {
    return LanPairResponseDto(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as String,
      endpoints: endpoints == const $CopyWithPlaceholder()
          ? _value.endpoints
          // ignore: cast_nullable_to_non_nullable
          : endpoints as LanPairEndpointsDto,
    );
  }
}

extension $LanPairResponseDtoCopyWith on LanPairResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfLanPairResponseDto.copyWith(...)` or like so:`instanceOfLanPairResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LanPairResponseDtoCWProxy get copyWith =>
      _$LanPairResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanPairResponseDto _$LanPairResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LanPairResponseDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'success',
          'sessionId',
          'token',
          'expiresAt',
          'endpoints',
        ],
      );
      final val = LanPairResponseDto(
        success: $checkedConvert('success', (v) => v as bool),
        sessionId: $checkedConvert('sessionId', (v) => v as String),
        token: $checkedConvert('token', (v) => v as String),
        expiresAt: $checkedConvert('expiresAt', (v) => v as String),
        endpoints: $checkedConvert(
          'endpoints',
          (v) => LanPairEndpointsDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LanPairResponseDtoToJson(LanPairResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'sessionId': instance.sessionId,
      'token': instance.token,
      'expiresAt': instance.expiresAt,
      'endpoints': instance.endpoints.toJson(),
    };
