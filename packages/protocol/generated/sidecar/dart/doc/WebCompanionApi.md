# kidmemory_protocol.api.WebCompanionApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:4317*

Method | HTTP request | Description
------------- | ------------- | -------------
[**webCompanionControllerAccessSharedContent**](WebCompanionApi.md#webcompanioncontrolleraccesssharedcontent) | **GET** /api/web-companion/share/{shareToken}/access |
[**webCompanionControllerCloseSession**](WebCompanionApi.md#webcompanioncontrollerclosesession) | **POST** /api/web-companion/sessions/{sessionId}/close |
[**webCompanionControllerCommitUploadItem**](WebCompanionApi.md#webcompanioncontrollercommituploaditem) | **PUT** /api/web-companion/sessions/{sessionId}/items/{uploadItemId}/commit |
[**webCompanionControllerCreateSession**](WebCompanionApi.md#webcompanioncontrollercreatesession) | **POST** /api/web-companion/sessions |
[**webCompanionControllerCreateShareToken**](WebCompanionApi.md#webcompanioncontrollercreatesharetoken) | **POST** /api/web-companion/sessions/{sessionId}/share |
[**webCompanionControllerCreateUploadItems**](WebCompanionApi.md#webcompanioncontrollercreateuploaditems) | **POST** /api/web-companion/sessions/{sessionId}/items |
[**webCompanionControllerGetAssetDetails**](WebCompanionApi.md#webcompanioncontrollergetassetdetails) | **GET** /api/web-companion/sessions/{sessionId}/assets/{assetId} |
[**webCompanionControllerGetBookDetails**](WebCompanionApi.md#webcompanioncontrollergetbookdetails) | **GET** /api/web-companion/sessions/{sessionId}/books/{bookId} |
[**webCompanionControllerGetBooksList**](WebCompanionApi.md#webcompanioncontrollergetbookslist) | **GET** /api/web-companion/sessions/{sessionId}/books |
[**webCompanionControllerGetRecentUploads**](WebCompanionApi.md#webcompanioncontrollergetrecentuploads) | **GET** /api/web-companion/sessions/{sessionId}/recent |
[**webCompanionControllerGetSessionDetail**](WebCompanionApi.md#webcompanioncontrollergetsessiondetail) | **GET** /api/web-companion/sessions/{sessionId}/detail |
[**webCompanionControllerGetSessionSummary**](WebCompanionApi.md#webcompanioncontrollergetsessionsummary) | **GET** /api/web-companion/sessions/{sessionId} |
[**webCompanionControllerGetSharedAssets**](WebCompanionApi.md#webcompanioncontrollergetsharedassets) | **GET** /api/web-companion/share/{shareToken}/assets |
[**webCompanionControllerGetSharedBook**](WebCompanionApi.md#webcompanioncontrollergetsharedbook) | **GET** /api/web-companion/share/{shareToken}/book |
[**webCompanionControllerRetryUploadItem**](WebCompanionApi.md#webcompanioncontrollerretryuploaditem) | **POST** /api/web-companion/sessions/{sessionId}/items/{uploadItemId}/retry |
[**webCompanionControllerRevokeShareToken**](WebCompanionApi.md#webcompanioncontrollerrevokesharetoken) | **POST** /api/web-companion/sessions/{sessionId}/share/{shareTokenId}/revoke |
[**webCompanionControllerSubmitSession**](WebCompanionApi.md#webcompanioncontrollersubmitsession) | **POST** /api/web-companion/sessions/{sessionId}/submit |


# **webCompanionControllerAccessSharedContent**
> webCompanionControllerAccessSharedContent(shareToken)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String shareToken = shareToken_example; // String |

try {
    api.webCompanionControllerAccessSharedContent(shareToken);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerAccessSharedContent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shareToken** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerCloseSession**
> WebCompanionControllerCloseSession201Response webCompanionControllerCloseSession(sessionId, webCompanionControllerRetryUploadItemRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final WebCompanionControllerRetryUploadItemRequest webCompanionControllerRetryUploadItemRequest = ; // WebCompanionControllerRetryUploadItemRequest |

try {
    final response = api.webCompanionControllerCloseSession(sessionId, webCompanionControllerRetryUploadItemRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCloseSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **webCompanionControllerRetryUploadItemRequest** | [**WebCompanionControllerRetryUploadItemRequest**](WebCompanionControllerRetryUploadItemRequest.md)|  |

### Return type

[**WebCompanionControllerCloseSession201Response**](WebCompanionControllerCloseSession201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerCommitUploadItem**
> WebCompanionControllerCommitUploadItem200Response webCompanionControllerCommitUploadItem(sessionId, uploadItemId, webCompanionControllerCommitUploadItemRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String uploadItemId = uploadItemId_example; // String |
final WebCompanionControllerCommitUploadItemRequest webCompanionControllerCommitUploadItemRequest = ; // WebCompanionControllerCommitUploadItemRequest |

try {
    final response = api.webCompanionControllerCommitUploadItem(sessionId, uploadItemId, webCompanionControllerCommitUploadItemRequest);
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
 **webCompanionControllerCommitUploadItemRequest** | [**WebCompanionControllerCommitUploadItemRequest**](WebCompanionControllerCommitUploadItemRequest.md)|  |

### Return type

[**WebCompanionControllerCommitUploadItem200Response**](WebCompanionControllerCommitUploadItem200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerCreateSession**
> WebCompanionControllerCreateSession201Response webCompanionControllerCreateSession(webCompanionControllerCreateSessionRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final WebCompanionControllerCreateSessionRequest webCompanionControllerCreateSessionRequest = ; // WebCompanionControllerCreateSessionRequest |

try {
    final response = api.webCompanionControllerCreateSession(webCompanionControllerCreateSessionRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCreateSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **webCompanionControllerCreateSessionRequest** | [**WebCompanionControllerCreateSessionRequest**](WebCompanionControllerCreateSessionRequest.md)|  |

### Return type

[**WebCompanionControllerCreateSession201Response**](WebCompanionControllerCreateSession201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerCreateShareToken**
> webCompanionControllerCreateShareToken(sessionId, token)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String token = token_example; // String |

try {
    api.webCompanionControllerCreateShareToken(sessionId, token);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCreateShareToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **token** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerCreateUploadItems**
> WebCompanionControllerCreateUploadItems201Response webCompanionControllerCreateUploadItems(sessionId, webCompanionControllerCreateUploadItemsRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final WebCompanionControllerCreateUploadItemsRequest webCompanionControllerCreateUploadItemsRequest = ; // WebCompanionControllerCreateUploadItemsRequest |

try {
    final response = api.webCompanionControllerCreateUploadItems(sessionId, webCompanionControllerCreateUploadItemsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCreateUploadItems: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **webCompanionControllerCreateUploadItemsRequest** | [**WebCompanionControllerCreateUploadItemsRequest**](WebCompanionControllerCreateUploadItemsRequest.md)|  |

### Return type

[**WebCompanionControllerCreateUploadItems201Response**](WebCompanionControllerCreateUploadItems201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetAssetDetails**
> WebCompanionControllerGetRecentUploads200ResponseInner webCompanionControllerGetAssetDetails(sessionId, assetId, token)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String assetId = assetId_example; // String |
final String token = token_example; // String |

try {
    final response = api.webCompanionControllerGetAssetDetails(sessionId, assetId, token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetAssetDetails: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **assetId** | **String**|  |
 **token** | **String**|  |

### Return type

[**WebCompanionControllerGetRecentUploads200ResponseInner**](WebCompanionControllerGetRecentUploads200ResponseInner.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetBookDetails**
> webCompanionControllerGetBookDetails(sessionId, bookId, token)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String bookId = bookId_example; // String |
final String token = token_example; // String |

try {
    api.webCompanionControllerGetBookDetails(sessionId, bookId, token);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetBookDetails: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **bookId** | **String**|  |
 **token** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetBooksList**
> webCompanionControllerGetBooksList(sessionId, token, childId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String token = token_example; // String |
final String childId = childId_example; // String |

try {
    api.webCompanionControllerGetBooksList(sessionId, token, childId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetBooksList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **token** | **String**|  |
 **childId** | **String**|  | [optional]

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetRecentUploads**
> List<WebCompanionControllerGetRecentUploads200ResponseInner> webCompanionControllerGetRecentUploads(sessionId, token, limit)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String token = token_example; // String |
final num limit = 8.14; // num |

try {
    final response = api.webCompanionControllerGetRecentUploads(sessionId, token, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetRecentUploads: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **token** | **String**|  |
 **limit** | **num**|  | [optional]

### Return type

[**List&lt;WebCompanionControllerGetRecentUploads200ResponseInner&gt;**](WebCompanionControllerGetRecentUploads200ResponseInner.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetSessionDetail**
> WebCompanionControllerGetSessionDetail200Response webCompanionControllerGetSessionDetail(sessionId, token)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String token = token_example; // String |

try {
    final response = api.webCompanionControllerGetSessionDetail(sessionId, token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetSessionDetail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **token** | **String**|  |

### Return type

[**WebCompanionControllerGetSessionDetail200Response**](WebCompanionControllerGetSessionDetail200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetSessionSummary**
> WebCompanionControllerGetSessionSummary200Response webCompanionControllerGetSessionSummary(sessionId, token)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String token = token_example; // String |

try {
    final response = api.webCompanionControllerGetSessionSummary(sessionId, token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetSessionSummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **token** | **String**|  |

### Return type

[**WebCompanionControllerGetSessionSummary200Response**](WebCompanionControllerGetSessionSummary200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetSharedAssets**
> webCompanionControllerGetSharedAssets(shareToken)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String shareToken = shareToken_example; // String |

try {
    api.webCompanionControllerGetSharedAssets(shareToken);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetSharedAssets: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shareToken** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetSharedBook**
> webCompanionControllerGetSharedBook(shareToken)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String shareToken = shareToken_example; // String |

try {
    api.webCompanionControllerGetSharedBook(shareToken);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetSharedBook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shareToken** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerRetryUploadItem**
> WebCompanionControllerCommitUploadItem200Response webCompanionControllerRetryUploadItem(sessionId, uploadItemId, webCompanionControllerRetryUploadItemRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String uploadItemId = uploadItemId_example; // String |
final WebCompanionControllerRetryUploadItemRequest webCompanionControllerRetryUploadItemRequest = ; // WebCompanionControllerRetryUploadItemRequest |

try {
    final response = api.webCompanionControllerRetryUploadItem(sessionId, uploadItemId, webCompanionControllerRetryUploadItemRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerRetryUploadItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **uploadItemId** | **String**|  |
 **webCompanionControllerRetryUploadItemRequest** | [**WebCompanionControllerRetryUploadItemRequest**](WebCompanionControllerRetryUploadItemRequest.md)|  |

### Return type

[**WebCompanionControllerCommitUploadItem200Response**](WebCompanionControllerCommitUploadItem200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerRevokeShareToken**
> WebCompanionControllerCloseSession201Response webCompanionControllerRevokeShareToken(sessionId, shareTokenId, token)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String shareTokenId = shareTokenId_example; // String |
final String token = token_example; // String |

try {
    final response = api.webCompanionControllerRevokeShareToken(sessionId, shareTokenId, token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerRevokeShareToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **shareTokenId** | **String**|  |
 **token** | **String**|  |

### Return type

[**WebCompanionControllerCloseSession201Response**](WebCompanionControllerCloseSession201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerSubmitSession**
> WebCompanionControllerCloseSession201Response webCompanionControllerSubmitSession(sessionId, webCompanionControllerRetryUploadItemRequest)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final WebCompanionControllerRetryUploadItemRequest webCompanionControllerRetryUploadItemRequest = ; // WebCompanionControllerRetryUploadItemRequest |

try {
    final response = api.webCompanionControllerSubmitSession(sessionId, webCompanionControllerRetryUploadItemRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerSubmitSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **webCompanionControllerRetryUploadItemRequest** | [**WebCompanionControllerRetryUploadItemRequest**](WebCompanionControllerRetryUploadItemRequest.md)|  |

### Return type

[**WebCompanionControllerCloseSession201Response**](WebCompanionControllerCloseSession201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
