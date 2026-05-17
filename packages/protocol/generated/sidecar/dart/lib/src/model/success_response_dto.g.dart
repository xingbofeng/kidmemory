// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SuccessResponseDtoCWProxy {
  SuccessResponseDto success(bool success);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SuccessResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SuccessResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SuccessResponseDto call({bool success});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSuccessResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSuccessResponseDto.copyWith.fieldName(...)`
class _$SuccessResponseDtoCWProxyImpl implements _$SuccessResponseDtoCWProxy {
  const _$SuccessResponseDtoCWProxyImpl(this._value);

  final SuccessResponseDto _value;

  @override
  SuccessResponseDto success(bool success) => this(success: success);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SuccessResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SuccessResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SuccessResponseDto call({Object? success = const $CopyWithPlaceholder()}) {
    return SuccessResponseDto(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool,
    );
  }
}

extension $SuccessResponseDtoCopyWith on SuccessResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfSuccessResponseDto.copyWith(...)` or like so:`instanceOfSuccessResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SuccessResponseDtoCWProxy get copyWith =>
      _$SuccessResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuccessResponseDto _$SuccessResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SuccessResponseDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['success']);
      final val = SuccessResponseDto(
        success: $checkedConvert('success', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$SuccessResponseDtoToJson(SuccessResponseDto instance) =>
    <String, dynamic>{'success': instance.success};
