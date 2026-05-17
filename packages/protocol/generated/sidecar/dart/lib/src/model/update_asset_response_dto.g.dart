// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_asset_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateAssetResponseDtoCWProxy {
  UpdateAssetResponseDto ok(bool? ok);

  UpdateAssetResponseDto success(bool? success);

  UpdateAssetResponseDto message(String? message);

  UpdateAssetResponseDto code(String? code);

  UpdateAssetResponseDto asset(Map<String, Object>? asset);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateAssetResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateAssetResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateAssetResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
    Map<String, Object>? asset,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateAssetResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateAssetResponseDto.copyWith.fieldName(...)`
class _$UpdateAssetResponseDtoCWProxyImpl
    implements _$UpdateAssetResponseDtoCWProxy {
  const _$UpdateAssetResponseDtoCWProxyImpl(this._value);

  final UpdateAssetResponseDto _value;

  @override
  UpdateAssetResponseDto ok(bool? ok) => this(ok: ok);

  @override
  UpdateAssetResponseDto success(bool? success) => this(success: success);

  @override
  UpdateAssetResponseDto message(String? message) => this(message: message);

  @override
  UpdateAssetResponseDto code(String? code) => this(code: code);

  @override
  UpdateAssetResponseDto asset(Map<String, Object>? asset) =>
      this(asset: asset);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateAssetResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateAssetResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateAssetResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? asset = const $CopyWithPlaceholder(),
  }) {
    return UpdateAssetResponseDto(
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
      asset: asset == const $CopyWithPlaceholder()
          ? _value.asset
          // ignore: cast_nullable_to_non_nullable
          : asset as Map<String, Object>?,
    );
  }
}

extension $UpdateAssetResponseDtoCopyWith on UpdateAssetResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateAssetResponseDto.copyWith(...)` or like so:`instanceOfUpdateAssetResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateAssetResponseDtoCWProxy get copyWith =>
      _$UpdateAssetResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAssetResponseDto _$UpdateAssetResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateAssetResponseDto', json, ($checkedConvert) {
  final val = UpdateAssetResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String?),
    asset: $checkedConvert(
      'asset',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$UpdateAssetResponseDtoToJson(
  UpdateAssetResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
if (instance.asset != null) 'asset': instance.asset,
};
