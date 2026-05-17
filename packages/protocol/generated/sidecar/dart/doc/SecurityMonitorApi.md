# kidmemory_protocol.api.SecurityMonitorApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:4317*

Method | HTTP request | Description
------------- | ------------- | -------------
[**securityMonitorControllerGetSecurityHealth**](SecurityMonitorApi.md#securitymonitorcontrollergetsecurityhealth) | **GET** /api/monitor/security/health | 
[**securityMonitorControllerGetSecurityStats**](SecurityMonitorApi.md#securitymonitorcontrollergetsecuritystats) | **GET** /api/monitor/security/stats | 


# **securityMonitorControllerGetSecurityHealth**
> securityMonitorControllerGetSecurityHealth()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getSecurityMonitorApi();

try {
    api.securityMonitorControllerGetSecurityHealth();
} on DioException catch (e) {
    print('Exception when calling SecurityMonitorApi->securityMonitorControllerGetSecurityHealth: $e\n');
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

# **securityMonitorControllerGetSecurityStats**
> securityMonitorControllerGetSecurityStats()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getSecurityMonitorApi();

try {
    api.securityMonitorControllerGetSecurityStats();
} on DioException catch (e) {
    print('Exception when calling SecurityMonitorApi->securityMonitorControllerGetSecurityStats: $e\n');
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

