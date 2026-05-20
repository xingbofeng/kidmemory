/// Trusted Upload data models.
library;

/// Upload session.
class TrustedUploadSession {
  const TrustedUploadSession({
    required this.sessionId,
    required this.token,
    required this.webUrl,
    required this.expiresAt,
    required this.maxItems,
  });

  final String sessionId;
  final String token;
  final String webUrl;
  final DateTime expiresAt;
  final int maxItems;

  factory TrustedUploadSession.fromJson(Map<String, dynamic> json) {
    return TrustedUploadSession(
      sessionId: json['sessionId'] as String,
      token: json['token'] as String,
      webUrl: json['webUrl'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      maxItems: json['maxItems'] as int,
    );
  }
}

/// Upload status.
class TrustedUploadStatus {
  const TrustedUploadStatus({required this.sessionId, required this.items});

  final String sessionId;
  final List<TrustedUploadItem> items;

  factory TrustedUploadStatus.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>;
    final items = itemsJson
        .map((item) => TrustedUploadItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return TrustedUploadStatus(
      sessionId: json['sessionId'] as String,
      items: items,
    );
  }

  int get totalCount => items.length;
  int get pendingCount => items.where((i) => i.status == 'pending').length;
  int get uploadingCount => items.where((i) => i.status == 'uploading').length;
  int get pullingCount =>
      items.where((i) => i.status == 'pulling_local').length;
  int get readyCount => items.where((i) => i.status == 'ready').length;
  int get failedCount => items.where((i) => i.status == 'failed').length;
}

/// Upload item.
class TrustedUploadItem {
  const TrustedUploadItem({
    required this.uploadItemId,
    required this.assetId,
    required this.filename,
    required this.status,
    this.errorCode,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uploadItemId;
  final String assetId;
  final String filename;
  final String status;
  final String? errorCode;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TrustedUploadItem.fromJson(Map<String, dynamic> json) {
    return TrustedUploadItem(
      uploadItemId: json['uploadItemId'] as String,
      assetId: json['assetId'] as String,
      filename: json['filename'] as String,
      status: json['status'] as String,
      errorCode: json['errorCode'] as String?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isPending => status == 'pending';
  bool get isUploading => status == 'uploading' || status == 'uploaded_remote';
  bool get isPulling => status == 'pulling_local';
  bool get isReady => status == 'ready';
  bool get isFailed => status == 'failed';
}
