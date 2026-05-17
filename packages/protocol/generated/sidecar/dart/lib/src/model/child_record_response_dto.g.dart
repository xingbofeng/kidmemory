// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_record_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChildRecordResponseDtoCWProxy {
  ChildRecordResponseDto id(String? id);

  ChildRecordResponseDto name(String? name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChildRecordResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChildRecordResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ChildRecordResponseDto call({String? id, String? name});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChildRecordResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChildRecordResponseDto.copyWith.fieldName(...)`
class _$ChildRecordResponseDtoCWProxyImpl
    implements _$ChildRecordResponseDtoCWProxy {
  const _$ChildRecordResponseDtoCWProxyImpl(this._value);

  final ChildRecordResponseDto _value;

  @override
  ChildRecordResponseDto id(String? id) => this(id: id);

  @override
  ChildRecordResponseDto name(String? name) => this(name: name);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChildRecordResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChildRecordResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ChildRecordResponseDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return ChildRecordResponseDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
    );
  }
}

extension $ChildRecordResponseDtoCopyWith on ChildRecordResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfChildRecordResponseDto.copyWith(...)` or like so:`instanceOfChildRecordResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChildRecordResponseDtoCWProxy get copyWith =>
      _$ChildRecordResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChildRecordResponseDto _$ChildRecordResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ChildRecordResponseDto', json, ($checkedConvert) {
  final val = ChildRecordResponseDto(
    id: $checkedConvert('id', (v) => v as String?),
    name: $checkedConvert('name', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ChildRecordResponseDtoToJson(
  ChildRecordResponseDto instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
