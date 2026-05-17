// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artifact_ref_response_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ArtifactRefResponseDtoCWProxy {
  ArtifactRefResponseDto id(String? id);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ArtifactRefResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ArtifactRefResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ArtifactRefResponseDto call({String? id});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfArtifactRefResponseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfArtifactRefResponseDto.copyWith.fieldName(...)`
class _$ArtifactRefResponseDtoCWProxyImpl
    implements _$ArtifactRefResponseDtoCWProxy {
  const _$ArtifactRefResponseDtoCWProxyImpl(this._value);

  final ArtifactRefResponseDto _value;

  @override
  ArtifactRefResponseDto id(String? id) => this(id: id);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ArtifactRefResponseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ArtifactRefResponseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ArtifactRefResponseDto call({Object? id = const $CopyWithPlaceholder()}) {
    return ArtifactRefResponseDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
    );
  }
}

extension $ArtifactRefResponseDtoCopyWith on ArtifactRefResponseDto {
  /// Returns a callable class that can be used as follows: `instanceOfArtifactRefResponseDto.copyWith(...)` or like so:`instanceOfArtifactRefResponseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ArtifactRefResponseDtoCWProxy get copyWith =>
      _$ArtifactRefResponseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtifactRefResponseDto _$ArtifactRefResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ArtifactRefResponseDto', json, ($checkedConvert) {
  final val = ArtifactRefResponseDto(
    id: $checkedConvert('id', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ArtifactRefResponseDtoToJson(
  ArtifactRefResponseDto instance,
) => <String, dynamic>{'id': instance.id};
