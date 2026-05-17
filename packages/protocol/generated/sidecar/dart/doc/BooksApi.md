# kidmemory_protocol.api.BooksApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://127.0.0.1:4317*

Method | HTTP request | Description
------------- | ------------- | -------------
[**booksControllerCancelJob**](BooksApi.md#bookscontrollercanceljob) | **POST** /books/jobs/{id}/cancel | 
[**booksControllerCreateJob**](BooksApi.md#bookscontrollercreatejob) | **POST** /books/jobs | 
[**booksControllerExportLongImage**](BooksApi.md#bookscontrollerexportlongimage) | **POST** /books/jobs/{id}/export/long-image | 
[**booksControllerExportPdf**](BooksApi.md#bookscontrollerexportpdf) | **POST** /books/jobs/{id}/export/pdf | 
[**booksControllerGetJob**](BooksApi.md#bookscontrollergetjob) | **GET** /books/jobs/{id} | 
[**booksControllerListJobs**](BooksApi.md#bookscontrollerlistjobs) | **GET** /books/jobs | 
[**booksControllerPreview**](BooksApi.md#bookscontrollerpreview) | **GET** /books/jobs/{id}/preview | 
[**booksControllerRetryJob**](BooksApi.md#bookscontrollerretryjob) | **POST** /books/jobs/{id}/retry | 


# **booksControllerCancelJob**
> booksControllerCancelJob(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getBooksApi();
final String id = id_example; // String | 

try {
    api.booksControllerCancelJob(id);
} on DioException catch (e) {
    print('Exception when calling BooksApi->booksControllerCancelJob: $e\n');
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

# **booksControllerCreateJob**
> booksControllerCreateJob()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getBooksApi();

try {
    api.booksControllerCreateJob();
} on DioException catch (e) {
    print('Exception when calling BooksApi->booksControllerCreateJob: $e\n');
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

# **booksControllerExportLongImage**
> booksControllerExportLongImage(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getBooksApi();
final String id = id_example; // String | 

try {
    api.booksControllerExportLongImage(id);
} on DioException catch (e) {
    print('Exception when calling BooksApi->booksControllerExportLongImage: $e\n');
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

# **booksControllerExportPdf**
> booksControllerExportPdf(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getBooksApi();
final String id = id_example; // String | 

try {
    api.booksControllerExportPdf(id);
} on DioException catch (e) {
    print('Exception when calling BooksApi->booksControllerExportPdf: $e\n');
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

# **booksControllerGetJob**
> booksControllerGetJob(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getBooksApi();
final String id = id_example; // String | 

try {
    api.booksControllerGetJob(id);
} on DioException catch (e) {
    print('Exception when calling BooksApi->booksControllerGetJob: $e\n');
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

# **booksControllerListJobs**
> booksControllerListJobs()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getBooksApi();

try {
    api.booksControllerListJobs();
} on DioException catch (e) {
    print('Exception when calling BooksApi->booksControllerListJobs: $e\n');
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

# **booksControllerPreview**
> booksControllerPreview(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getBooksApi();
final String id = id_example; // String | 

try {
    api.booksControllerPreview(id);
} on DioException catch (e) {
    print('Exception when calling BooksApi->booksControllerPreview: $e\n');
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

# **booksControllerRetryJob**
> booksControllerRetryJob(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getBooksApi();
final String id = id_example; // String | 

try {
    api.booksControllerRetryJob(id);
} on DioException catch (e) {
    print('Exception when calling BooksApi->booksControllerRetryJob: $e\n');
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

