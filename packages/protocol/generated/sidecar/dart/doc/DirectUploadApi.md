# kidmemory_protocol.api.DirectUploadApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:4317*

Method | HTTP request | Description
------------- | ------------- | -------------
[**directUploadControllerCreateSession**](DirectUploadApi.md#directuploadcontrollercreatesession) | **POST** /api/web-companion/direct-upload/sessions |
[**directUploadControllerGetSessionConfig**](DirectUploadApi.md#directuploadcontrollergetsessionconfig) | **GET** /api/web-companion/direct-upload/sessions/{sessionId}/config |
[**directUploadControllerGetStatus**](DirectUploadApi.md#directuploadcontrollergetstatus) | **GET** /api/web-companion/direct-upload/sessions/{sessionId}/status |
[**directUploadControllerListObjects**](DirectUploadApi.md#directuploadcontrollerlistobjects) | **GET** /api/web-companion/direct-upload/sessions/{sessionId}/objects |
[**directUploadControllerPullback**](DirectUploadApi.md#directuploadcontrollerpullback) | **POST** /api/web-companion/direct-upload/sessions/{sessionId}/pullback |


# **directUploadControllerCreateSession**
> directUploadControllerCreateSession()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();

try {
    api.directUploadControllerCreateSession();
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerCreateSession: $e\n');
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

# **directUploadControllerGetSessionConfig**
> directUploadControllerGetSessionConfig(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final String sessionId = sessionId_example; // String |

try {
    api.directUploadControllerGetSessionConfig(sessionId);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerGetSessionConfig: $e\n');
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

# **directUploadControllerGetStatus**
> directUploadControllerGetStatus(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final String sessionId = sessionId_example; // String |

try {
    api.directUploadControllerGetStatus(sessionId);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerGetStatus: $e\n');
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

# **directUploadControllerListObjects**
> directUploadControllerListObjects(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final String sessionId = sessionId_example; // String |

try {
    api.directUploadControllerListObjects(sessionId);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerListObjects: $e\n');
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

# **directUploadControllerPullback**
> directUploadControllerPullback(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final String sessionId = sessionId_example; // String |

try {
    api.directUploadControllerPullback(sessionId);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerPullback: $e\n');
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
