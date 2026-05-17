// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ensure_child_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnsureChildResponseDtoCWProxy {
  EnsureChildResponseDto child(ChildRecordResponseDto? child);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnsureChildResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnsureChildResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  EnsureChildResponseDto call({ChildRecordResponseDto? child});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnsureChildResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnsureChildResponseDto.copyWith.fieldName(...)`
class _$EnsureChildResponseDtoCWProxyImpl
    implements _$EnsureChildResponseDtoCWProxy {
  const _$EnsureChildResponseDtoCWProxyImpl(this._value);

  final EnsureChildResponseDto _value;

  @override
  EnsureChildResponseDto child(ChildRecordResponseDto? child) =>
      this(child: child);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnsureChildResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnsureChildResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  EnsureChildResponseDto call({Object? child = const $CopyWithPlaceholder()}) {
    return EnsureChildResponseDto(
      child: child == const $CopyWithPlaceholder()
          ? _value.child
          // ignore: cast_nullable_to_non_nullable
          : child as ChildRecordResponseDto?,
    );
  }
}

extension $EnsureChildResponseDtoCopyWith on EnsureChildResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfEnsureChildResponseDto.copyWith(...)` or like so:`instanceOfEnsureChildResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnsureChildResponseDtoCWProxy get copyWith =>
      _$EnsureChildResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnsureChildResponseDto _$EnsureChildResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EnsureChildResponseDto', json, ($checkedConvert) {
  final val = EnsureChildResponseDto(
    child: $checkedConvert(
      'child',
      (v) => v == null
          ? null
          : ChildRecordResponseDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$EnsureChildResponseDtoToJson(
  EnsureChildResponseDto instance,
) => <String, dynamic>{'child': instance.child?.toJson()};
