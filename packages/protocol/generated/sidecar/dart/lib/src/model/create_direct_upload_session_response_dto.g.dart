// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_direct_upload_session_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateDirectUploadSessionResponseDtoCWProxy {
  CreateDirectUploadSessionResponseDto sessionId(String sessionId);

  CreateDirectUploadSessionResponseDto childId(String childId);

  CreateDirectUploadSessionResponseDto bucket(String bucket);

  CreateDirectUploadSessionResponseDto sessionPath(String sessionPath);

  CreateDirectUploadSessionResponseDto supabaseUrl(String supabaseUrl);

  CreateDirectUploadSessionResponseDto anonKey(String anonKey);

  CreateDirectUploadSessionResponseDto publicUrl(String publicUrl);

  CreateDirectUploadSessionResponseDto recommendedClientLimit(
    int recommendedClientLimit,
  );

  CreateDirectUploadSessionResponseDto expiresAtHintSeconds(
    int expiresAtHintSeconds,
  );

  CreateDirectUploadSessionResponseDto token(String token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateDirectUploadSessionResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateDirectUploadSessionResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateDirectUploadSessionResponseDto call({
    String sessionId,
    String childId,
    String bucket,
    String sessionPath,
    String supabaseUrl,
    String anonKey,
    String publicUrl,
    int recommendedClientLimit,
    int expiresAtHintSeconds,
    String token,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateDirectUploadSessionResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateDirectUploadSessionResponseDto.copyWith.fieldName(...)`
class _$CreateDirectUploadSessionResponseDtoCWProxyImpl
    implements _$CreateDirectUploadSessionResponseDtoCWProxy {
  const _$CreateDirectUploadSessionResponseDtoCWProxyImpl(this._value);

  final CreateDirectUploadSessionResponseDto _value;

  @override
  CreateDirectUploadSessionResponseDto sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  CreateDirectUploadSessionResponseDto childId(String childId) =>
      this(childId: childId);

  @override
  CreateDirectUploadSessionResponseDto bucket(String bucket) =>
      this(bucket: bucket);

  @override
  CreateDirectUploadSessionResponseDto sessionPath(String sessionPath) =>
      this(sessionPath: sessionPath);

  @override
  CreateDirectUploadSessionResponseDto supabaseUrl(String supabaseUrl) =>
      this(supabaseUrl: supabaseUrl);

  @override
  CreateDirectUploadSessionResponseDto anonKey(String anonKey) =>
      this(anonKey: anonKey);

  @override
  CreateDirectUploadSessionResponseDto publicUrl(String publicUrl) =>
      this(publicUrl: publicUrl);

  @override
  CreateDirectUploadSessionResponseDto recommendedClientLimit(
    int recommendedClientLimit,
  ) => this(recommendedClientLimit: recommendedClientLimit);

  @override
  CreateDirectUploadSessionResponseDto expiresAtHintSeconds(
    int expiresAtHintSeconds,
  ) => this(expiresAtHintSeconds: expiresAtHintSeconds);

  @override
  CreateDirectUploadSessionResponseDto token(String token) =>
      this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateDirectUploadSessionResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateDirectUploadSessionResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateDirectUploadSessionResponseDto call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? childId = const $CopyWithPlaceholder(),
    Object? bucket = const $CopyWithPlaceholder(),
    Object? sessionPath = const $CopyWithPlaceholder(),
    Object? supabaseUrl = const $CopyWithPlaceholder(),
    Object? anonKey = const $CopyWithPlaceholder(),
    Object? publicUrl = const $CopyWithPlaceholder(),
    Object? recommendedClientLimit = const $CopyWithPlaceholder(),
    Object? expiresAtHintSeconds = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return CreateDirectUploadSessionResponseDto(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      childId: childId == const $CopyWithPlaceholder()
          ? _value.childId
          // ignore: cast_nullable_to_non_nullable
          : childId as String,
      bucket: bucket == const $CopyWithPlaceholder()
          ? _value.bucket
          // ignore: cast_nullable_to_non_nullable
          : bucket as String,
      sessionPath: sessionPath == const $CopyWithPlaceholder()
          ? _value.sessionPath
          // ignore: cast_nullable_to_non_nullable
          : sessionPath as String,
      supabaseUrl: supabaseUrl == const $CopyWithPlaceholder()
          ? _value.supabaseUrl
          // ignore: cast_nullable_to_non_nullable
          : supabaseUrl as String,
      anonKey: anonKey == const $CopyWithPlaceholder()
          ? _value.anonKey
          // ignore: cast_nullable_to_non_nullable
          : anonKey as String,
      publicUrl: publicUrl == const $CopyWithPlaceholder()
          ? _value.publicUrl
          // ignore: cast_nullable_to_non_nullable
          : publicUrl as String,
      recommendedClientLimit:
          recommendedClientLimit == const $CopyWithPlaceholder()
          ? _value.recommendedClientLimit
          // ignore: cast_nullable_to_non_nullable
          : recommendedClientLimit as int,
      expiresAtHintSeconds: expiresAtHintSeconds == const $CopyWithPlaceholder()
          ? _value.expiresAtHintSeconds
          // ignore: cast_nullable_to_non_nullable
          : expiresAtHintSeconds as int,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
    );
  }
}

extension $CreateDirectUploadSessionResponseDtoCopyWith
    on CreateDirectUploadSessionResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateDirectUploadSessionResponseDto.copyWith(...)` or like so:`instanceOfCreateDirectUploadSessionResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateDirectUploadSessionResponseDtoCWProxy get copyWith =>
      _$CreateDirectUploadSessionResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDirectUploadSessionResponseDto
_$CreateDirectUploadSessionResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateDirectUploadSessionResponseDto', json, (
      $checkedConvert,
    ) {
      $checkKeys(
        json,
        requiredKeys: const [
          'sessionId',
          'childId',
          'bucket',
          'sessionPath',
          'supabaseUrl',
          'anonKey',
          'publicUrl',
          'recommendedClientLimit',
          'expiresAtHintSeconds',
          'token',
        ],
      );
      final val = CreateDirectUploadSessionResponseDto(
        sessionId: $checkedConvert('sessionId', (v) => v as String),
        childId: $checkedConvert('childId', (v) => v as String),
        bucket: $checkedConvert('bucket', (v) => v as String),
        sessionPath: $checkedConvert('sessionPath', (v) => v as String),
        supabaseUrl: $checkedConvert('supabaseUrl', (v) => v as String),
        anonKey: $checkedConvert('anonKey', (v) => v as String),
        publicUrl: $checkedConvert('publicUrl', (v) => v as String),
        recommendedClientLimit: $checkedConvert(
          'recommendedClientLimit',
          (v) => (v as num).toInt(),
        ),
        expiresAtHintSeconds: $checkedConvert(
          'expiresAtHintSeconds',
          (v) => (v as num).toInt(),
        ),
        token: $checkedConvert('token', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CreateDirectUploadSessionResponseDtoToJson(
  CreateDirectUploadSessionResponseDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'childId': instance.childId,
  'bucket': instance.bucket,
  'sessionPath': instance.sessionPath,
  'supabaseUrl': instance.supabaseUrl,
  'anonKey': instance.anonKey,
  'publicUrl': instance.publicUrl,
  'recommendedClientLimit': instance.recommendedClientLimit,
  'expiresAtHintSeconds': instance.expiresAtHintSeconds,
  'token': instance.token,
};
