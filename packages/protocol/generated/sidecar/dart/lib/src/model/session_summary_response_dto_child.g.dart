// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_summary_response_dto_child.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionSummaryResponseDtoChildCWProxy {
  SessionSummaryResponseDtoChild id(String id);

  SessionSummaryResponseDtoChild displayName(String displayName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryResponseDtoChild(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryResponseDtoChild(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryResponseDtoChild call({String id, String displayName});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionSummaryResponseDtoChild.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionSummaryResponseDtoChild.copyWith.fieldName(...)`
class _$SessionSummaryResponseDtoChildCWProxyImpl
    implements _$SessionSummaryResponseDtoChildCWProxy {
  const _$SessionSummaryResponseDtoChildCWProxyImpl(this._value);

  final SessionSummaryResponseDtoChild _value;

  @override
  SessionSummaryResponseDtoChild id(String id) => this(id: id);

  @override
  SessionSummaryResponseDtoChild displayName(String displayName) =>
      this(displayName: displayName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionSummaryResponseDtoChild(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionSummaryResponseDtoChild(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionSummaryResponseDtoChild call({
    Object? id = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
  }) {
    return SessionSummaryResponseDtoChild(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String,
    );
  }
}

extension $SessionSummaryResponseDtoChildCopyWith
    on SessionSummaryResponseDtoChild {
  /// Returns a callable class that can be used as follows: `instanceOfSessionSummaryResponseDtoChild.copyWith(...)` or like so:`instanceOfSessionSummaryResponseDtoChild.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionSummaryResponseDtoChildCWProxy get copyWith =>
      _$SessionSummaryResponseDtoChildCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSummaryResponseDtoChild _$SessionSummaryResponseDtoChildFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SessionSummaryResponseDtoChild', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'displayName']);
  final val = SessionSummaryResponseDtoChild(
    id: $checkedConvert('id', (v) => v as String),
    displayName: $checkedConvert('displayName', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SessionSummaryResponseDtoChildToJson(
  SessionSummaryResponseDtoChild instance,
) => <String, dynamic>{'id': instance.id, 'displayName': instance.displayName};
