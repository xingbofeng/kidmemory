# kidmemory_protocol.api.LanReceiverApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**lanReceiverControllerDiscover**](LanReceiverApi.md#lanreceivercontrollerdiscover) | **GET** /api/web-companion/lan/discover | 
[**lanReceiverControllerDiscoverDevices**](LanReceiverApi.md#lanreceivercontrollerdiscoverdevices) | **GET** /api/web-companion/lan/devices | 
[**lanReceiverControllerGetSessionStatus**](LanReceiverApi.md#lanreceivercontrollergetsessionstatus) | **GET** /api/web-companion/lan/sessions/{sessionId}/status | 
[**lanReceiverControllerPair**](LanReceiverApi.md#lanreceivercontrollerpair) | **POST** /api/web-companion/lan/pair | 
[**lanReceiverControllerUpload**](LanReceiverApi.md#lanreceivercontrollerupload) | **POST** /api/web-companion/lan/sessions/{sessionId}/upload | 


# **lanReceiverControllerDiscover**
> lanReceiverControllerDiscover()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getLanReceiverApi();

try {
    api.lanReceiverControllerDiscover();
} on DioException catch (e) {
    print('Exception when calling LanReceiverApi->lanReceiverControllerDiscover: $e\n');
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

# **lanReceiverControllerDiscoverDevices**
> lanReceiverControllerDiscoverDevices()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getLanReceiverApi();

try {
    api.lanReceiverControllerDiscoverDevices();
} on DioException catch (e) {
    print('Exception when calling LanReceiverApi->lanReceiverControllerDiscoverDevices: $e\n');
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

# **lanReceiverControllerGetSessionStatus**
> lanReceiverControllerGetSessionStatus(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getLanReceiverApi();
final String sessionId = sessionId_example; // String | 

try {
    api.lanReceiverControllerGetSessionStatus(sessionId);
} on DioException catch (e) {
    print('Exception when calling LanReceiverApi->lanReceiverControllerGetSessionStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **lanReceiverControllerPair**
> lanReceiverControllerPair()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getLanReceiverApi();

try {
    api.lanReceiverControllerPair();
} on DioException catch (e) {
    print('Exception when calling LanReceiverApi->lanReceiverControllerPair: $e\n');
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

# **lanReceiverControllerUpload**
> lanReceiverControllerUpload(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getLanReceiverApi();
final String sessionId = sessionId_example; // String | 

try {
    api.lanReceiverControllerUpload(sessionId);
} on DioException catch (e) {
    print('Exception when calling LanReceiverApi->lanReceiverControllerUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

