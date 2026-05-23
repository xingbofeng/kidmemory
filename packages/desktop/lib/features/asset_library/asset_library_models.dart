class AssetImportReport {
  const AssetImportReport({
    required this.imported,
    required this.duplicates,
    required this.failed,
    required this.skipped,
    this.message = '',
    this.title = '',
  });

  final int imported;
  final int duplicates;
  final int failed;
  final int skipped;
  final String message;
  final String title;
}

class AssetMetadataUpdate {
  const AssetMetadataUpdate({
    required this.title,
    required this.description,
    required this.tags,
    required this.capturedAt,
    required this.type,
  });

  final String title;
  final String description;
  final List<String> tags;
  final String? capturedAt;
  final String type;

  Map<String, dynamic> toPayload() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'capturedAt': capturedAt,
      'type': type,
    };
  }
}
