# kidmemory_protocol.api.DatasetApi

## Load the API package
```dart
import 'package:kidmemory_protocol/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**datasetControllerAddSearchCandidatePoolItems**](DatasetApi.md#datasetcontrolleraddsearchcandidatepoolitems) | **POST** /search/candidate-pool/items | 
[**datasetControllerCreateChild**](DatasetApi.md#datasetcontrollercreatechild) | **POST** /children | 
[**datasetControllerDeleteAsset**](DatasetApi.md#datasetcontrollerdeleteasset) | **DELETE** /assets/{id} | 
[**datasetControllerGetAsset**](DatasetApi.md#datasetcontrollergetasset) | **GET** /assets/{id} | 
[**datasetControllerGetAssetPreview**](DatasetApi.md#datasetcontrollergetassetpreview) | **GET** /assets/{id}/preview | 
[**datasetControllerGetChild**](DatasetApi.md#datasetcontrollergetchild) | **GET** /children/{id} | 
[**datasetControllerGetExportArtifactShareMetadata**](DatasetApi.md#datasetcontrollergetexportartifactsharemetadata) | **GET** /storage/export-artifacts/{id}/share | 
[**datasetControllerGetSearchIndexingStatus**](DatasetApi.md#datasetcontrollergetsearchindexingstatus) | **GET** /search/indexing-status | 
[**datasetControllerImportAssets**](DatasetApi.md#datasetcontrollerimportassets) | **POST** /assets/import | 
[**datasetControllerImportSample**](DatasetApi.md#datasetcontrollerimportsample) | **POST** /sample/import | 
[**datasetControllerListAssets**](DatasetApi.md#datasetcontrollerlistassets) | **GET** /assets | 
[**datasetControllerListChildren**](DatasetApi.md#datasetcontrollerlistchildren) | **GET** /children | 
[**datasetControllerListSearchCandidatePool**](DatasetApi.md#datasetcontrollerlistsearchcandidatepool) | **GET** /search/candidate-pool | 
[**datasetControllerRemoveSearchCandidatePoolItems**](DatasetApi.md#datasetcontrollerremovesearchcandidatepoolitems) | **DELETE** /search/candidate-pool/items | 
[**datasetControllerRemoveSearchCandidatePoolItemsPost**](DatasetApi.md#datasetcontrollerremovesearchcandidatepoolitemspost) | **POST** /search/candidate-pool/items/remove | 
[**datasetControllerResetSample**](DatasetApi.md#datasetcontrollerresetsample) | **POST** /sample/reset | 
[**datasetControllerRunSearchIndexer**](DatasetApi.md#datasetcontrollerrunsearchindexer) | **POST** /search/indexing/run | 
[**datasetControllerRunStorageSync**](DatasetApi.md#datasetcontrollerrunstoragesync) | **POST** /storage/sync/run | 
[**datasetControllerSearchAssets**](DatasetApi.md#datasetcontrollersearchassets) | **POST** /search/query | 
[**datasetControllerSyncAssetToStorage**](DatasetApi.md#datasetcontrollersyncassettostorage) | **POST** /storage/assets/{id}/sync | 
[**datasetControllerSyncExportArtifactToStorage**](DatasetApi.md#datasetcontrollersyncexportartifacttostorage) | **POST** /storage/export-artifacts/{id}/sync | 
[**datasetControllerUpdateAsset**](DatasetApi.md#datasetcontrollerupdateasset) | **POST** /assets/{id}/update | 


# **datasetControllerAddSearchCandidatePoolItems**
> datasetControllerAddSearchCandidatePoolItems()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerAddSearchCandidatePoolItems();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerAddSearchCandidatePoolItems: $e\n');
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

# **datasetControllerCreateChild**
> datasetControllerCreateChild()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerCreateChild();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerCreateChild: $e\n');
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

# **datasetControllerDeleteAsset**
> datasetControllerDeleteAsset(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();
final String id = id_example; // String | 

try {
    api.datasetControllerDeleteAsset(id);
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerDeleteAsset: $e\n');
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

# **datasetControllerGetAsset**
> datasetControllerGetAsset(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();
final String id = id_example; // String | 

try {
    api.datasetControllerGetAsset(id);
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerGetAsset: $e\n');
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

# **datasetControllerGetAssetPreview**
> datasetControllerGetAssetPreview(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();
final String id = id_example; // String | 

try {
    api.datasetControllerGetAssetPreview(id);
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerGetAssetPreview: $e\n');
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

# **datasetControllerGetChild**
> datasetControllerGetChild(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();
final String id = id_example; // String | 

try {
    api.datasetControllerGetChild(id);
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerGetChild: $e\n');
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

# **datasetControllerGetExportArtifactShareMetadata**
> datasetControllerGetExportArtifactShareMetadata(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();
final String id = id_example; // String | 

try {
    api.datasetControllerGetExportArtifactShareMetadata(id);
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerGetExportArtifactShareMetadata: $e\n');
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

# **datasetControllerGetSearchIndexingStatus**
> datasetControllerGetSearchIndexingStatus()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerGetSearchIndexingStatus();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerGetSearchIndexingStatus: $e\n');
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

# **datasetControllerImportAssets**
> datasetControllerImportAssets()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerImportAssets();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerImportAssets: $e\n');
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

# **datasetControllerImportSample**
> datasetControllerImportSample()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerImportSample();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerImportSample: $e\n');
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

# **datasetControllerListAssets**
> datasetControllerListAssets()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerListAssets();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerListAssets: $e\n');
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

# **datasetControllerListChildren**
> datasetControllerListChildren()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerListChildren();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerListChildren: $e\n');
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

# **datasetControllerListSearchCandidatePool**
> datasetControllerListSearchCandidatePool()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerListSearchCandidatePool();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerListSearchCandidatePool: $e\n');
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

# **datasetControllerRemoveSearchCandidatePoolItems**
> datasetControllerRemoveSearchCandidatePoolItems()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerRemoveSearchCandidatePoolItems();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerRemoveSearchCandidatePoolItems: $e\n');
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

# **datasetControllerRemoveSearchCandidatePoolItemsPost**
> datasetControllerRemoveSearchCandidatePoolItemsPost()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerRemoveSearchCandidatePoolItemsPost();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerRemoveSearchCandidatePoolItemsPost: $e\n');
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

# **datasetControllerResetSample**
> datasetControllerResetSample()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerResetSample();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerResetSample: $e\n');
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

# **datasetControllerRunSearchIndexer**
> datasetControllerRunSearchIndexer()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerRunSearchIndexer();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerRunSearchIndexer: $e\n');
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

# **datasetControllerRunStorageSync**
> datasetControllerRunStorageSync()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerRunStorageSync();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerRunStorageSync: $e\n');
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

# **datasetControllerSearchAssets**
> datasetControllerSearchAssets()



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();

try {
    api.datasetControllerSearchAssets();
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerSearchAssets: $e\n');
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

# **datasetControllerSyncAssetToStorage**
> datasetControllerSyncAssetToStorage(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();
final String id = id_example; // String | 

try {
    api.datasetControllerSyncAssetToStorage(id);
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerSyncAssetToStorage: $e\n');
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

# **datasetControllerSyncExportArtifactToStorage**
> datasetControllerSyncExportArtifactToStorage(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();
final String id = id_example; // String | 

try {
    api.datasetControllerSyncExportArtifactToStorage(id);
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerSyncExportArtifactToStorage: $e\n');
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

# **datasetControllerUpdateAsset**
> datasetControllerUpdateAsset(id)



### Example
```dart
import 'package:kidmemory_protocol/api.dart';

final api = KidmemoryProtocol().getDatasetApi();
final String id = id_example; // String | 

try {
    api.datasetControllerUpdateAsset(id);
} on DioException catch (e) {
    print('Exception when calling DatasetApi->datasetControllerUpdateAsset: $e\n');
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

