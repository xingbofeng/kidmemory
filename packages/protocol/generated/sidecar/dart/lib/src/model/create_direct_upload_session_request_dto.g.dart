// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_direct_upload_session_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateDirectUploadSessionRequestDtoCWProxy {
  CreateDirectUploadSessionRequestDto childId(String childId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateDirectUploadSessionRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateDirectUploadSessionRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateDirectUploadSessionRequestDto call({String childId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateDirectUploadSessionRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateDirectUploadSessionRequestDto.copyWith.fieldName(...)`
class _$CreateDirectUploadSessionRequestDtoCWProxyImpl
    implements _$CreateDirectUploadSessionRequestDtoCWProxy {
  const _$CreateDirectUploadSessionRequestDtoCWProxyImpl(this._value);

  final CreateDirectUploadSessionRequestDto _value;

  @override
  CreateDirectUploadSessionRequestDto childId(String childId) =>
      this(childId: childId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateDirectUploadSessionRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateDirectUploadSessionRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateDirectUploadSessionRequestDto call({
    Object? childId = const $CopyWithPlaceholder(),
  }) {
    return CreateDirectUploadSessionRequestDto(
      childId: childId == const $CopyWithPlaceholder()
          ? _value.childId
          // ignore: cast_nullable_to_non_nullable
          : childId as String,
    );
  }
}

extension $CreateDirectUploadSessionRequestDtoCopyWith
    on CreateDirectUploadSessionRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateDirectUploadSessionRequestDto.copyWith(...)` or like so:`instanceOfCreateDirectUploadSessionRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateDirectUploadSessionRequestDtoCWProxy get copyWith =>
      _$CreateDirectUploadSessionRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDirectUploadSessionRequestDto
_$CreateDirectUploadSessionRequestDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateDirectUploadSessionRequestDto', json, (
      $checkedConvert,
    ) {
      $checkKeys(json, requiredKeys: const ['childId']);
      final val = CreateDirectUploadSessionRequestDto(
        childId: $checkedConvert('childId', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CreateDirectUploadSessionRequestDtoToJson(
  CreateDirectUploadSessionRequestDto instance,
) => <String, dynamic>{'childId': instance.childId};
