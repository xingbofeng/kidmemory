// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artifact_share_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ArtifactShareResponseDtoCWProxy {
  ArtifactShareResponseDto ok(bool? ok);

  ArtifactShareResponseDto success(bool? success);

  ArtifactShareResponseDto message(String? message);

  ArtifactShareResponseDto code(String? code);

  ArtifactShareResponseDto url(String? url);

  ArtifactShareResponseDto text(String? text);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ArtifactShareResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ArtifactShareResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ArtifactShareResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
    String? url,
    String? text,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfArtifactShareResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfArtifactShareResponseDto.copyWith.fieldName(...)`
class _$ArtifactShareResponseDtoCWProxyImpl
    implements _$ArtifactShareResponseDtoCWProxy {
  const _$ArtifactShareResponseDtoCWProxyImpl(this._value);

  final ArtifactShareResponseDto _value;

  @override
  ArtifactShareResponseDto ok(bool? ok) => this(ok: ok);

  @override
  ArtifactShareResponseDto success(bool? success) => this(success: success);

  @override
  ArtifactShareResponseDto message(String? message) => this(message: message);

  @override
  ArtifactShareResponseDto code(String? code) => this(code: code);

  @override
  ArtifactShareResponseDto url(String? url) => this(url: url);

  @override
  ArtifactShareResponseDto text(String? text) => this(text: text);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ArtifactShareResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ArtifactShareResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ArtifactShareResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
  }) {
    return ArtifactShareResponseDto(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool?,
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String?,
    );
  }
}

extension $ArtifactShareResponseDtoCopyWith on ArtifactShareResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfArtifactShareResponseDto.copyWith(...)` or like so:`instanceOfArtifactShareResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ArtifactShareResponseDtoCWProxy get copyWith =>
      _$ArtifactShareResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtifactShareResponseDto _$ArtifactShareResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ArtifactShareResponseDto', json, ($checkedConvert) {
  final val = ArtifactShareResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String?),
    url: $checkedConvert('url', (v) => v as String?),
    text: $checkedConvert('text', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ArtifactShareResponseDtoToJson(
  ArtifactShareResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
if (instance.url != null) 'url': instance.url,
if (instance.text != null) 'text': instance.text,
};
