import 'package:flutter/material.dart';

// Types imported from other files.
export '../../features/setup/setup_page.dart'
    show SetupCheckVm, SupabaseStorageVm;
export '../../features/generate_export/generate_export_page.dart'
    show ExportResultVm;
export '../../data/sample_assets.dart' show SampleAssetVm;

class ChildVm {
  const ChildVm({
    required this.id,
    required this.name,
    this.birthday = '',
    this.notes = '',
  });

  final String id;
  final String name;
  final String birthday;
  final String notes;
}

class AssetVm {
  const AssetVm({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.tags,
    required this.capturedAt,
    required this.icon,
    this.imagePath = '',
    this.thumbnailPath = '',
    this.previewUrl = '',
    this.originalFilename = '',
    this.storageStatus = '',
    this.matchReasons = const [],
  });

  final String id;
  final String title;
  final String type;
  final String description;
  final List<String> tags;
  final String capturedAt;
  final IconData icon;
  final String imagePath;
  final String thumbnailPath;
  final String previewUrl;
  final String originalFilename;
  final String storageStatus;
  final List<String> matchReasons;

  String get previewPath => previewUrl.isNotEmpty
      ? previewUrl
      : thumbnailPath.isNotEmpty
      ? thumbnailPath
      : imagePath;

  factory AssetVm.fromJson(Map<String, dynamic> json) {
    return AssetVm(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      capturedAt: json['capturedAt'] as String? ?? '',
      icon: Icons.image,
      imagePath: json['imagePath'] as String? ?? '',
      thumbnailPath: json['thumbnailPath'] as String? ?? '',
      previewUrl: json['previewUrl'] as String? ?? '',
      originalFilename: json['originalFilename'] as String? ?? '',
      storageStatus: json['storageStatus'] as String? ?? '',
      matchReasons: (json['matchReasons'] as List?)?.cast<String>() ?? const [],
    );
  }
}

class AssetSearchInput {
  const AssetSearchInput({
    required this.childId,
    required this.query,
    required this.type,
  });

  final String childId;
  final String query;
  final String type;
}

class AssetSearchResult {
  const AssetSearchResult({required this.assets, required this.statusMessage});

  final List<AssetVm> assets;
  final String statusMessage;
}
