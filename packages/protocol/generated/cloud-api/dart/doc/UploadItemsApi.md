# kidmemory_protocol.api.UploadItemsApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:3002*

Method | HTTP request | Description
------------- | ------------- | -------------
[**uploadItemsControllerGetPendingSync**](UploadItemsApi.md#uploaditemscontrollergetpendingsync) | **GET** /upload-items/pending-sync | Get pending sync upload items
[**uploadItemsControllerUpdateSyncStatus**](UploadItemsApi.md#uploaditemscontrollerupdatesyncstatus) | **PUT** /upload-items/{id}/sync-status | Update upload item sync status


# **uploadItemsControllerGetPendingSync**
> List<UploadItemResponseDto> uploadItemsControllerGetPendingSync(offset, limit, deviceId)

Get pending sync upload items

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getUploadItemsApi();
final num offset = 8.14; // num | Number of items to skip
final num limit = 8.14; // num | Maximum items to return
final Object deviceId = ; // Object | Filter by device ID

try {
    final response = api.uploadItemsControllerGetPendingSync(offset, limit, deviceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UploadItemsApi->uploadItemsControllerGetPendingSync: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **offset** | **num**| Number of items to skip | [optional]
 **limit** | **num**| Maximum items to return | [optional]
 **deviceId** | [**Object**](.md)| Filter by device ID | [optional]

### Return type

[**List&lt;UploadItemResponseDto&gt;**](UploadItemResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadItemsControllerUpdateSyncStatus**
> UploadItemResponseDto uploadItemsControllerUpdateSyncStatus(id, updateSyncStatusRequestDto)

Update upload item sync status

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getUploadItemsApi();
final String id = id_example; // String |
final UpdateSyncStatusRequestDto updateSyncStatusRequestDto = ; // UpdateSyncStatusRequestDto |

try {
    final response = api.uploadItemsControllerUpdateSyncStatus(id, updateSyncStatusRequestDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UploadItemsApi->uploadItemsControllerUpdateSyncStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **updateSyncStatusRequestDto** | [**UpdateSyncStatusRequestDto**](UpdateSyncStatusRequestDto.md)|  |

### Return type

[**UploadItemResponseDto**](UploadItemResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
