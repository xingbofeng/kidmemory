part of '../../desktop_shell.dart';

extension _DesktopShellImportPreview on _DesktopShellState {
  List<AssetPreviewItem> get _samplePreviewAssets {
    final seenLabels = <String, int>{};
    return assets.map((asset) {
      final typeLabel = _assetTypeLabel(asset.type);
      final label = _uniquePreviewLabel(
        asset.title,
        typeLabel: typeLabel,
        seenLabels: seenLabels,
      );
      return AssetPreviewItem(
        label: label,
        icon: _assetIcon(asset.type),
        iconAsset: _assetIconAsset(asset.type),
        typeLabel: typeLabel,
        path: asset.previewUrl.isNotEmpty
            ? asset.previewUrl
            : (asset.thumbnailPath.isNotEmpty
                  ? asset.thumbnailPath
                  : asset.imagePath),
      );
    }).toList();
  }

  String _uniquePreviewLabel(
    String rawLabel, {
    required String typeLabel,
    required Map<String, int> seenLabels,
  }) {
    final label = rawLabel.trim().isEmpty
        ? AppLocalizations.of(context)!.importPreviewS578
        : rawLabel.trim();
    final seen = seenLabels[label] ?? 0;
    seenLabels[label] = seen + 1;
    if (seen == 0) return label;
    final dotIndex = label.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == label.length - 1) {
      return '$label-$typeLabel';
    }
    return '${label.substring(0, dotIndex)}-$typeLabel${label.substring(dotIndex)}';
  }

  int _countAssetsByType(List<AssetVm> sourceAssets, String type) =>
      sourceAssets.where((asset) => asset.type == type).length;

  int _countUniqueTags(List<AssetVm> sourceAssets) {
    final tags = <String>{};
    for (final asset in sourceAssets) {
      for (final tag in asset.tags) {
        final normalized = tag.trim();
        if (normalized.isNotEmpty) tags.add(normalized);
      }
    }
    return tags.length;
  }

  IconData _assetIcon(String type) {
    return switch (type) {
      'photo' => Icons.photo_camera,
      'craft' => Icons.build,
      _ => Icons.palette,
    };
  }

  String _assetTypeLabel(String type) {
    return switch (type) {
      'photo' => AppLocalizations.of(context)!.contentAssetTypePhotoLabel,
      'craft' => AppLocalizations.of(context)!.contentAssetTypeCraftLabel,
      _ => AppLocalizations.of(context)!.contentCategoryArtworkLabel,
    };
  }

  String _assetIconAsset(String type) {
    return switch (type) {
      'photo' => cameraIconAsset,
      'craft' => bearDocumentIconAsset,
      _ => paletteIconAsset,
    };
  }

  AssetVm _assetFromRecord(
    AssetRecordDto dto, {
    List<String> matchReasons = const [],
  }) {
    final explicitPreviewUrl = dto.previewUrlValue;
    return AssetVm(
      id: dto.idValue,
      title: dto.titleValue,
      type: dto.typeValue,
      description: dto.descriptionValue,
      tags: dto.tagsValue,
      capturedAt: dto.capturedAtValue,
      imagePath: dto.imagePathValue,
      thumbnailPath: dto.thumbnailPathValue,
      previewUrl: explicitPreviewUrl.isNotEmpty
          ? explicitPreviewUrl
          : '${api.baseUrl}/assets/${dto.idValue}/preview',
      originalFilename: dto.originalFilenameValue,
      storageStatus: dto.storageStatusValue,
      matchReasons: matchReasons,
      icon: switch (dto.typeValue) {
        'photo' => Icons.photo_camera,
        'craft' => Icons.build,
        _ => Icons.palette,
      },
    );
  }
}
