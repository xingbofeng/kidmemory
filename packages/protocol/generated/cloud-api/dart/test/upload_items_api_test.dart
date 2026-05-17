import 'package:test/test.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart';


/// tests for UploadItemsApi
void main() {
  final instance = KidmemoryProtocol().getUploadItemsApi();

  group(UploadItemsApi, () {
    // Get pending sync upload items
    //
    //Future<List<UploadItemResponseDto>> uploadItemsControllerGetPendingSync({ num offset, num limit, Object deviceId }) async
    test('test uploadItemsControllerGetPendingSync', () async {
      // TODO
    });

    // Update upload item sync status
    //
    //Future<UploadItemResponseDto> uploadItemsControllerUpdateSyncStatus() async
    test('test uploadItemsControllerUpdateSyncStatus', () async {
      // TODO
    });

  });
}
