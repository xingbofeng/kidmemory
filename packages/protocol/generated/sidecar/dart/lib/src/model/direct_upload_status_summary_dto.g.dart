// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_upload_status_summary_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DirectUploadStatusSummaryDtoCWProxy {
  DirectUploadStatusSummaryDto pendingRemote(int pendingRemote);

  DirectUploadStatusSummaryDto downloading(int downloading);

  DirectUploadStatusSummaryDto ready(int ready);

  DirectUploadStatusSummaryDto failed(int failed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DirectUploadStatusSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DirectUploadStatusSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  DirectUploadStatusSummaryDto call({
    int pendingRemote,
    int downloading,
    int ready,
    int failed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDirectUploadStatusSummaryDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDirectUploadStatusSummaryDto.copyWith.fieldName(...)`
class _$DirectUploadStatusSummaryDtoCWProxyImpl
    implements _$DirectUploadStatusSummaryDtoCWProxy {
  const _$DirectUploadStatusSummaryDtoCWProxyImpl(this._value);

  final DirectUploadStatusSummaryDto _value;

  @override
  DirectUploadStatusSummaryDto pendingRemote(int pendingRemote) =>
      this(pendingRemote: pendingRemote);

  @override
  DirectUploadStatusSummaryDto downloading(int downloading) =>
      this(downloading: downloading);

  @override
  DirectUploadStatusSummaryDto ready(int ready) => this(ready: ready);

  @override
  DirectUploadStatusSummaryDto failed(int failed) => this(failed: failed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DirectUploadStatusSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DirectUploadStatusSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  DirectUploadStatusSummaryDto call({
    Object? pendingRemote = const $CopyWithPlaceholder(),
    Object? downloading = const $CopyWithPlaceholder(),
    Object? ready = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
  }) {
    return DirectUploadStatusSummaryDto(
      pendingRemote: pendingRemote == const $CopyWithPlaceholder()
          ? _value.pendingRemote
          // ignore: cast_nullable_to_non_nullable
          : pendingRemote as int,
      downloading: downloading == const $CopyWithPlaceholder()
          ? _value.downloading
          // ignore: cast_nullable_to_non_nullable
          : downloading as int,
      ready: ready == const $CopyWithPlaceholder()
          ? _value.ready
          // ignore: cast_nullable_to_non_nullable
          : ready as int,
      failed: failed == const $CopyWithPlaceholder()
          ? _value.failed
          // ignore: cast_nullable_to_non_nullable
          : failed as int,
    );
  }
}

extension $DirectUploadStatusSummaryDtoCopyWith
    on DirectUploadStatusSummaryDto {
  /// Returns a callable class that can be used as follows: `instanceOfDirectUploadStatusSummaryDto.copyWith(...)` or like so:`instanceOfDirectUploadStatusSummaryDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DirectUploadStatusSummaryDtoCWProxy get copyWith =>
      _$DirectUploadStatusSummaryDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectUploadStatusSummaryDto _$DirectUploadStatusSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'DirectUploadStatusSummaryDto',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['pending_remote', 'downloading', 'ready', 'failed'],
    );
    final val = DirectUploadStatusSummaryDto(
      pendingRemote: $checkedConvert(
        'pending_remote',
        (v) => (v as num).toInt(),
      ),
      downloading: $checkedConvert('downloading', (v) => (v as num).toInt()),
      ready: $checkedConvert('ready', (v) => (v as num).toInt()),
      failed: $checkedConvert('failed', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {'pendingRemote': 'pending_remote'},
);

Map<String, dynamic> _$DirectUploadStatusSummaryDtoToJson(
  DirectUploadStatusSummaryDto instance,
) => <String, dynamic>{
  'pending_remote': instance.pendingRemote,
  'downloading': instance.downloading,
  'ready': instance.ready,
  'failed': instance.failed,
};
