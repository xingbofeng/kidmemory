// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'close_session_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CloseSessionRequestDtoCWProxy {
  CloseSessionRequestDto token(String token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CloseSessionRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CloseSessionRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CloseSessionRequestDto call({String token});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCloseSessionRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCloseSessionRequestDto.copyWith.fieldName(...)`
class _$CloseSessionRequestDtoCWProxyImpl
    implements _$CloseSessionRequestDtoCWProxy {
  const _$CloseSessionRequestDtoCWProxyImpl(this._value);

  final CloseSessionRequestDto _value;

  @override
  CloseSessionRequestDto token(String token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CloseSessionRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CloseSessionRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CloseSessionRequestDto call({Object? token = const $CopyWithPlaceholder()}) {
    return CloseSessionRequestDto(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
    );
  }
}

extension $CloseSessionRequestDtoCopyWith on CloseSessionRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfCloseSessionRequestDto.copyWith(...)` or like so:`instanceOfCloseSessionRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CloseSessionRequestDtoCWProxy get copyWith =>
      _$CloseSessionRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloseSessionRequestDto _$CloseSessionRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CloseSessionRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['token']);
  final val = CloseSessionRequestDto(
    token: $checkedConvert('token', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$CloseSessionRequestDtoToJson(
  CloseSessionRequestDto instance,
) => <String, dynamic>{'token': instance.token};
