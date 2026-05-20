# kidmemory_protocol.api.CreationApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:4317*

Method | HTTP request | Description
------------- | ------------- | -------------
[**creationControllerCreateJob**](CreationApi.md#creationcontrollercreatejob) | **POST** /creation/jobs | 
[**creationControllerCreatePlan**](CreationApi.md#creationcontrollercreateplan) | **POST** /creation/jobs/plan | 
[**creationControllerExportJob**](CreationApi.md#creationcontrollerexportjob) | **POST** /creation/jobs/{jobId}/export | 
[**creationControllerGetEvents**](CreationApi.md#creationcontrollergetevents) | **GET** /creation/jobs/{jobId}/events | 
[**creationControllerGetJob**](CreationApi.md#creationcontrollergetjob) | **GET** /creation/jobs/{jobId} | 
[**creationControllerPreview**](CreationApi.md#creationcontrollerpreview) | **GET** /creation/jobs/{jobId}/preview | 
[**creationControllerShareJob**](CreationApi.md#creationcontrollersharejob) | **POST** /creation/jobs/{jobId}/share | 


# **creationControllerCreateJob**
> creationControllerCreateJob()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();

try {
    api.creationControllerCreateJob();
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerCreateJob: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerCreatePlan**
> creationControllerCreatePlan()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();

try {
    api.creationControllerCreatePlan();
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerCreatePlan: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerExportJob**
> creationControllerExportJob(jobId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String jobId = jobId_example; // String | 

try {
    api.creationControllerExportJob(jobId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerExportJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerGetEvents**
> creationControllerGetEvents(jobId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String jobId = jobId_example; // String | 

try {
    api.creationControllerGetEvents(jobId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerGetEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerGetJob**
> creationControllerGetJob(jobId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String jobId = jobId_example; // String | 

try {
    api.creationControllerGetJob(jobId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerGetJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerPreview**
> creationControllerPreview(jobId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String jobId = jobId_example; // String | 

try {
    api.creationControllerPreview(jobId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerPreview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerShareJob**
> creationControllerShareJob(jobId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String jobId = jobId_example; // String | 

try {
    api.creationControllerShareJob(jobId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerShareJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

