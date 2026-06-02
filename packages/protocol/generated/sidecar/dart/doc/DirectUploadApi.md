# kidmemory_protocol.api.DirectUploadApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:4317*

Method | HTTP request | Description
------------- | ------------- | -------------
[**directUploadControllerCreateSession**](DirectUploadApi.md#directuploadcontrollercreatesession) | **POST** /api/web-companion/direct-upload/sessions |
[**directUploadControllerCreateSignedUploadTarget**](DirectUploadApi.md#directuploadcontrollercreatesigneduploadtarget) | **POST** /api/web-companion/direct-upload/sessions/{sessionId}/sign-upload |
[**directUploadControllerGetSessionConfig**](DirectUploadApi.md#directuploadcontrollergetsessionconfig) | **GET** /api/web-companion/direct-upload/sessions/{sessionId}/config |
[**directUploadControllerGetStatus**](DirectUploadApi.md#directuploadcontrollergetstatus) | **GET** /api/web-companion/direct-upload/sessions/{sessionId}/status |
[**directUploadControllerListObjects**](DirectUploadApi.md#directuploadcontrollerlistobjects) | **GET** /api/web-companion/direct-upload/sessions/{sessionId}/objects |
[**directUploadControllerPullback**](DirectUploadApi.md#directuploadcontrollerpullback) | **POST** /api/web-companion/direct-upload/sessions/{sessionId}/pullback |


# **directUploadControllerCreateSession**
> DirectUploadControllerCreateSession201Response directUploadControllerCreateSession(directUploadControllerCreateSessionRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final DirectUploadControllerCreateSessionRequest directUploadControllerCreateSessionRequest = ; // DirectUploadControllerCreateSessionRequest |

try {
    final response = api.directUploadControllerCreateSession(directUploadControllerCreateSessionRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerCreateSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **directUploadControllerCreateSessionRequest** | [**DirectUploadControllerCreateSessionRequest**](DirectUploadControllerCreateSessionRequest.md)|  |

### Return type

[**DirectUploadControllerCreateSession201Response**](DirectUploadControllerCreateSession201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **directUploadControllerCreateSignedUploadTarget**
> WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload directUploadControllerCreateSignedUploadTarget(sessionId, directUploadControllerCreateSignedUploadTargetRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final String sessionId = sessionId_example; // String |
final DirectUploadControllerCreateSignedUploadTargetRequest directUploadControllerCreateSignedUploadTargetRequest = ; // DirectUploadControllerCreateSignedUploadTargetRequest |

try {
    final response = api.directUploadControllerCreateSignedUploadTarget(sessionId, directUploadControllerCreateSignedUploadTargetRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerCreateSignedUploadTarget: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **directUploadControllerCreateSignedUploadTargetRequest** | [**DirectUploadControllerCreateSignedUploadTargetRequest**](DirectUploadControllerCreateSignedUploadTargetRequest.md)|  |

### Return type

[**WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload**](WebCompanionControllerCreateUploadItems201ResponseItemsInnerSignedUpload.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **directUploadControllerGetSessionConfig**
> DirectUploadControllerGetSessionConfig200Response directUploadControllerGetSessionConfig(sessionId, token)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final String sessionId = sessionId_example; // String |
final String token = token_example; // String |

try {
    final response = api.directUploadControllerGetSessionConfig(sessionId, token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerGetSessionConfig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **token** | **String**|  |

### Return type

[**DirectUploadControllerGetSessionConfig200Response**](DirectUploadControllerGetSessionConfig200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **directUploadControllerGetStatus**
> DirectUploadControllerGetStatus200Response directUploadControllerGetStatus(sessionId, token)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final String sessionId = sessionId_example; // String |
final String token = token_example; // String |

try {
    final response = api.directUploadControllerGetStatus(sessionId, token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerGetStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **token** | **String**|  |

### Return type

[**DirectUploadControllerGetStatus200Response**](DirectUploadControllerGetStatus200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **directUploadControllerListObjects**
> DirectUploadControllerListObjects200Response directUploadControllerListObjects(sessionId, token)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final String sessionId = sessionId_example; // String |
final String token = token_example; // String |

try {
    final response = api.directUploadControllerListObjects(sessionId, token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerListObjects: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **token** | **String**|  |

### Return type

[**DirectUploadControllerListObjects200Response**](DirectUploadControllerListObjects200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **directUploadControllerPullback**
> DirectUploadControllerPullback201Response directUploadControllerPullback(sessionId, directUploadControllerPullbackRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDirectUploadApi();
final String sessionId = sessionId_example; // String |
final DirectUploadControllerPullbackRequest directUploadControllerPullbackRequest = ; // DirectUploadControllerPullbackRequest |

try {
    final response = api.directUploadControllerPullback(sessionId, directUploadControllerPullbackRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DirectUploadApi->directUploadControllerPullback: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **directUploadControllerPullbackRequest** | [**DirectUploadControllerPullbackRequest**](DirectUploadControllerPullbackRequest.md)|  |

### Return type

[**DirectUploadControllerPullback201Response**](DirectUploadControllerPullback201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
