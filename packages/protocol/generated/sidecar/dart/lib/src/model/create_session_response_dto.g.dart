// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_session_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateSessionResponseDtoCWProxy {
  CreateSessionResponseDto sessionId(String sessionId);

  CreateSessionResponseDto token(String token);

  CreateSessionResponseDto webUrl(String webUrl);

  CreateSessionResponseDto expiresAt(String expiresAt);

  CreateSessionResponseDto maxItems(int maxItems);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateSessionResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateSessionResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateSessionResponseDto call({
    String sessionId,
    String token,
    String webUrl,
    String expiresAt,
    int maxItems,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateSessionResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateSessionResponseDto.copyWith.fieldName(...)`
class _$CreateSessionResponseDtoCWProxyImpl
    implements _$CreateSessionResponseDtoCWProxy {
  const _$CreateSessionResponseDtoCWProxyImpl(this._value);

  final CreateSessionResponseDto _value;

  @override
  CreateSessionResponseDto sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  CreateSessionResponseDto token(String token) => this(token: token);

  @override
  CreateSessionResponseDto webUrl(String webUrl) => this(webUrl: webUrl);

  @override
  CreateSessionResponseDto expiresAt(String expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  CreateSessionResponseDto maxItems(int maxItems) => this(maxItems: maxItems);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateSessionResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateSessionResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateSessionResponseDto call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
    Object? webUrl = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? maxItems = const $CopyWithPlaceholder(),
  }) {
    return CreateSessionResponseDto(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      webUrl: webUrl == const $CopyWithPlaceholder()
          ? _value.webUrl
          // ignore: cast_nullable_to_non_nullable
          : webUrl as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as String,
      maxItems: maxItems == const $CopyWithPlaceholder()
          ? _value.maxItems
          // ignore: cast_nullable_to_non_nullable
          : maxItems as int,
    );
  }
}

extension $CreateSessionResponseDtoCopyWith on CreateSessionResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateSessionResponseDto.copyWith(...)` or like so:`instanceOfCreateSessionResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateSessionResponseDtoCWProxy get copyWith =>
      _$CreateSessionResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSessionResponseDto _$CreateSessionResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateSessionResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'sessionId',
      'token',
      'webUrl',
      'expiresAt',
      'maxItems',
    ],
  );
  final val = CreateSessionResponseDto(
    sessionId: $checkedConvert('sessionId', (v) => v as String),
    token: $checkedConvert('token', (v) => v as String),
    webUrl: $checkedConvert('webUrl', (v) => v as String),
    expiresAt: $checkedConvert('expiresAt', (v) => v as String),
    maxItems: $checkedConvert('maxItems', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$CreateSessionResponseDtoToJson(
  CreateSessionResponseDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'token': instance.token,
  'webUrl': instance.webUrl,
  'expiresAt': instance.expiresAt,
  'maxItems': instance.maxItems,
};
