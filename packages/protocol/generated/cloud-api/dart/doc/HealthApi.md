# kidmemory_protocol.api.HealthApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthControllerGetHealth**](HealthApi.md#healthcontrollergethealth) | **GET** /health | Health check endpoint
[**healthControllerGetReadiness**](HealthApi.md#healthcontrollergetreadiness) | **GET** /health/ready | Readiness check endpoint


# **healthControllerGetHealth**
> healthControllerGetHealth()

Health check endpoint

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getHealthApi();

try {
    api.healthControllerGetHealth();
} on DioException catch (e) {
    print('Exception when calling HealthApi->healthControllerGetHealth: $e\n');
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

# **healthControllerGetReadiness**
> healthControllerGetReadiness()

Readiness check endpoint

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getHealthApi();

try {
    api.healthControllerGetReadiness();
} on DioException catch (e) {
    print('Exception when calling HealthApi->healthControllerGetReadiness: $e\n');
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

