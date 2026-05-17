// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_summary_providers_dto_supabase.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionSummaryProvidersDtoSupabaseCWProxy {
  SessionSummaryProvidersDtoSupabase available(bool? available);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryProvidersDtoSupabase(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryProvidersDtoSupabase(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryProvidersDtoSupabase call({bool? available});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionSummaryProvidersDtoSupabase.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionSummaryProvidersDtoSupabase.copyWith.fieldName(...)`
class _$SessionSummaryProvidersDtoSupabaseCWProxyImpl
    implements _$SessionSummaryProvidersDtoSupabaseCWProxy {
  const _$SessionSummaryProvidersDtoSupabaseCWProxyImpl(this._value);

  final SessionSummaryProvidersDtoSupabase _value;

  @override
  SessionSummaryProvidersDtoSupabase available(bool? available) =>
      this(available: available);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryProvidersDtoSupabase(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryProvidersDtoSupabase(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryProvidersDtoSupabase call({
    Object? available = const $CopyWithPlaceholder(),
  }) {
    return SessionSummaryProvidersDtoSupabase(
      available: available == const $CopyWithPlaceholder()
          ? _value.available
          // ignore: cast_nullable_to_non_nullable
          : available as bool?,
    );
  }
}

extension $SessionSummaryProvidersDtoSupabaseCopyWith
    on SessionSummaryProvidersDtoSupabase {
  /// Returns a callable class that can be used as follows: `instanceOfSessionSummaryProvidersDtoSupabase.copyWith(...)` or like so:`instanceOfSessionSummaryProvidersDtoSupabase.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionSummaryProvidersDtoSupabaseCWProxy get copyWith =>
      _$SessionSummaryProvidersDtoSupabaseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSummaryProvidersDtoSupabase _$SessionSummaryProvidersDtoSupabaseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SessionSummaryProvidersDtoSupabase', json, (
  $checkedConvert,
) {
  final val = SessionSummaryProvidersDtoSupabase(
    available: $checkedConvert('available', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$SessionSummaryProvidersDtoSupabaseToJson(
  SessionSummaryProvidersDtoSupabase instance,
) => <String, dynamic>{'available': instance.available};
