// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_detail_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionDetailResponseDtoCWProxy {
  SessionDetailResponseDto sessionId(String sessionId);

  SessionDetailResponseDto items(List<UploadItemDetailDto> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionDetailResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionDetailResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionDetailResponseDto call({
    String sessionId,
    List<UploadItemDetailDto> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionDetailResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionDetailResponseDto.copyWith.fieldName(...)`
class _$SessionDetailResponseDtoCWProxyImpl
    implements _$SessionDetailResponseDtoCWProxy {
  const _$SessionDetailResponseDtoCWProxyImpl(this._value);

  final SessionDetailResponseDto _value;

  @override
  SessionDetailResponseDto sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  SessionDetailResponseDto items(List<UploadItemDetailDto> items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionDetailResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionDetailResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionDetailResponseDto call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return SessionDetailResponseDto(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<UploadItemDetailDto>,
    );
  }
}

extension $SessionDetailResponseDtoCopyWith on SessionDetailResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfSessionDetailResponseDto.copyWith(...)` or like so:`instanceOfSessionDetailResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionDetailResponseDtoCWProxy get copyWith =>
      _$SessionDetailResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionDetailResponseDto _$SessionDetailResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SessionDetailResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['sessionId', 'items']);
  final val = SessionDetailResponseDto(
    sessionId: $checkedConvert('sessionId', (v) => v as String),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => UploadItemDetailDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SessionDetailResponseDtoToJson(
  SessionDetailResponseDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
