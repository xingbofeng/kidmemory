# kidmemory_protocol.api.AgentConfigApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:4317*

Method | HTTP request | Description
------------- | ------------- | -------------
[**agentConfigControllerCreateConfig**](AgentConfigApi.md#agentconfigcontrollercreateconfig) | **POST** /api/config/agent-configs | 
[**agentConfigControllerDeleteConfig**](AgentConfigApi.md#agentconfigcontrollerdeleteconfig) | **DELETE** /api/config/agent-configs/{id} | 
[**agentConfigControllerGetConfig**](AgentConfigApi.md#agentconfigcontrollergetconfig) | **GET** /api/config/agent-configs/{id} | 
[**agentConfigControllerGetDefaultConfig**](AgentConfigApi.md#agentconfigcontrollergetdefaultconfig) | **GET** /api/config/agent-configs/default | 
[**agentConfigControllerListConfigs**](AgentConfigApi.md#agentconfigcontrollerlistconfigs) | **GET** /api/config/agent-configs | 
[**agentConfigControllerSetDefaultConfig**](AgentConfigApi.md#agentconfigcontrollersetdefaultconfig) | **POST** /api/config/agent-configs/{id}/set-default | 
[**agentConfigControllerTestConfig**](AgentConfigApi.md#agentconfigcontrollertestconfig) | **POST** /api/config/agent-configs/{id}/test | 
[**agentConfigControllerUpdateConfig**](AgentConfigApi.md#agentconfigcontrollerupdateconfig) | **PUT** /api/config/agent-configs/{id} | 


# **agentConfigControllerCreateConfig**
> agentConfigControllerCreateConfig()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getAgentConfigApi();

try {
    api.agentConfigControllerCreateConfig();
} on DioException catch (e) {
    print('Exception when calling AgentConfigApi->agentConfigControllerCreateConfig: $e\n');
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

# **agentConfigControllerDeleteConfig**
> agentConfigControllerDeleteConfig(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getAgentConfigApi();
final String id = id_example; // String | 

try {
    api.agentConfigControllerDeleteConfig(id);
} on DioException catch (e) {
    print('Exception when calling AgentConfigApi->agentConfigControllerDeleteConfig: $e\n');
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

# **agentConfigControllerGetConfig**
> agentConfigControllerGetConfig(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getAgentConfigApi();
final String id = id_example; // String | 

try {
    api.agentConfigControllerGetConfig(id);
} on DioException catch (e) {
    print('Exception when calling AgentConfigApi->agentConfigControllerGetConfig: $e\n');
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

# **agentConfigControllerGetDefaultConfig**
> agentConfigControllerGetDefaultConfig()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getAgentConfigApi();

try {
    api.agentConfigControllerGetDefaultConfig();
} on DioException catch (e) {
    print('Exception when calling AgentConfigApi->agentConfigControllerGetDefaultConfig: $e\n');
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

# **agentConfigControllerListConfigs**
> agentConfigControllerListConfigs()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getAgentConfigApi();

try {
    api.agentConfigControllerListConfigs();
} on DioException catch (e) {
    print('Exception when calling AgentConfigApi->agentConfigControllerListConfigs: $e\n');
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

# **agentConfigControllerSetDefaultConfig**
> agentConfigControllerSetDefaultConfig(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getAgentConfigApi();
final String id = id_example; // String | 

try {
    api.agentConfigControllerSetDefaultConfig(id);
} on DioException catch (e) {
    print('Exception when calling AgentConfigApi->agentConfigControllerSetDefaultConfig: $e\n');
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

# **agentConfigControllerTestConfig**
> agentConfigControllerTestConfig(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getAgentConfigApi();
final String id = id_example; // String | 

try {
    api.agentConfigControllerTestConfig(id);
} on DioException catch (e) {
    print('Exception when calling AgentConfigApi->agentConfigControllerTestConfig: $e\n');
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

# **agentConfigControllerUpdateConfig**
> agentConfigControllerUpdateConfig(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getAgentConfigApi();
final String id = id_example; // String | 

try {
    api.agentConfigControllerUpdateConfig(id);
} on DioException catch (e) {
    print('Exception when calling AgentConfigApi->agentConfigControllerUpdateConfig: $e\n');
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

