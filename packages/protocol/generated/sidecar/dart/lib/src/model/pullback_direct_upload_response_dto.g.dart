// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pullback_direct_upload_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullbackDirectUploadResponseDtoCWProxy {
  PullbackDirectUploadResponseDto sessionId(String sessionId);

  PullbackDirectUploadResponseDto results(
    List<PullbackDirectUploadItemResultDto> results,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullbackDirectUploadResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullbackDirectUploadResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PullbackDirectUploadResponseDto call({
    String sessionId,
    List<PullbackDirectUploadItemResultDto> results,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullbackDirectUploadResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullbackDirectUploadResponseDto.copyWith.fieldName(...)`
class _$PullbackDirectUploadResponseDtoCWProxyImpl
    implements _$PullbackDirectUploadResponseDtoCWProxy {
  const _$PullbackDirectUploadResponseDtoCWProxyImpl(this._value);

  final PullbackDirectUploadResponseDto _value;

  @override
  PullbackDirectUploadResponseDto sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  PullbackDirectUploadResponseDto results(
    List<PullbackDirectUploadItemResultDto> results,
  ) => this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullbackDirectUploadResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullbackDirectUploadResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PullbackDirectUploadResponseDto call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? results = const $CopyWithPlaceholder(),
  }) {
    return PullbackDirectUploadResponseDto(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<PullbackDirectUploadItemResultDto>,
    );
  }
}

extension $PullbackDirectUploadResponseDtoCopyWith
    on PullbackDirectUploadResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfPullbackDirectUploadResponseDto.copyWith(...)` or like so:`instanceOfPullbackDirectUploadResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullbackDirectUploadResponseDtoCWProxy get copyWith =>
      _$PullbackDirectUploadResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullbackDirectUploadResponseDto _$PullbackDirectUploadResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PullbackDirectUploadResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['sessionId', 'results']);
  final val = PullbackDirectUploadResponseDto(
    sessionId: $checkedConvert('sessionId', (v) => v as String),
    results: $checkedConvert(
      'results',
      (v) => (v as List<dynamic>)
          .map(
            (e) => PullbackDirectUploadItemResultDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$PullbackDirectUploadResponseDtoToJson(
  PullbackDirectUploadResponseDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'results': instance.results.map((e) => e.toJson()).toList(),
};
