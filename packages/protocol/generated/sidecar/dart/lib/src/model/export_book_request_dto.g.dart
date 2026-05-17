// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_book_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportBookRequestDtoCWProxy {
  ExportBookRequestDto targetPath(String targetPath);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportBookRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportBookRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportBookRequestDto call({String targetPath});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportBookRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportBookRequestDto.copyWith.fieldName(...)`
class _$ExportBookRequestDtoCWProxyImpl
    implements _$ExportBookRequestDtoCWProxy {
  const _$ExportBookRequestDtoCWProxyImpl(this._value);

  final ExportBookRequestDto _value;

  @override
  ExportBookRequestDto targetPath(String targetPath) =>
      this(targetPath: targetPath);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportBookRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportBookRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportBookRequestDto call({
    Object? targetPath = const $CopyWithPlaceholder(),
  }) {
    return ExportBookRequestDto(
      targetPath: targetPath == const $CopyWithPlaceholder()
          ? _value.targetPath
          // ignore: cast_nullable_to_non_nullable
          : targetPath as String,
    );
  }
}

extension $ExportBookRequestDtoCopyWith on ExportBookRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfExportBookRequestDto.copyWith(...)` or like so:`instanceOfExportBookRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportBookRequestDtoCWProxy get copyWith =>
      _$ExportBookRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportBookRequestDto _$ExportBookRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExportBookRequestDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['targetPath']);
  final val = ExportBookRequestDto(
    targetPath: $checkedConvert('targetPath', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ExportBookRequestDtoToJson(
  ExportBookRequestDto instance,
) => <String, dynamic>{'targetPath': instance.targetPath};
