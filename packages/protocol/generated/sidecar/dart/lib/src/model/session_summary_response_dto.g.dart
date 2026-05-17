// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_summary_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionSummaryResponseDtoCWProxy {
  SessionSummaryResponseDto sessionId(String sessionId);

  SessionSummaryResponseDto status(String status);

  SessionSummaryResponseDto child(SessionSummaryResponseDtoChild child);

  SessionSummaryResponseDto expiresAt(String expiresAt);

  SessionSummaryResponseDto maxItems(int maxItems);

  SessionSummaryResponseDto usedItems(int usedItems);

  SessionSummaryResponseDto providers(SessionSummaryProvidersDto providers);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryResponseDto call({
    String sessionId,
    String status,
    SessionSummaryResponseDtoChild child,
    String expiresAt,
    int maxItems,
    int usedItems,
    SessionSummaryProvidersDto providers,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionSummaryResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionSummaryResponseDto.copyWith.fieldName(...)`
class _$SessionSummaryResponseDtoCWProxyImpl
    implements _$SessionSummaryResponseDtoCWProxy {
  const _$SessionSummaryResponseDtoCWProxyImpl(this._value);

  final SessionSummaryResponseDto _value;

  @override
  SessionSummaryResponseDto sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  SessionSummaryResponseDto status(String status) => this(status: status);

  @override
  SessionSummaryResponseDto child(SessionSummaryResponseDtoChild child) =>
      this(child: child);

  @override
  SessionSummaryResponseDto expiresAt(String expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  SessionSummaryResponseDto maxItems(int maxItems) => this(maxItems: maxItems);

  @override
  SessionSummaryResponseDto usedItems(int usedItems) =>
      this(usedItems: usedItems);

  @override
  SessionSummaryResponseDto providers(SessionSummaryProvidersDto providers) =>
      this(providers: providers);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryResponseDto call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? child = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? maxItems = const $CopyWithPlaceholder(),
    Object? usedItems = const $CopyWithPlaceholder(),
    Object? providers = const $CopyWithPlaceholder(),
  }) {
    return SessionSummaryResponseDto(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      child: child == const $CopyWithPlaceholder()
          ? _value.child
          // ignore: cast_nullable_to_non_nullable
          : child as SessionSummaryResponseDtoChild,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as String,
      maxItems: maxItems == const $CopyWithPlaceholder()
          ? _value.maxItems
          // ignore: cast_nullable_to_non_nullable
          : maxItems as int,
      usedItems: usedItems == const $CopyWithPlaceholder()
          ? _value.usedItems
          // ignore: cast_nullable_to_non_nullable
          : usedItems as int,
      providers: providers == const $CopyWithPlaceholder()
          ? _value.providers
          // ignore: cast_nullable_to_non_nullable
          : providers as SessionSummaryProvidersDto,
    );
  }
}

extension $SessionSummaryResponseDtoCopyWith on SessionSummaryResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfSessionSummaryResponseDto.copyWith(...)` or like so:`instanceOfSessionSummaryResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionSummaryResponseDtoCWProxy get copyWith =>
      _$SessionSummaryResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSummaryResponseDto _$SessionSummaryResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SessionSummaryResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'sessionId',
      'status',
      'child',
      'expiresAt',
      'maxItems',
      'usedItems',
      'providers',
    ],
  );
  final val = SessionSummaryResponseDto(
    sessionId: $checkedConvert('sessionId', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    child: $checkedConvert(
      'child',
      (v) => SessionSummaryResponseDtoChild.fromJson(v as Map<String, dynamic>),
    ),
    expiresAt: $checkedConvert('expiresAt', (v) => v as String),
    maxItems: $checkedConvert('maxItems', (v) => (v as num).toInt()),
    usedItems: $checkedConvert('usedItems', (v) => (v as num).toInt()),
    providers: $checkedConvert(
      'providers',
      (v) => SessionSummaryProvidersDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SessionSummaryResponseDtoToJson(
  SessionSummaryResponseDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'status': instance.status,
  'child': instance.child.toJson(),
  'expiresAt': instance.expiresAt,
  'maxItems': instance.maxItems,
  'usedItems': instance.usedItems,
  'providers': instance.providers.toJson(),
};
