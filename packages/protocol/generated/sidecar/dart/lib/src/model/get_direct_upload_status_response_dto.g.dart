// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_direct_upload_status_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GetDirectUploadStatusResponseDtoCWProxy {
  GetDirectUploadStatusResponseDto sessionId(String sessionId);

  GetDirectUploadStatusResponseDto items(List<DirectUploadStatusItemDto> items);

  GetDirectUploadStatusResponseDto summary(
    DirectUploadStatusSummaryDto summary,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GetDirectUploadStatusResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GetDirectUploadStatusResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  GetDirectUploadStatusResponseDto call({
    String sessionId,
    List<DirectUploadStatusItemDto> items,
    DirectUploadStatusSummaryDto summary,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGetDirectUploadStatusResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGetDirectUploadStatusResponseDto.copyWith.fieldName(...)`
class _$GetDirectUploadStatusResponseDtoCWProxyImpl
    implements _$GetDirectUploadStatusResponseDtoCWProxy {
  const _$GetDirectUploadStatusResponseDtoCWProxyImpl(this._value);

  final GetDirectUploadStatusResponseDto _value;

  @override
  GetDirectUploadStatusResponseDto sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  GetDirectUploadStatusResponseDto items(
    List<DirectUploadStatusItemDto> items,
  ) => this(items: items);

  @override
  GetDirectUploadStatusResponseDto summary(
    DirectUploadStatusSummaryDto summary,
  ) => this(summary: summary);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GetDirectUploadStatusResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GetDirectUploadStatusResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  GetDirectUploadStatusResponseDto call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
  }) {
    return GetDirectUploadStatusResponseDto(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<DirectUploadStatusItemDto>,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as DirectUploadStatusSummaryDto,
    );
  }
}

extension $GetDirectUploadStatusResponseDtoCopyWith
    on GetDirectUploadStatusResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfGetDirectUploadStatusResponseDto.copyWith(...)` or like so:`instanceOfGetDirectUploadStatusResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GetDirectUploadStatusResponseDtoCWProxy get copyWith =>
      _$GetDirectUploadStatusResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetDirectUploadStatusResponseDto _$GetDirectUploadStatusResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GetDirectUploadStatusResponseDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['sessionId', 'items', 'summary']);
  final val = GetDirectUploadStatusResponseDto(
    sessionId: $checkedConvert('sessionId', (v) => v as String),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) =>
                DirectUploadStatusItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    summary: $checkedConvert(
      'summary',
      (v) => DirectUploadStatusSummaryDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GetDirectUploadStatusResponseDtoToJson(
  GetDirectUploadStatusResponseDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'summary': instance.summary.toJson(),
};
