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
> webCompanionControllerCloseSession(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |

try {
    api.webCompanionControllerCloseSession(sessionId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCloseSession: $e\n');
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

# **webCompanionControllerCommitUploadItem**
> webCompanionControllerCommitUploadItem(sessionId, uploadItemId)



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

# **webCompanionControllerCreateSession**
> webCompanionControllerCreateSession()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();

try {
    api.webCompanionControllerCreateSession();
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCreateSession: $e\n');
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

# **webCompanionControllerCreateShareToken**
> webCompanionControllerCreateShareToken(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |

try {
    api.webCompanionControllerCreateShareToken(sessionId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerCreateShareToken: $e\n');
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

# **webCompanionControllerCreateUploadItems**
> webCompanionControllerCreateUploadItems(sessionId)



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

# **webCompanionControllerGetAssetDetails**
> webCompanionControllerGetAssetDetails(sessionId, assetId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String assetId = assetId_example; // String |

try {
    api.webCompanionControllerGetAssetDetails(sessionId, assetId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetAssetDetails: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **assetId** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetBookDetails**
> webCompanionControllerGetBookDetails(sessionId, bookId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String bookId = bookId_example; // String |

try {
    api.webCompanionControllerGetBookDetails(sessionId, bookId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetBookDetails: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **bookId** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerGetBooksList**
> webCompanionControllerGetBooksList(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |

try {
    api.webCompanionControllerGetBooksList(sessionId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetBooksList: $e\n');
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

# **webCompanionControllerGetRecentUploads**
> webCompanionControllerGetRecentUploads(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |

try {
    api.webCompanionControllerGetRecentUploads(sessionId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetRecentUploads: $e\n');
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

# **webCompanionControllerGetSessionDetail**
> webCompanionControllerGetSessionDetail(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |

try {
    api.webCompanionControllerGetSessionDetail(sessionId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerGetSessionDetail: $e\n');
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
> webCompanionControllerRetryUploadItem(sessionId, uploadItemId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String uploadItemId = uploadItemId_example; // String |

try {
    api.webCompanionControllerRetryUploadItem(sessionId, uploadItemId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerRetryUploadItem: $e\n');
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

# **webCompanionControllerRevokeShareToken**
> webCompanionControllerRevokeShareToken(sessionId, shareTokenId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |
final String shareTokenId = shareTokenId_example; // String |

try {
    api.webCompanionControllerRevokeShareToken(sessionId, shareTokenId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerRevokeShareToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  |
 **shareTokenId** | **String**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webCompanionControllerSubmitSession**
> webCompanionControllerSubmitSession(sessionId)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getWebCompanionApi();
final String sessionId = sessionId_example; // String |

try {
    api.webCompanionControllerSubmitSession(sessionId);
} on DioException catch (e) {
    print('Exception when calling WebCompanionApi->webCompanionControllerSubmitSession: $e\n');
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
