// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_upload_items_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateUploadItemsRequestDtoCWProxy {
  CreateUploadItemsRequestDto token(String token);

  CreateUploadItemsRequestDto files(List<CreateUploadItemFileDto> files);

  CreateUploadItemsRequestDto provider(String provider);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateUploadItemsRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateUploadItemsRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateUploadItemsRequestDto call({
    String token,
    List<CreateUploadItemFileDto> files,
    String provider,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateUploadItemsRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateUploadItemsRequestDto.copyWith.fieldName(...)`
class _$CreateUploadItemsRequestDtoCWProxyImpl
    implements _$CreateUploadItemsRequestDtoCWProxy {
  const _$CreateUploadItemsRequestDtoCWProxyImpl(this._value);

  final CreateUploadItemsRequestDto _value;

  @override
  CreateUploadItemsRequestDto token(String token) => this(token: token);

  @override
  CreateUploadItemsRequestDto files(List<CreateUploadItemFileDto> files) =>
      this(files: files);

  @override
  CreateUploadItemsRequestDto provider(String provider) =>
      this(provider: provider);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateUploadItemsRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateUploadItemsRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateUploadItemsRequestDto call({
    Object? token = const $CopyWithPlaceholder(),
    Object? files = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
  }) {
    return CreateUploadItemsRequestDto(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<CreateUploadItemFileDto>,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as String,
    );
  }
}

extension $CreateUploadItemsRequestDtoCopyWith on CreateUploadItemsRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateUploadItemsRequestDto.copyWith(...)` or like so:`instanceOfCreateUploadItemsRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateUploadItemsRequestDtoCWProxy get copyWith =>
      _$CreateUploadItemsRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUploadItemsRequestDto _$CreateUploadItemsRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateUploadItemsRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['token', 'files', 'provider']);
  final val = CreateUploadItemsRequestDto(
    token: $checkedConvert('token', (v) => v as String),
    files: $checkedConvert(
      'files',
      (v) => (v as List<dynamic>)
          .map(
            (e) => CreateUploadItemFileDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    provider: $checkedConvert('provider', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$CreateUploadItemsRequestDtoToJson(
  CreateUploadItemsRequestDto instance,
) => <String, dynamic>{
  'token': instance.token,
  'files': instance.files.map((e) => e.toJson()).toList(),
  'provider': instance.provider,
};
