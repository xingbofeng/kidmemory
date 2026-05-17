import 'package:test/test.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart';


/// tests for WebCompanionApi
void main() {
  final instance = KidmemoryProtocol().getWebCompanionApi();

  group(WebCompanionApi, () {
    // Commit upload item
    //
    //Future<CommitUploadItemResponseDto> webCompanionControllerCommitUploadItem(String sessionId, String uploadItemId, CommitUploadItemRequestDto commitUploadItemRequestDto) async
    test('test webCompanionControllerCommitUploadItem', () async {
      // TODO
    });

    // Create upload items for trusted upload session
    //
    //Future<CreateUploadItemsResponseDto> webCompanionControllerCreateUploadItems(String sessionId, CreateUploadItemsRequestDto createUploadItemsRequestDto) async
    test('test webCompanionControllerCreateUploadItems', () async {
      // TODO
    });

    // Get direct upload config for trusted upload session
    //
    //Future<DirectUploadConfigResponseDto> webCompanionControllerGetDirectUploadConfig(String sessionId) async
    test('test webCompanionControllerGetDirectUploadConfig', () async {
      // TODO
    });

    // Get trusted upload session summary
    //
    //Future<SessionSummaryResponseDto> webCompanionControllerGetSessionSummary(String sessionId) async
    test('test webCompanionControllerGetSessionSummary', () async {
      // TODO
    });

    // Get public shared assets
    //
    //Future<List<SharedAssetDto>> webCompanionControllerGetSharedAssets(String shareToken, { num limit }) async
    test('test webCompanionControllerGetSharedAssets', () async {
      // TODO
    });

    // Get public shared book metadata
    //
    //Future<SharedBookDto> webCompanionControllerGetSharedBook(String shareToken, { String bookId }) async
    test('test webCompanionControllerGetSharedBook', () async {
      // TODO
    });

    // Validate public share token
    //
    //Future<ShareTokenValidationResponseDto> webCompanionControllerValidateShareToken(String shareToken, { Object userAgent, Object clientIp }) async
    test('test webCompanionControllerValidateShareToken', () async {
      // TODO
    });

  });
}
