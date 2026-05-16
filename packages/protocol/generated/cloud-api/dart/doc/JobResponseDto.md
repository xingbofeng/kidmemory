# kidmemory_protocol.model.JobResponseDto

## Load the model package
```dart
import 'package:kidmemory_protocol/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**deviceId** | **String** |  | [optional] 
**type** | **String** | Job type | 
**payload** | **Object** | Job payload (JSON) | 
**status** | **String** | Job status | 
**priority** | **num** | Priority (higher = more urgent) | [default to 0]
**claimedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**completedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**errorMessage** | **String** |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


