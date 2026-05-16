# kidmemory_protocol.api.ConfigApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**configControllerClaudeReadiness**](ConfigApi.md#configcontrollerclaudereadiness) | **POST** /config/check/claude | 
[**configControllerHealth**](ConfigApi.md#configcontrollerhealth) | **GET** /health | 
[**configControllerInitializeSchema**](ConfigApi.md#configcontrollerinitializeschema) | **POST** /schema/init | 
[**configControllerOpenAIReadiness**](ConfigApi.md#configcontrolleropenaireadiness) | **POST** /config/check/openai | 
[**configControllerPgVectorReadiness**](ConfigApi.md#configcontrollerpgvectorreadiness) | **POST** /config/check/pgvector | 
[**configControllerPostgresReadiness**](ConfigApi.md#configcontrollerpostgresreadiness) | **POST** /config/check/postgres | 
[**configControllerStatus**](ConfigApi.md#configcontrollerstatus) | **GET** /config/status | 
[**configControllerTestSupabaseStorage**](ConfigApi.md#configcontrollertestsupabasestorage) | **POST** /config/supabase-storage/test | 
[**configControllerUiConfig**](ConfigApi.md#configcontrolleruiconfig) | **GET** /config/ui | 
[**configControllerUpdateOpenAI**](ConfigApi.md#configcontrollerupdateopenai) | **POST** /config/openai | 
[**configControllerUpdatePaths**](ConfigApi.md#configcontrollerupdatepaths) | **POST** /config/paths | 
[**configControllerUpdatePostgres**](ConfigApi.md#configcontrollerupdatepostgres) | **POST** /config/postgres | 
[**configControllerUpdateSupabaseStorage**](ConfigApi.md#configcontrollerupdatesupabasestorage) | **POST** /config/supabase-storage | 


# **configControllerClaudeReadiness**
> configControllerClaudeReadiness()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerClaudeReadiness();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerClaudeReadiness: $e\n');
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

# **configControllerHealth**
> configControllerHealth()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerHealth();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerHealth: $e\n');
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

# **configControllerInitializeSchema**
> configControllerInitializeSchema()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerInitializeSchema();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerInitializeSchema: $e\n');
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

# **configControllerOpenAIReadiness**
> configControllerOpenAIReadiness()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerOpenAIReadiness();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerOpenAIReadiness: $e\n');
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

# **configControllerPgVectorReadiness**
> configControllerPgVectorReadiness()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerPgVectorReadiness();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerPgVectorReadiness: $e\n');
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

# **configControllerPostgresReadiness**
> configControllerPostgresReadiness()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerPostgresReadiness();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerPostgresReadiness: $e\n');
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

# **configControllerStatus**
> configControllerStatus()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerStatus();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerStatus: $e\n');
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

# **configControllerTestSupabaseStorage**
> configControllerTestSupabaseStorage()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerTestSupabaseStorage();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerTestSupabaseStorage: $e\n');
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

# **configControllerUiConfig**
> configControllerUiConfig()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerUiConfig();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerUiConfig: $e\n');
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

# **configControllerUpdateOpenAI**
> configControllerUpdateOpenAI()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerUpdateOpenAI();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerUpdateOpenAI: $e\n');
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

# **configControllerUpdatePaths**
> configControllerUpdatePaths()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerUpdatePaths();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerUpdatePaths: $e\n');
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

# **configControllerUpdatePostgres**
> configControllerUpdatePostgres()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerUpdatePostgres();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerUpdatePostgres: $e\n');
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

# **configControllerUpdateSupabaseStorage**
> configControllerUpdateSupabaseStorage()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getConfigApi();

try {
    api.configControllerUpdateSupabaseStorage();
} on DioException catch (e) {
    print('Exception when calling ConfigApi->configControllerUpdateSupabaseStorage: $e\n');
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

