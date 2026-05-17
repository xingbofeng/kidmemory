# kidmemory_protocol.api.DevicesApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:3002*

Method | HTTP request | Description
------------- | ------------- | -------------
[**devicesControllerGetDevice**](DevicesApi.md#devicescontrollergetdevice) | **GET** /devices/{id} | Get device by ID
[**devicesControllerHeartbeat**](DevicesApi.md#devicescontrollerheartbeat) | **PUT** /devices/{id}/heartbeat | Update device heartbeat
[**devicesControllerRegister**](DevicesApi.md#devicescontrollerregister) | **POST** /devices/register | Register a device (idempotent by machineId)


# **devicesControllerGetDevice**
> devicesControllerGetDevice(id)

Get device by ID

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDevicesApi();
final String id = id_example; // String | 

try {
    api.devicesControllerGetDevice(id);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->devicesControllerGetDevice: $e\n');
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

# **devicesControllerHeartbeat**
> devicesControllerHeartbeat(id)

Update device heartbeat

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDevicesApi();
final String id = id_example; // String | 

try {
    api.devicesControllerHeartbeat(id);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->devicesControllerHeartbeat: $e\n');
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

# **devicesControllerRegister**
> devicesControllerRegister()

Register a device (idempotent by machineId)

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDevicesApi();

try {
    api.devicesControllerRegister();
} on DioException catch (e) {
    print('Exception when calling DevicesApi->devicesControllerRegister: $e\n');
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

