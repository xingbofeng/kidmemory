# kidmemory_protocol.api.ConfigApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**configControllerGetStatus**](ConfigApi.md#configcontrollergetstatus) | **GET** /config/status | Get configuration status


# **configControllerGetStatus**
> configControllerGetStatus()

Get configuration status

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerGetStatus();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerGetStatus: $e\n');
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

