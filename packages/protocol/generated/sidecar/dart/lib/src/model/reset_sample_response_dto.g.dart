// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_sample_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ResetSampleResponseDtoCWProxy {
  ResetSampleResponseDto ok(bool? ok);

  ResetSampleResponseDto success(bool? success);

  ResetSampleResponseDto message(String? message);

  ResetSampleResponseDto code(String? code);

  ResetSampleResponseDto deletedAssets(int? deletedAssets);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResetSampleResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResetSampleResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ResetSampleResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
    int? deletedAssets,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfResetSampleResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfResetSampleResponseDto.copyWith.fieldName(...)`
class _$ResetSampleResponseDtoCWProxyImpl
    implements _$ResetSampleResponseDtoCWProxy {
  const _$ResetSampleResponseDtoCWProxyImpl(this._value);

  final ResetSampleResponseDto _value;

  @override
  ResetSampleResponseDto ok(bool? ok) => this(ok: ok);

  @override
  ResetSampleResponseDto success(bool? success) => this(success: success);

  @override
  ResetSampleResponseDto message(String? message) => this(message: message);

  @override
  ResetSampleResponseDto code(String? code) => this(code: code);

  @override
  ResetSampleResponseDto deletedAssets(int? deletedAssets) =>
      this(deletedAssets: deletedAssets);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResetSampleResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResetSampleResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ResetSampleResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? deletedAssets = const $CopyWithPlaceholder(),
  }) {
    return ResetSampleResponseDto(
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
      deletedAssets: deletedAssets == const $CopyWithPlaceholder()
          ? _value.deletedAssets
          // ignore: cast_nullable_to_non_nullable
          : deletedAssets as int?,
    );
  }
}

extension $ResetSampleResponseDtoCopyWith on ResetSampleResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfResetSampleResponseDto.copyWith(...)` or like so:`instanceOfResetSampleResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ResetSampleResponseDtoCWProxy get copyWith =>
      _$ResetSampleResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResetSampleResponseDto _$ResetSampleResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ResetSampleResponseDto', json, ($checkedConvert) {
  final val = ResetSampleResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String?),
    deletedAssets: $checkedConvert(
      'deletedAssets',
      (v) => (v as num?)?.toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ResetSampleResponseDtoToJson(
  ResetSampleResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
if (instance.deletedAssets != null) 'deletedAssets': instance.deletedAssets,
};
