import 'package:kidmemory_protocol/src/model/commit_upload_item_request_dto.dart';
import 'package:kidmemory_protocol/src/model/commit_upload_item_response_dto.dart';
import 'package:kidmemory_protocol/src/model/create_upload_file_dto.dart';
import 'package:kidmemory_protocol/src/model/create_upload_items_request_dto.dart';
import 'package:kidmemory_protocol/src/model/create_upload_items_response_dto.dart';
import 'package:kidmemory_protocol/src/model/created_upload_item_dto.dart';
import 'package:kidmemory_protocol/src/model/device_response_dto.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_config_response_dto.dart';
import 'package:kidmemory_protocol/src/model/job_response_dto.dart';
import 'package:kidmemory_protocol/src/model/register_device_request_dto.dart';
import 'package:kidmemory_protocol/src/model/session_summary_response_dto.dart';
import 'package:kidmemory_protocol/src/model/share_token_validation_response_dto.dart';
import 'package:kidmemory_protocol/src/model/shared_asset_dto.dart';
import 'package:kidmemory_protocol/src/model/shared_book_dto.dart';
import 'package:kidmemory_protocol/src/model/signed_upload_target_dto.dart';
import 'package:kidmemory_protocol/src/model/update_job_status_request_dto.dart';
import 'package:kidmemory_protocol/src/model/update_sync_status_request_dto.dart';
import 'package:kidmemory_protocol/src/model/upload_item_response_dto.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'CommitUploadItemRequestDto':
          return CommitUploadItemRequestDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommitUploadItemResponseDto':
          return CommitUploadItemResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateUploadFileDto':
          return CreateUploadFileDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateUploadItemsRequestDto':
          return CreateUploadItemsRequestDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateUploadItemsResponseDto':
          return CreateUploadItemsResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreatedUploadItemDto':
          return CreatedUploadItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeviceResponseDto':
          return DeviceResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadConfigResponseDto':
          return DirectUploadConfigResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'JobResponseDto':
          return JobResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RegisterDeviceRequestDto':
          return RegisterDeviceRequestDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SessionSummaryResponseDto':
          return SessionSummaryResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShareTokenValidationResponseDto':
          return ShareTokenValidationResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SharedAssetDto':
          return SharedAssetDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SharedBookDto':
          return SharedBookDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SignedUploadTargetDto':
          return SignedUploadTargetDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateJobStatusRequestDto':
          return UpdateJobStatusRequestDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateSyncStatusRequestDto':
          return UpdateSyncStatusRequestDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UploadItemResponseDto':
          return UploadItemResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }