/// Data models for the Web Companion Supabase direct-upload feature.
///
/// All shapes mirror the sidecar response payloads under
/// `/api/web-companion/direct-upload/*`. They intentionally exclude any
/// sensitive fields such as service role keys or local absolute paths.
class DirectUploadConfig {
  const DirectUploadConfig({
    required this.sessionId,
    required this.childId,
    required this.bucket,
    required this.sessionPath,
    required this.supabaseUrl,
    required this.anonKey,
    required this.publicUrl,
    required this.recommendedClientLimit,
    required this.expiresAtHintSeconds,
  });

  final String sessionId;
  final String childId;
  final String bucket;
  final String sessionPath;
  final String supabaseUrl;
  final String anonKey;
  final String publicUrl;
  final int recommendedClientLimit;
  final int expiresAtHintSeconds;

  factory DirectUploadConfig.fromJson(Map<String, dynamic> json) {
    return DirectUploadConfig(
      sessionId: _readString(json, 'sessionId'),
      childId: _readString(json, 'childId'),
      bucket: _readString(json, 'bucket'),
      sessionPath: _readString(json, 'sessionPath'),
      supabaseUrl: _readString(json, 'supabaseUrl'),
      anonKey: _readString(json, 'anonKey'),
      publicUrl: _readString(json, 'publicUrl'),
      recommendedClientLimit: _readInt(json, 'recommendedClientLimit', 200),
      expiresAtHintSeconds: _readInt(json, 'expiresAtHintSeconds', 0),
    );
  }
}

/// One pull-back row reported by the sidecar. `status` follows the
/// `pending_remote → downloading → ready / failed` state machine.
class DirectUploadStatusItem {
  const DirectUploadStatusItem({
    required this.objectKey,
    required this.status,
    this.assetId,
    this.errorCode,
    this.errorMessage,
  });

  final String objectKey;
  final String status;
  final String? assetId;
  final String? errorCode;
  final String? errorMessage;

  factory DirectUploadStatusItem.fromJson(Map<String, dynamic> json) {
    return DirectUploadStatusItem(
      objectKey: _readString(json, 'objectKey'),
      status: _readString(json, 'status'),
      assetId: _readNullableString(json, 'assetId'),
      errorCode: _readNullableString(json, 'errorCode'),
      errorMessage: _readNullableString(json, 'errorMessage'),
    );
  }

  /// Best-effort extraction of the original filename from `objectKey`.
  String get displayName {
    final slash = objectKey.lastIndexOf('/');
    if (slash < 0 || slash == objectKey.length - 1) return objectKey;
    return objectKey.substring(slash + 1);
  }
}

class DirectUploadStatusSummary {
  const DirectUploadStatusSummary({
    required this.pendingRemote,
    required this.downloading,
    required this.ready,
    required this.failed,
  });

  final int pendingRemote;
  final int downloading;
  final int ready;
  final int failed;

  factory DirectUploadStatusSummary.fromJson(Map<String, dynamic> json) {
    return DirectUploadStatusSummary(
      pendingRemote: _readInt(json, 'pending_remote', 0),
      downloading: _readInt(json, 'downloading', 0),
      ready: _readInt(json, 'ready', 0),
      failed: _readInt(json, 'failed', 0),
    );
  }
}

class DirectUploadStatusSnapshot {
  const DirectUploadStatusSnapshot({
    required this.sessionId,
    required this.items,
    required this.summary,
  });

  final String sessionId;
  final List<DirectUploadStatusItem> items;
  final DirectUploadStatusSummary summary;

  factory DirectUploadStatusSnapshot.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <DirectUploadStatusItem>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        if (entry is Map<String, dynamic>) {
          items.add(DirectUploadStatusItem.fromJson(entry));
        }
      }
    }
    final summaryRaw = json['summary'];
    final summary = summaryRaw is Map<String, dynamic>
        ? DirectUploadStatusSummary.fromJson(summaryRaw)
        : const DirectUploadStatusSummary(
            pendingRemote: 0,
            downloading: 0,
            ready: 0,
            failed: 0,
          );
    return DirectUploadStatusSnapshot(
      sessionId: _readString(json, 'sessionId'),
      items: items,
      summary: summary,
    );
  }
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  if (value == null) return '';
  return value.toString();
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  return null;
}

int _readInt(Map<String, dynamic> json, String key, int fallback) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
