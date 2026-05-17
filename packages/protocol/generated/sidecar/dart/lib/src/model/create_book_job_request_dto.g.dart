// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_book_job_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateBookJobRequestDtoCWProxy {
  CreateBookJobRequestDto assetIds(List<String> assetIds);

  CreateBookJobRequestDto childId(String? childId);

  CreateBookJobRequestDto coverPolicy(String? coverPolicy);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateBookJobRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateBookJobRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateBookJobRequestDto call({
    List<String> assetIds,
    String? childId,
    String? coverPolicy,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateBookJobRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateBookJobRequestDto.copyWith.fieldName(...)`
class _$CreateBookJobRequestDtoCWProxyImpl
    implements _$CreateBookJobRequestDtoCWProxy {
  const _$CreateBookJobRequestDtoCWProxyImpl(this._value);

  final CreateBookJobRequestDto _value;

  @override
  CreateBookJobRequestDto assetIds(List<String> assetIds) =>
      this(assetIds: assetIds);

  @override
  CreateBookJobRequestDto childId(String? childId) => this(childId: childId);

  @override
  CreateBookJobRequestDto coverPolicy(String? coverPolicy) =>
      this(coverPolicy: coverPolicy);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateBookJobRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateBookJobRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateBookJobRequestDto call({
    Object? assetIds = const $CopyWithPlaceholder(),
    Object? childId = const $CopyWithPlaceholder(),
    Object? coverPolicy = const $CopyWithPlaceholder(),
  }) {
    return CreateBookJobRequestDto(
      assetIds: assetIds == const $CopyWithPlaceholder()
          ? _value.assetIds
          // ignore: cast_nullable_to_non_nullable
          : assetIds as List<String>,
      childId: childId == const $CopyWithPlaceholder()
          ? _value.childId
          // ignore: cast_nullable_to_non_nullable
          : childId as String?,
      coverPolicy: coverPolicy == const $CopyWithPlaceholder()
          ? _value.coverPolicy
          // ignore: cast_nullable_to_non_nullable
          : coverPolicy as String?,
    );
  }
}

extension $CreateBookJobRequestDtoCopyWith on CreateBookJobRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateBookJobRequestDto.copyWith(...)` or like so:`instanceOfCreateBookJobRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateBookJobRequestDtoCWProxy get copyWith =>
      _$CreateBookJobRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookJobRequestDto _$CreateBookJobRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateBookJobRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['assetIds']);
  final val = CreateBookJobRequestDto(
    assetIds: $checkedConvert(
      'assetIds',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    childId: $checkedConvert('childId', (v) => v as String?),
    coverPolicy: $checkedConvert('coverPolicy', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CreateBookJobRequestDtoToJson(
  CreateBookJobRequestDto instance,
) => <String, dynamic>{
  'assetIds': instance.assetIds,
if (instance.childId != null) 'childId': instance.childId,
if (instance.coverPolicy != null) 'coverPolicy': instance.coverPolicy,
};
