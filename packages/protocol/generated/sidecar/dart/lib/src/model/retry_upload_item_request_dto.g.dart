// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retry_upload_item_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RetryUploadItemRequestDtoCWProxy {
  RetryUploadItemRequestDto token(String token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RetryUploadItemRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RetryUploadItemRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  RetryUploadItemRequestDto call({String token});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRetryUploadItemRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRetryUploadItemRequestDto.copyWith.fieldName(...)`
class _$RetryUploadItemRequestDtoCWProxyImpl
    implements _$RetryUploadItemRequestDtoCWProxy {
  const _$RetryUploadItemRequestDtoCWProxyImpl(this._value);

  final RetryUploadItemRequestDto _value;

  @override
  RetryUploadItemRequestDto token(String token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RetryUploadItemRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RetryUploadItemRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  RetryUploadItemRequestDto call({
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return RetryUploadItemRequestDto(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
    );
  }
}

extension $RetryUploadItemRequestDtoCopyWith on RetryUploadItemRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfRetryUploadItemRequestDto.copyWith(...)` or like so:`instanceOfRetryUploadItemRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RetryUploadItemRequestDtoCWProxy get copyWith =>
      _$RetryUploadItemRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetryUploadItemRequestDto _$RetryUploadItemRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RetryUploadItemRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['token']);
  final val = RetryUploadItemRequestDto(
    token: $checkedConvert('token', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$RetryUploadItemRequestDtoToJson(
  RetryUploadItemRequestDto instance,
) => <String, dynamic>{'token': instance.token};
