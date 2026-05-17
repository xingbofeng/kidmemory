// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_summary_providers_dto_lan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionSummaryProvidersDtoLanCWProxy {
  SessionSummaryProvidersDtoLan available(bool? available);

  SessionSummaryProvidersDtoLan endpoint(String? endpoint);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryProvidersDtoLan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryProvidersDtoLan(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryProvidersDtoLan call({bool? available, String? endpoint});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionSummaryProvidersDtoLan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionSummaryProvidersDtoLan.copyWith.fieldName(...)`
class _$SessionSummaryProvidersDtoLanCWProxyImpl
    implements _$SessionSummaryProvidersDtoLanCWProxy {
  const _$SessionSummaryProvidersDtoLanCWProxyImpl(this._value);

  final SessionSummaryProvidersDtoLan _value;

  @override
  SessionSummaryProvidersDtoLan available(bool? available) =>
      this(available: available);

  @override
  SessionSummaryProvidersDtoLan endpoint(String? endpoint) =>
      this(endpoint: endpoint);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryProvidersDtoLan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryProvidersDtoLan(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryProvidersDtoLan call({
    Object? available = const $CopyWithPlaceholder(),
    Object? endpoint = const $CopyWithPlaceholder(),
  }) {
    return SessionSummaryProvidersDtoLan(
      available: available == const $CopyWithPlaceholder()
          ? _value.available
          // ignore: cast_nullable_to_non_nullable
          : available as bool?,
      endpoint: endpoint == const $CopyWithPlaceholder()
          ? _value.endpoint
          // ignore: cast_nullable_to_non_nullable
          : endpoint as String?,
    );
  }
}

extension $SessionSummaryProvidersDtoLanCopyWith
    on SessionSummaryProvidersDtoLan {
  /// Returns a callable class that can be used as follows: `instanceOfSessionSummaryProvidersDtoLan.copyWith(...)` or like so:`instanceOfSessionSummaryProvidersDtoLan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionSummaryProvidersDtoLanCWProxy get copyWith =>
      _$SessionSummaryProvidersDtoLanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSummaryProvidersDtoLan _$SessionSummaryProvidersDtoLanFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SessionSummaryProvidersDtoLan', json, ($checkedConvert) {
  final val = SessionSummaryProvidersDtoLan(
    available: $checkedConvert('available', (v) => v as bool?),
    endpoint: $checkedConvert('endpoint', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$SessionSummaryProvidersDtoLanToJson(
  SessionSummaryProvidersDtoLan instance,
) => <String, dynamic>{
if (instance.available != null) 'available': instance.available,
if (instance.endpoint != null) 'endpoint': instance.endpoint,
};
