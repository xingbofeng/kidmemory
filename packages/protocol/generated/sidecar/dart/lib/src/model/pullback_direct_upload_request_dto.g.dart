// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pullback_direct_upload_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullbackDirectUploadRequestDtoCWProxy {
  PullbackDirectUploadRequestDto objectKeys(List<String>? objectKeys);

  PullbackDirectUploadRequestDto token(String? token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullbackDirectUploadRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullbackDirectUploadRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PullbackDirectUploadRequestDto call({
    List<String>? objectKeys,
    String? token,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullbackDirectUploadRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullbackDirectUploadRequestDto.copyWith.fieldName(...)`
class _$PullbackDirectUploadRequestDtoCWProxyImpl
    implements _$PullbackDirectUploadRequestDtoCWProxy {
  const _$PullbackDirectUploadRequestDtoCWProxyImpl(this._value);

  final PullbackDirectUploadRequestDto _value;

  @override
  PullbackDirectUploadRequestDto objectKeys(List<String>? objectKeys) =>
      this(objectKeys: objectKeys);

  @override
  PullbackDirectUploadRequestDto token(String? token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullbackDirectUploadRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullbackDirectUploadRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PullbackDirectUploadRequestDto call({
    Object? objectKeys = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return PullbackDirectUploadRequestDto(
      objectKeys: objectKeys == const $CopyWithPlaceholder()
          ? _value.objectKeys
          // ignore: cast_nullable_to_non_nullable
          : objectKeys as List<String>?,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String?,
    );
  }
}

extension $PullbackDirectUploadRequestDtoCopyWith
    on PullbackDirectUploadRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfPullbackDirectUploadRequestDto.copyWith(...)` or like so:`instanceOfPullbackDirectUploadRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullbackDirectUploadRequestDtoCWProxy get copyWith =>
      _$PullbackDirectUploadRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullbackDirectUploadRequestDto _$PullbackDirectUploadRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PullbackDirectUploadRequestDto', json, ($checkedConvert) {
  final val = PullbackDirectUploadRequestDto(
    objectKeys: $checkedConvert(
      'objectKeys',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    token: $checkedConvert('token', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$PullbackDirectUploadRequestDtoToJson(
  PullbackDirectUploadRequestDto instance,
) => <String, dynamic>{
if (instance.objectKeys != null) 'objectKeys': instance.objectKeys,
if (instance.token != null) 'token': instance.token,
};
