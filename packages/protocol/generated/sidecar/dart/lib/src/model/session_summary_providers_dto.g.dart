// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_summary_providers_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionSummaryProvidersDtoCWProxy {
  SessionSummaryProvidersDto lan(SessionSummaryProvidersDtoLan? lan);

  SessionSummaryProvidersDto supabase(
    SessionSummaryProvidersDtoSupabase? supabase,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryProvidersDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryProvidersDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryProvidersDto call({
    SessionSummaryProvidersDtoLan? lan,
    SessionSummaryProvidersDtoSupabase? supabase,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionSummaryProvidersDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionSummaryProvidersDto.copyWith.fieldName(...)`
class _$SessionSummaryProvidersDtoCWProxyImpl
    implements _$SessionSummaryProvidersDtoCWProxy {
  const _$SessionSummaryProvidersDtoCWProxyImpl(this._value);

  final SessionSummaryProvidersDto _value;

  @override
  SessionSummaryProvidersDto lan(SessionSummaryProvidersDtoLan? lan) =>
      this(lan: lan);

  @override
  SessionSummaryProvidersDto supabase(
    SessionSummaryProvidersDtoSupabase? supabase,
  ) => this(supabase: supabase);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryProvidersDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryProvidersDto(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryProvidersDto call({
    Object? lan = const $CopyWithPlaceholder(),
    Object? supabase = const $CopyWithPlaceholder(),
  }) {
    return SessionSummaryProvidersDto(
      lan: lan == const $CopyWithPlaceholder()
          ? _value.lan
          // ignore: cast_nullable_to_non_nullable
          : lan as SessionSummaryProvidersDtoLan?,
      supabase: supabase == const $CopyWithPlaceholder()
          ? _value.supabase
          // ignore: cast_nullable_to_non_nullable
          : supabase as SessionSummaryProvidersDtoSupabase?,
    );
  }
}

extension $SessionSummaryProvidersDtoCopyWith on SessionSummaryProvidersDto {
  /// Returns a callable class that can be used as follows: `instanceOfSessionSummaryProvidersDto.copyWith(...)` or like so:`instanceOfSessionSummaryProvidersDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionSummaryProvidersDtoCWProxy get copyWith =>
      _$SessionSummaryProvidersDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSummaryProvidersDto _$SessionSummaryProvidersDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SessionSummaryProvidersDto', json, ($checkedConvert) {
  final val = SessionSummaryProvidersDto(
    lan: $checkedConvert(
      'lan',
      (v) => v == null
          ? null
          : SessionSummaryProvidersDtoLan.fromJson(v as Map<String, dynamic>),
    ),
    supabase: $checkedConvert(
      'supabase',
      (v) => v == null
          ? null
          : SessionSummaryProvidersDtoSupabase.fromJson(
              v as Map<String, dynamic>,
            ),
    ),
  );
  return val;
});

Map<String, dynamic> _$SessionSummaryProvidersDtoToJson(
  SessionSummaryProvidersDto instance,
) => <String, dynamic>{
if (instance.lan?.toJson() != null) 'lan': instance.lan?.toJson(),
if (instance.supabase?.toJson() != null) 'supabase': instance.supabase?.toJson(),
};
