// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_session_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateSessionRequestDtoCWProxy {
  CreateSessionRequestDto childId(String childId);

  CreateSessionRequestDto expiresInMinutes(int? expiresInMinutes);

  CreateSessionRequestDto maxItems(int? maxItems);

  CreateSessionRequestDto preferredProviders(List<String>? preferredProviders);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateSessionRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateSessionRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateSessionRequestDto call({
    String childId,
    int? expiresInMinutes,
    int? maxItems,
    List<String>? preferredProviders,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateSessionRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateSessionRequestDto.copyWith.fieldName(...)`
class _$CreateSessionRequestDtoCWProxyImpl
    implements _$CreateSessionRequestDtoCWProxy {
  const _$CreateSessionRequestDtoCWProxyImpl(this._value);

  final CreateSessionRequestDto _value;

  @override
  CreateSessionRequestDto childId(String childId) => this(childId: childId);

  @override
  CreateSessionRequestDto expiresInMinutes(int? expiresInMinutes) =>
      this(expiresInMinutes: expiresInMinutes);

  @override
  CreateSessionRequestDto maxItems(int? maxItems) => this(maxItems: maxItems);

  @override
  CreateSessionRequestDto preferredProviders(
    List<String>? preferredProviders,
  ) => this(preferredProviders: preferredProviders);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateSessionRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateSessionRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateSessionRequestDto call({
    Object? childId = const $CopyWithPlaceholder(),
    Object? expiresInMinutes = const $CopyWithPlaceholder(),
    Object? maxItems = const $CopyWithPlaceholder(),
    Object? preferredProviders = const $CopyWithPlaceholder(),
  }) {
    return CreateSessionRequestDto(
      childId: childId == const $CopyWithPlaceholder()
          ? _value.childId
          // ignore: cast_nullable_to_non_nullable
          : childId as String,
      expiresInMinutes: expiresInMinutes == const $CopyWithPlaceholder()
          ? _value.expiresInMinutes
          // ignore: cast_nullable_to_non_nullable
          : expiresInMinutes as int?,
      maxItems: maxItems == const $CopyWithPlaceholder()
          ? _value.maxItems
          // ignore: cast_nullable_to_non_nullable
          : maxItems as int?,
      preferredProviders: preferredProviders == const $CopyWithPlaceholder()
          ? _value.preferredProviders
          // ignore: cast_nullable_to_non_nullable
          : preferredProviders as List<String>?,
    );
  }
}

extension $CreateSessionRequestDtoCopyWith on CreateSessionRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateSessionRequestDto.copyWith(...)` or like so:`instanceOfCreateSessionRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateSessionRequestDtoCWProxy get copyWith =>
      _$CreateSessionRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSessionRequestDto _$CreateSessionRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateSessionRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['childId']);
  final val = CreateSessionRequestDto(
    childId: $checkedConvert('childId', (v) => v as String),
    expiresInMinutes: $checkedConvert(
      'expiresInMinutes',
      (v) => (v as num?)?.toInt(),
    ),
    maxItems: $checkedConvert('maxItems', (v) => (v as num?)?.toInt()),
    preferredProviders: $checkedConvert(
      'preferredProviders',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$CreateSessionRequestDtoToJson(
  CreateSessionRequestDto instance,
) => <String, dynamic>{
  'childId': instance.childId,
if (instance.expiresInMinutes != null) 'expiresInMinutes': instance.expiresInMinutes,
if (instance.maxItems != null) 'maxItems': instance.maxItems,
if (instance.preferredProviders != null) 'preferredProviders': instance.preferredProviders,
};
