// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'children_list_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChildrenListResponseDtoCWProxy {
  ChildrenListResponseDto children(List<ChildRecordResponseDto>? children);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChildrenListResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChildrenListResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ChildrenListResponseDto call({List<ChildRecordResponseDto>? children});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChildrenListResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChildrenListResponseDto.copyWith.fieldName(...)`
class _$ChildrenListResponseDtoCWProxyImpl
    implements _$ChildrenListResponseDtoCWProxy {
  const _$ChildrenListResponseDtoCWProxyImpl(this._value);

  final ChildrenListResponseDto _value;

  @override
  ChildrenListResponseDto children(List<ChildRecordResponseDto>? children) =>
      this(children: children);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChildrenListResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChildrenListResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ChildrenListResponseDto call({
    Object? children = const $CopyWithPlaceholder(),
  }) {
    return ChildrenListResponseDto(
      children: children == const $CopyWithPlaceholder()
          ? _value.children
          // ignore: cast_nullable_to_non_nullable
          : children as List<ChildRecordResponseDto>?,
    );
  }
}

extension $ChildrenListResponseDtoCopyWith on ChildrenListResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfChildrenListResponseDto.copyWith(...)` or like so:`instanceOfChildrenListResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChildrenListResponseDtoCWProxy get copyWith =>
      _$ChildrenListResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChildrenListResponseDto _$ChildrenListResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ChildrenListResponseDto', json, ($checkedConvert) {
  final val = ChildrenListResponseDto(
    children: $checkedConvert(
      'children',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => ChildRecordResponseDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ChildrenListResponseDtoToJson(
  ChildrenListResponseDto instance,
) => <String, dynamic>{
if (instance.children?.map((e) => e.toJson()).toList() != null) 'children': instance.children?.map((e) => e.toJson()).toList(),
};
