import 'package:kidmemory_protocol/src/model/direct_upload_controller_create_session201_response.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_create_session_request.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_get_session_config200_response.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_get_status200_response.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_get_status200_response_items_inner.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_get_status200_response_summary.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_list_objects200_response.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_list_objects200_response_objects_inner.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_pullback201_response.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_pullback201_response_results_inner.dart';
import 'package:kidmemory_protocol/src/model/direct_upload_controller_pullback_request.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_close_session201_response.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_commit_upload_item200_response.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_commit_upload_item_request.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_create_session201_response.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_create_session_request.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_create_upload_items201_response.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_create_upload_items201_response_items_inner.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_create_upload_items201_response_items_inner_signed_upload.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_create_upload_items_request.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_create_upload_items_request_files_inner.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_get_recent_uploads200_response_inner.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_get_session_detail200_response.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_get_session_detail200_response_items_inner.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_get_session_summary200_response.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_get_session_summary200_response_child.dart';
import 'package:kidmemory_protocol/src/model/web_companion_controller_retry_upload_item_request.dart';

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
        case 'DirectUploadControllerCreateSession201Response':
          return DirectUploadControllerCreateSession201Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerCreateSessionRequest':
          return DirectUploadControllerCreateSessionRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerGetSessionConfig200Response':
          return DirectUploadControllerGetSessionConfig200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerGetStatus200Response':
          return DirectUploadControllerGetStatus200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerGetStatus200ResponseItemsInner':
          return DirectUploadControllerGetStatus200ResponseItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerGetStatus200ResponseSummary':
          return DirectUploadControllerGetStatus200ResponseSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerListObjects200Response':
          return DirectUploadControllerListObjects200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerListObjects200ResponseObjectsInner':
          return DirectUploadControllerListObjects200ResponseObjectsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerPullback201Response':
          return DirectUploadControllerPullback201Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerPullback201ResponseResultsInner':
          return DirectUploadControllerPullback201ResponseResultsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DirectUploadControllerPullbackRequest':
          return DirectUploadControllerPullbackRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCloseSession201Response':
          return WebCompanionControllerCloseSession201Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCommitUploadItem200Response':
          return WebCompanionControllerCommitUploadItem200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCommitUploadItemRequest':
          return WebCompanionControllerCommitUploadItemRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCreateSession201Response':
          return WebCompanionControllerCreateSession201Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCreateSessionRequest':
          return WebCompanionControllerCreateSessionRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCreateUploadItems201Response':
          return WebCompanionControllerCreateUploadItems201Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCreateUploadItems201ResponseItemsInner':
          return WebCompanionControllerCreateUploadItems201ResponseItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload':
          return WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCreateUploadItemsRequest':
          return WebCompanionControllerCreateUploadItemsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerCreateUploadItemsRequestFilesInner':
          return WebCompanionControllerCreateUploadItemsRequestFilesInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerGetRecentUploads200ResponseInner':
          return WebCompanionControllerGetRecentUploads200ResponseInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerGetSessionDetail200Response':
          return WebCompanionControllerGetSessionDetail200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerGetSessionDetail200ResponseItemsInner':
          return WebCompanionControllerGetSessionDetail200ResponseItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerGetSessionSummary200Response':
          return WebCompanionControllerGetSessionSummary200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerGetSessionSummary200ResponseChild':
          return WebCompanionControllerGetSessionSummary200ResponseChild.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WebCompanionControllerRetryUploadItemRequest':
          return WebCompanionControllerRetryUploadItemRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
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