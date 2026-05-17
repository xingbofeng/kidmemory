# kidmemory_protocol.api.StreamableHttpApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:4317*

Method | HTTP request | Description
------------- | ------------- | -------------
[**streamableHttpControllerHandleDeleteRequest**](StreamableHttpApi.md#streamablehttpcontrollerhandledeleterequest) | **DELETE** /mcp | 
[**streamableHttpControllerHandleGetRequest**](StreamableHttpApi.md#streamablehttpcontrollerhandlegetrequest) | **GET** /mcp | 
[**streamableHttpControllerHandlePostRequest**](StreamableHttpApi.md#streamablehttpcontrollerhandlepostrequest) | **POST** /mcp | 


# **streamableHttpControllerHandleDeleteRequest**
> streamableHttpControllerHandleDeleteRequest()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getStreamableHttpApi();

try {
    api.streamableHttpControllerHandleDeleteRequest();
} on DioException catch (e) {
    print('Exception when calling StreamableHttpApi->streamableHttpControllerHandleDeleteRequest: $e\n');
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

# **streamableHttpControllerHandleGetRequest**
> streamableHttpControllerHandleGetRequest()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getStreamableHttpApi();

try {
    api.streamableHttpControllerHandleGetRequest();
} on DioException catch (e) {
    print('Exception when calling StreamableHttpApi->streamableHttpControllerHandleGetRequest: $e\n');
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

# **streamableHttpControllerHandlePostRequest**
> streamableHttpControllerHandlePostRequest()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getStreamableHttpApi();

try {
    api.streamableHttpControllerHandlePostRequest();
} on DioException catch (e) {
    print('Exception when calling StreamableHttpApi->streamableHttpControllerHandlePostRequest: $e\n');
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

