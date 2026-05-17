// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'path_config_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PathConfigResponseDtoCWProxy {
  PathConfigResponseDto dataDir(String? dataDir);

  PathConfigResponseDto workspaceDir(String? workspaceDir);

  PathConfigResponseDto exportDir(String? exportDir);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PathConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PathConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PathConfigResponseDto call({
    String? dataDir,
    String? workspaceDir,
    String? exportDir,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPathConfigResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPathConfigResponseDto.copyWith.fieldName(...)`
class _$PathConfigResponseDtoCWProxyImpl
    implements _$PathConfigResponseDtoCWProxy {
  const _$PathConfigResponseDtoCWProxyImpl(this._value);

  final PathConfigResponseDto _value;

  @override
  PathConfigResponseDto dataDir(String? dataDir) => this(dataDir: dataDir);

  @override
  PathConfigResponseDto workspaceDir(String? workspaceDir) =>
      this(workspaceDir: workspaceDir);

  @override
  PathConfigResponseDto exportDir(String? exportDir) =>
      this(exportDir: exportDir);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PathConfigResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PathConfigResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PathConfigResponseDto call({
    Object? dataDir = const $CopyWithPlaceholder(),
    Object? workspaceDir = const $CopyWithPlaceholder(),
    Object? exportDir = const $CopyWithPlaceholder(),
  }) {
    return PathConfigResponseDto(
      dataDir: dataDir == const $CopyWithPlaceholder()
          ? _value.dataDir
          // ignore: cast_nullable_to_non_nullable
          : dataDir as String?,
      workspaceDir: workspaceDir == const $CopyWithPlaceholder()
          ? _value.workspaceDir
          // ignore: cast_nullable_to_non_nullable
          : workspaceDir as String?,
      exportDir: exportDir == const $CopyWithPlaceholder()
          ? _value.exportDir
          // ignore: cast_nullable_to_non_nullable
          : exportDir as String?,
    );
  }
}

extension $PathConfigResponseDtoCopyWith on PathConfigResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfPathConfigResponseDto.copyWith(...)` or like so:`instanceOfPathConfigResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PathConfigResponseDtoCWProxy get copyWith =>
      _$PathConfigResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathConfigResponseDto _$PathConfigResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PathConfigResponseDto', json, ($checkedConvert) {
  final val = PathConfigResponseDto(
    dataDir: $checkedConvert('dataDir', (v) => v as String?),
    workspaceDir: $checkedConvert('workspaceDir', (v) => v as String?),
    exportDir: $checkedConvert('exportDir', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$PathConfigResponseDtoToJson(
  PathConfigResponseDto instance,
) => <String, dynamic>{
if (instance.dataDir != null) 'dataDir': instance.dataDir,
if (instance.workspaceDir != null) 'workspaceDir': instance.workspaceDir,
if (instance.exportDir != null) 'exportDir': instance.exportDir,
};
