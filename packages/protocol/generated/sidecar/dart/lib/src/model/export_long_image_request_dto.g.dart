// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_long_image_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportLongImageRequestDtoCWProxy {
  ExportLongImageRequestDto targetPath(String targetPath);

  ExportLongImageRequestDto format(String format);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportLongImageRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportLongImageRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportLongImageRequestDto call({String targetPath, String format});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportLongImageRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportLongImageRequestDto.copyWith.fieldName(...)`
class _$ExportLongImageRequestDtoCWProxyImpl
    implements _$ExportLongImageRequestDtoCWProxy {
  const _$ExportLongImageRequestDtoCWProxyImpl(this._value);

  final ExportLongImageRequestDto _value;

  @override
  ExportLongImageRequestDto targetPath(String targetPath) =>
      this(targetPath: targetPath);

  @override
  ExportLongImageRequestDto format(String format) => this(format: format);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportLongImageRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportLongImageRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportLongImageRequestDto call({
    Object? targetPath = const $CopyWithPlaceholder(),
    Object? format = const $CopyWithPlaceholder(),
  }) {
    return ExportLongImageRequestDto(
      targetPath: targetPath == const $CopyWithPlaceholder()
          ? _value.targetPath
          // ignore: cast_nullable_to_non_nullable
          : targetPath as String,
      format: format == const $CopyWithPlaceholder()
          ? _value.format
          // ignore: cast_nullable_to_non_nullable
          : format as String,
    );
  }
}

extension $ExportLongImageRequestDtoCopyWith on ExportLongImageRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfExportLongImageRequestDto.copyWith(...)` or like so:`instanceOfExportLongImageRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportLongImageRequestDtoCWProxy get copyWith =>
      _$ExportLongImageRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportLongImageRequestDto _$ExportLongImageRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExportLongImageRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['targetPath', 'format']);
  final val = ExportLongImageRequestDto(
    targetPath: $checkedConvert('targetPath', (v) => v as String),
    format: $checkedConvert('format', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ExportLongImageRequestDtoToJson(
  ExportLongImageRequestDto instance,
) => <String, dynamic>{
  'targetPath': instance.targetPath,
  'format': instance.format,
};
