// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_sample_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportSampleResponseDtoCWProxy {
  ImportSampleResponseDto ok(bool? ok);

  ImportSampleResponseDto success(bool? success);

  ImportSampleResponseDto message(String? message);

  ImportSampleResponseDto code(String? code);

  ImportSampleResponseDto childId(String? childId);

  ImportSampleResponseDto assetCount(int? assetCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportSampleResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportSampleResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportSampleResponseDto call({
    bool? ok,
    bool? success,
    String? message,
    String? code,
    String? childId,
    int? assetCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportSampleResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportSampleResponseDto.copyWith.fieldName(...)`
class _$ImportSampleResponseDtoCWProxyImpl
    implements _$ImportSampleResponseDtoCWProxy {
  const _$ImportSampleResponseDtoCWProxyImpl(this._value);

  final ImportSampleResponseDto _value;

  @override
  ImportSampleResponseDto ok(bool? ok) => this(ok: ok);

  @override
  ImportSampleResponseDto success(bool? success) => this(success: success);

  @override
  ImportSampleResponseDto message(String? message) => this(message: message);

  @override
  ImportSampleResponseDto code(String? code) => this(code: code);

  @override
  ImportSampleResponseDto childId(String? childId) => this(childId: childId);

  @override
  ImportSampleResponseDto assetCount(int? assetCount) =>
      this(assetCount: assetCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportSampleResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportSampleResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportSampleResponseDto call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? childId = const $CopyWithPlaceholder(),
    Object? assetCount = const $CopyWithPlaceholder(),
  }) {
    return ImportSampleResponseDto(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool?,
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      childId: childId == const $CopyWithPlaceholder()
          ? _value.childId
          // ignore: cast_nullable_to_non_nullable
          : childId as String?,
      assetCount: assetCount == const $CopyWithPlaceholder()
          ? _value.assetCount
          // ignore: cast_nullable_to_non_nullable
          : assetCount as int?,
    );
  }
}

extension $ImportSampleResponseDtoCopyWith on ImportSampleResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfImportSampleResponseDto.copyWith(...)` or like so:`instanceOfImportSampleResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportSampleResponseDtoCWProxy get copyWith =>
      _$ImportSampleResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportSampleResponseDto _$ImportSampleResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportSampleResponseDto', json, ($checkedConvert) {
  final val = ImportSampleResponseDto(
    ok: $checkedConvert('ok', (v) => v as bool?),
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String?),
    childId: $checkedConvert('childId', (v) => v as String?),
    assetCount: $checkedConvert('assetCount', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$ImportSampleResponseDtoToJson(
  ImportSampleResponseDto instance,
) => <String, dynamic>{
if (instance.ok != null) 'ok': instance.ok,
if (instance.success != null) 'success': instance.success,
if (instance.message != null) 'message': instance.message,
if (instance.code != null) 'code': instance.code,
if (instance.childId != null) 'childId': instance.childId,
if (instance.assetCount != null) 'assetCount': instance.assetCount,
};
