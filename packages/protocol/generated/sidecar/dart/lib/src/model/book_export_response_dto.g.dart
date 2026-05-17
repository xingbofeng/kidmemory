// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_export_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BookExportResponseDtoCWProxy {
  BookExportResponseDto exported(ExportedPayloadResponseDto? exported);

  BookExportResponseDto artifact(ArtifactRefResponseDto? artifact);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookExportResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookExportResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  BookExportResponseDto call({
    ExportedPayloadResponseDto? exported,
    ArtifactRefResponseDto? artifact,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBookExportResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBookExportResponseDto.copyWith.fieldName(...)`
class _$BookExportResponseDtoCWProxyImpl
    implements _$BookExportResponseDtoCWProxy {
  const _$BookExportResponseDtoCWProxyImpl(this._value);

  final BookExportResponseDto _value;

  @override
  BookExportResponseDto exported(ExportedPayloadResponseDto? exported) =>
      this(exported: exported);

  @override
  BookExportResponseDto artifact(ArtifactRefResponseDto? artifact) =>
      this(artifact: artifact);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookExportResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookExportResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  BookExportResponseDto call({
    Object? exported = const $CopyWithPlaceholder(),
    Object? artifact = const $CopyWithPlaceholder(),
  }) {
    return BookExportResponseDto(
      exported: exported == const $CopyWithPlaceholder()
          ? _value.exported
          // ignore: cast_nullable_to_non_nullable
          : exported as ExportedPayloadResponseDto?,
      artifact: artifact == const $CopyWithPlaceholder()
          ? _value.artifact
          // ignore: cast_nullable_to_non_nullable
          : artifact as ArtifactRefResponseDto?,
    );
  }
}

extension $BookExportResponseDtoCopyWith on BookExportResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfBookExportResponseDto.copyWith(...)` or like so:`instanceOfBookExportResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BookExportResponseDtoCWProxy get copyWith =>
      _$BookExportResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookExportResponseDto _$BookExportResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BookExportResponseDto', json, ($checkedConvert) {
  final val = BookExportResponseDto(
    exported: $checkedConvert(
      'exported',
      (v) => v == null
          ? null
          : ExportedPayloadResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    artifact: $checkedConvert(
      'artifact',
      (v) => v == null
          ? null
          : ArtifactRefResponseDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$BookExportResponseDtoToJson(
  BookExportResponseDto instance,
) => <String, dynamic>{
if (instance.exported?.toJson() != null) 'exported': instance.exported?.toJson(),
if (instance.artifact?.toJson() != null) 'artifact': instance.artifact?.toJson(),
};
