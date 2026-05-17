# kidmemory_protocol.api.WebCompanionApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:3002*

Method | HTTP request | Description
------------- | ------------- | -------------
[**webCompanionControllerCommitUploadItem**](WebCompanionApi.md#webcompanioncontrollercommituploaditem) | **PUT** /api/web-companion/sessions/{sessionId}/items/{uploadItemId}/commit | Commit upload item
[**webCompanionControllerCreateUploadItems**](WebCompanionApi.md#webcompanioncontrollercreateuploaditems) | **POST** /api/web-companion/sessions/{sessionId}/items | Create upload items for trusted upload session
[**webCompanionControllerGetDirectUploadConfig**](WebCompanionApi.md#webcompanioncontrollergetdirectuploadconfig) | **GET** /api/web-companion/direct-upload/sessions/{sessionId}/config | Get direct upload config for trusted upload session
[**webCompanionControllerGetSessionSummary**](WebCompanionApi.md#webcompanioncontrollergetsessionsummary) | **GET** /api/web-companion/sessions/{sessionId} | Get trusted upload session summary
[**webCompanionControllerGetSharedAssets**](WebCompanionApi.md#webcompanioncontrollergetsharedassets) | **GET** /api/web-companion/share/{shareToken}/assets | Get public shared assets
[**webCompanionControllerGetSharedBook**](WebCompanionApi.md#webcompanioncontrollergetsharedbook) | **GET** /api/web-companion/share/{shareToken}/book | Get public shared book metadata
[**webCompanionControllerValidateShareToken**](WebCompanionApi.md#webcompanioncontrollervalidatesharetoken) | **GET** /api/web-companion/share/{shareToken}/access | Validate public share token


# **webCompanionControllerCommitUploadItem**
> webCompanionControllerCommitUploadItem(sessionId, uploadItemId)

Commit upload item

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String | 
final String uploadItemId = uploadItemId_example; // String | 

try {
    api.webCompanionControllerCommitUploadItem(sessionId, uploadItemId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCommitUploadItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 
 **uploadItemId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerCreateUploadItems**
> webCompanionControllerCreateUploadItems(sessionId)

Create upload items for trusted upload session

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String | 

try {
    api.webCompanionControllerCreateUploadItems(sessionId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCreateUploadItems: $e\n');
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

# **webCompanionControllerGetDirectUploadConfig**
> webCompanionControllerGetDirectUploadConfig(sessionId)

Get direct upload config for trusted upload session

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String | 

try {
    api.webCompanionControllerGetDirectUploadConfig(sessionId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetDirectUploadConfig: $e\n');
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

# **webCompanionControllerGetSessionSummary**
> webCompanionControllerGetSessionSummary(sessionId)

Get trusted upload session summary

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String | 

try {
    api.webCompanionControllerGetSessionSummary(sessionId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetSessionSummary: $e\n');
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

# **webCompanionControllerGetSharedAssets**
> webCompanionControllerGetSharedAssets(shareToken, limit)

Get public shared assets

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String shareToken = shareToken_example; // String | 
final num limit = 8.14; // num | 

try {
    api.webCompanionControllerGetSharedAssets(shareToken, limit);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetSharedAssets: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shareToken** | **String**|  | 
 **limit** | **num**|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetSharedBook**
> webCompanionControllerGetSharedBook(shareToken, bookId)

Get public shared book metadata

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String shareToken = shareToken_example; // String | 
final String bookId = bookId_example; // String | 

try {
    api.webCompanionControllerGetSharedBook(shareToken, bookId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetSharedBook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shareToken** | **String**|  | 
 **bookId** | **String**|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerValidateShareToken**
> webCompanionControllerValidateShareToken(shareToken, userAgent, clientIp)

Validate public share token

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String shareToken = shareToken_example; // String | 
final Object userAgent = ; // Object | 
final Object clientIp = ; // Object | 

try {
    api.webCompanionControllerValidateShareToken(shareToken, userAgent, clientIp);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerValidateShareToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shareToken** | **String**|  | 
 **userAgent** | [**Object**](.md)|  | [optional] 
 **clientIp** | [**Object**](.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

