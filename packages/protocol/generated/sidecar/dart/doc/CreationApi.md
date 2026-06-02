# kidmemory_protocol.api.CreationApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:4317*

Method | HTTP request | Description
------------- | ------------- | -------------
[**creationControllerCreateTask**](CreationApi.md#creationcontrollercreatetask) | **POST** /creation/tasks |
[**creationControllerExportTask**](CreationApi.md#creationcontrollerexporttask) | **POST** /creation/tasks/{taskId}/export |
[**creationControllerGenerateTask**](CreationApi.md#creationcontrollergeneratetask) | **POST** /creation/tasks/{taskId}/generate |
[**creationControllerGetEvents**](CreationApi.md#creationcontrollergetevents) | **GET** /creation/tasks/{taskId}/events |
[**creationControllerGetTask**](CreationApi.md#creationcontrollergettask) | **GET** /creation/tasks/{taskId} |
[**creationControllerPreview**](CreationApi.md#creationcontrollerpreview) | **GET** /creation/tasks/{taskId}/preview |
[**creationControllerShareTask**](CreationApi.md#creationcontrollersharetask) | **POST** /creation/tasks/{taskId}/share |


# **creationControllerCreateTask**
> creationControllerCreateTask(creationControllerCreateTaskRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final CreationControllerCreateTaskRequest creationControllerCreateTaskRequest = ; // CreationControllerCreateTaskRequest |

try {
    api.creationControllerCreateTask(creationControllerCreateTaskRequest);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerCreateTask: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **creationControllerCreateTaskRequest** | [**CreationControllerCreateTaskRequest**](CreationControllerCreateTaskRequest.md)|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerExportTask**
> creationControllerExportTask(taskId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String taskId = taskId_example; // String |

try {
    api.creationControllerExportTask(taskId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerExportTask: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerGenerateTask**
> creationControllerGenerateTask(taskId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String taskId = taskId_example; // String |

try {
    api.creationControllerGenerateTask(taskId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerGenerateTask: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerGetEvents**
> creationControllerGetEvents(taskId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String taskId = taskId_example; // String |

try {
    api.creationControllerGetEvents(taskId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerGetEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerGetTask**
> creationControllerGetTask(taskId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String taskId = taskId_example; // String |

try {
    api.creationControllerGetTask(taskId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerGetTask: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerPreview**
> creationControllerPreview(taskId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String taskId = taskId_example; // String |

try {
    api.creationControllerPreview(taskId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerPreview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **creationControllerShareTask**
> creationControllerShareTask(taskId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getCreationApi();
final String taskId = taskId_example; // String |

try {
    api.creationControllerShareTask(taskId);
} on DioException catch (e) {
    print('Exception when calling CreationApi->creationControllerShareTask: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
