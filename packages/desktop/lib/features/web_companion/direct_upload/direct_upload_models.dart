import '../../../core/sidecar/sidecar_dtos.dart';

typedef DirectUploadConfig = CreateDirectUploadSessionResponseDto;
typedef DirectUploadStatusItem = DirectUploadStatusItemDto;
typedef DirectUploadStatusSummary = DirectUploadStatusSummaryDto;
typedef DirectUploadStatusSnapshot = GetDirectUploadStatusResponseDto;

extension DirectUploadStatusItemView on DirectUploadStatusItem {
  String get displayName {
    final slash = objectKey.lastIndexOf('/');
    if (slash < 0 || slash == objectKey.length - 1) return objectKey;
    return objectKey.substring(slash + 1);
  }
}
