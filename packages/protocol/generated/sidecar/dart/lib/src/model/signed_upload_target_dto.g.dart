// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signed_upload_target_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SignedUploadTargetDtoCWProxy {
  SignedUploadTargetDto method(String method);

  SignedUploadTargetDto url(String url);

  SignedUploadTargetDto expiresAt(String expiresAt);

  SignedUploadTargetDto headers(Map<String, String> headers);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SignedUploadTargetDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SignedUploadTargetDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SignedUploadTargetDto call({
    String method,
    String url,
    String expiresAt,
    Map<String, String> headers,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSignedUploadTargetDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSignedUploadTargetDto.copyWith.fieldName(...)`
class _$SignedUploadTargetDtoCWProxyImpl
    implements _$SignedUploadTargetDtoCWProxy {
  const _$SignedUploadTargetDtoCWProxyImpl(this._value);

  final SignedUploadTargetDto _value;

  @override
  SignedUploadTargetDto method(String method) => this(method: method);

  @override
  SignedUploadTargetDto url(String url) => this(url: url);

  @override
  SignedUploadTargetDto expiresAt(String expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  SignedUploadTargetDto headers(Map<String, String> headers) =>
      this(headers: headers);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SignedUploadTargetDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SignedUploadTargetDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SignedUploadTargetDto call({
    Object? method = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? headers = const $CopyWithPlaceholder(),
  }) {
    return SignedUploadTargetDto(
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as String,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as String,
      headers: headers == const $CopyWithPlaceholder()
          ? _value.headers
          // ignore: cast_nullable_to_non_nullable
          : headers as Map<String, String>,
    );
  }
}

extension $SignedUploadTargetDtoCopyWith on SignedUploadTargetDto {
  /// Returns a callable class that can be used as follows: `instanceOfSignedUploadTargetDto.copyWith(...)` or like so:`instanceOfSignedUploadTargetDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SignedUploadTargetDtoCWProxy get copyWith =>
      _$SignedUploadTargetDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignedUploadTargetDto _$SignedUploadTargetDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SignedUploadTargetDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['method', 'url', 'expiresAt', 'headers'],
  );
  final val = SignedUploadTargetDto(
    method: $checkedConvert('method', (v) => v as String),
    url: $checkedConvert('url', (v) => v as String),
    expiresAt: $checkedConvert('expiresAt', (v) => v as String),
    headers: $checkedConvert(
      'headers',
      (v) => Map<String, String>.from(v as Map),
    ),
  );
  return val;
});

Map<String, dynamic> _$SignedUploadTargetDtoToJson(
  SignedUploadTargetDto instance,
) => <String, dynamic>{
  'method': instance.method,
  'url': instance.url,
  'expiresAt': instance.expiresAt,
  'headers': instance.headers,
};
