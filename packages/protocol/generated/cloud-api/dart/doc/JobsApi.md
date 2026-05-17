# kidmemory_protocol.api.JobsApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:3002*

Method | HTTP request | Description
------------- | ------------- | -------------
[**jobsControllerGetPendingJobs**](JobsApi.md#jobscontrollergetpendingjobs) | **GET** /jobs/pending | Get pending jobs for device
[**jobsControllerUpdateStatus**](JobsApi.md#jobscontrollerupdatestatus) | **PUT** /jobs/{id}/status | Update job status


# **jobsControllerGetPendingJobs**
> jobsControllerGetPendingJobs(limit, deviceId)

Get pending jobs for device

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getJobsApi();
final num limit = 8.14; // num | Maximum jobs to return
final Object deviceId = ; // Object | Filter by device ID (null = unassigned)

try {
    api.jobsControllerGetPendingJobs(limit, deviceId);
} on DioException catch (e) {
    print('Exception when calling JobsApi->jobsControllerGetPendingJobs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **num**| Maximum jobs to return | [optional] 
 **deviceId** | [**Object**](.md)| Filter by device ID (null = unassigned) | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **jobsControllerUpdateStatus**
> jobsControllerUpdateStatus(id)

Update job status

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getJobsApi();
final String id = id_example; // String | 

try {
    api.jobsControllerUpdateStatus(id);
} on DioException catch (e) {
    print('Exception when calling JobsApi->jobsControllerUpdateStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

