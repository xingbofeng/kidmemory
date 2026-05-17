//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_asset_response_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAssetResponseDto {
  /// Returns a new [UpdateAssetResponseDto] instance.
  UpdateAssetResponseDto({

     this.ok,

     this.success,

     this.message,

     this.code,

     this.asset,
  });

  @JsonKey(

    name: r'ok',
    required: false,
    includeIfNull: false,
  )


  final bool? ok;



  @JsonKey(

    name: r'success',
    required: false,
    includeIfNull: false,
  )


  final bool? success;



  @JsonKey(

    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;



  @JsonKey(

    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



  @JsonKey(

    name: r'asset',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? asset;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateAssetResponseDto &&
      other.ok == ok &&
      other.success == success &&
      other.message == message &&
      other.code == code &&
      other.asset == asset;

    @override
    int get hashCode =>
        ok.hashCode +
        success.hashCode +
        message.hashCode +
        code.hashCode +
        asset.hashCode;

  factory UpdateAssetResponseDto.fromJson(Map<String, dynamic> json) => _$UpdateAssetResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAssetResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
