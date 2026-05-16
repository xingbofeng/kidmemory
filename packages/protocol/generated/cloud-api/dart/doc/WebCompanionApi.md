# kidmemory_protocol.api.WebCompanionApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://localhost*

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
> CommitUploadItemResponseDto webCompanionControllerCommitUploadItem(sessionId, uploadItemId, commitUploadItemRequestDto)

Commit upload item

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String | 
final String uploadItemId = uploadItemId_example; // String | 
final CommitUploadItemRequestDto commitUploadItemRequestDto = ; // CommitUploadItemRequestDto | 

try {
    final response = api.webCompanionControllerCommitUploadItem(sessionId, uploadItemId, commitUploadItemRequestDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCommitUploadItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 
 **uploadItemId** | **String**|  | 
 **commitUploadItemRequestDto** | [**CommitUploadItemRequestDto**](CommitUploadItemRequestDto.md)|  | 

### Return type

[**CommitUploadItemResponseDto**](CommitUploadItemResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerCreateUploadItems**
> CreateUploadItemsResponseDto webCompanionControllerCreateUploadItems(sessionId, createUploadItemsRequestDto)

Create upload items for trusted upload session

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String | 
final CreateUploadItemsRequestDto createUploadItemsRequestDto = ; // CreateUploadItemsRequestDto | 

try {
    final response = api.webCompanionControllerCreateUploadItems(sessionId, createUploadItemsRequestDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCreateUploadItems: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 
 **createUploadItemsRequestDto** | [**CreateUploadItemsRequestDto**](CreateUploadItemsRequestDto.md)|  | 

### Return type

[**CreateUploadItemsResponseDto**](CreateUploadItemsResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetDirectUploadConfig**
> DirectUploadConfigResponseDto webCompanionControllerGetDirectUploadConfig(sessionId)

Get direct upload config for trusted upload session

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String | 

try {
    final response = api.webCompanionControllerGetDirectUploadConfig(sessionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetDirectUploadConfig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 

### Return type

[**DirectUploadConfigResponseDto**](DirectUploadConfigResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetSessionSummary**
> SessionSummaryResponseDto webCompanionControllerGetSessionSummary(sessionId)

Get trusted upload session summary

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String | 

try {
    final response = api.webCompanionControllerGetSessionSummary(sessionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetSessionSummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 

### Return type

[**SessionSummaryResponseDto**](SessionSummaryResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetSharedAssets**
> List<SharedAssetDto> webCompanionControllerGetSharedAssets(shareToken, limit)

Get public shared assets

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String shareToken = shareToken_example; // String | 
final num limit = 8.14; // num | 

try {
    final response = api.webCompanionControllerGetSharedAssets(shareToken, limit);
    print(response);
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

[**List&lt;SharedAssetDto&gt;**](SharedAssetDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetSharedBook**
> SharedBookDto webCompanionControllerGetSharedBook(shareToken, bookId)

Get public shared book metadata

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String shareToken = shareToken_example; // String | 
final String bookId = bookId_example; // String | 

try {
    final response = api.webCompanionControllerGetSharedBook(shareToken, bookId);
    print(response);
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

[**SharedBookDto**](SharedBookDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerValidateShareToken**
> ShareTokenValidationResponseDto webCompanionControllerValidateShareToken(shareToken, userAgent, clientIp)

Validate public share token

### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String shareToken = shareToken_example; // String | 
final Object userAgent = ; // Object | 
final Object clientIp = ; // Object | 

try {
    final response = api.webCompanionControllerValidateShareToken(shareToken, userAgent, clientIp);
    print(response);
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

[**ShareTokenValidationResponseDto**](ShareTokenValidationResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

