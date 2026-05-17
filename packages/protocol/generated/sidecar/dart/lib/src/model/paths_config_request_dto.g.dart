// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paths_config_request_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PathsConfigRequestDtoCWProxy {
  PathsConfigRequestDto dataDir(String dataDir);

  PathsConfigRequestDto workspaceDir(String workspaceDir);

  PathsConfigRequestDto exportDir(String exportDir);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PathsConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PathsConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PathsConfigRequestDto call({
    String dataDir,
    String workspaceDir,
    String exportDir,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPathsConfigRequestDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPathsConfigRequestDto.copyWith.fieldName(...)`
class _$PathsConfigRequestDtoCWProxyImpl
    implements _$PathsConfigRequestDtoCWProxy {
  const _$PathsConfigRequestDtoCWProxyImpl(this._value);

  final PathsConfigRequestDto _value;

  @override
  PathsConfigRequestDto dataDir(String dataDir) => this(dataDir: dataDir);

  @override
  PathsConfigRequestDto workspaceDir(String workspaceDir) =>
      this(workspaceDir: workspaceDir);

  @override
  PathsConfigRequestDto exportDir(String exportDir) =>
      this(exportDir: exportDir);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PathsConfigRequestDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PathsConfigRequestDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PathsConfigRequestDto call({
    Object? dataDir = const $CopyWithPlaceholder(),
    Object? workspaceDir = const $CopyWithPlaceholder(),
    Object? exportDir = const $CopyWithPlaceholder(),
  }) {
    return PathsConfigRequestDto(
      dataDir: dataDir == const $CopyWithPlaceholder()
          ? _value.dataDir
          // ignore: cast_nullable_to_non_nullable
          : dataDir as String,
      workspaceDir: workspaceDir == const $CopyWithPlaceholder()
          ? _value.workspaceDir
          // ignore: cast_nullable_to_non_nullable
          : workspaceDir as String,
      exportDir: exportDir == const $CopyWithPlaceholder()
          ? _value.exportDir
          // ignore: cast_nullable_to_non_nullable
          : exportDir as String,
    );
  }
}

extension $PathsConfigRequestDtoCopyWith on PathsConfigRequestDto {
  /// Returns a callable class that can be used as follows: `instanceOfPathsConfigRequestDto.copyWith(...)` or like so:`instanceOfPathsConfigRequestDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PathsConfigRequestDtoCWProxy get copyWith =>
      _$PathsConfigRequestDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathsConfigRequestDto _$PathsConfigRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PathsConfigRequestDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['dataDir', 'workspaceDir', 'exportDir'],
  );
  final val = PathsConfigRequestDto(
    dataDir: $checkedConvert('dataDir', (v) => v as String),
    workspaceDir: $checkedConvert('workspaceDir', (v) => v as String),
    exportDir: $checkedConvert('exportDir', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$PathsConfigRequestDtoToJson(
  PathsConfigRequestDto instance,
) => <String, dynamic>{
  'dataDir': instance.dataDir,
  'workspaceDir': instance.workspaceDir,
  'exportDir': instance.exportDir,
};
