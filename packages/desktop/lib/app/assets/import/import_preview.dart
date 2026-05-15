part of '../../desktop_shell.dart';

extension _DesktopShellImportPreview on _DesktopShellState {
  List<AssetPreviewItem> get _samplePreviewAssets {
    return assets
        .map(
          (asset) => AssetPreviewItem(
            label: asset.title,
            icon: _assetIcon(asset.type),
            iconAsset: _assetIconAsset(asset.type),
            path: asset.previewUrl.isNotEmpty
                ? asset.previewUrl
                : (asset.thumbnailPath.isNotEmpty
                      ? asset.thumbnailPath
                      : asset.imagePath),
          ),
        )
        .toList();
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
    final explicitPreviewUrl = dto.previewUrl;
    return AssetVm(
      id: dto.id,
      title: dto.title,
      type: dto.type,
      description: dto.description,
      tags: dto.tags,
      capturedAt: dto.capturedAt,
      imagePath: dto.imagePath,
      thumbnailPath: dto.thumbnailPath,
      previewUrl: explicitPreviewUrl.isNotEmpty
          ? explicitPreviewUrl
          : '${api.baseUrl}/assets/${dto.id}/preview',
      originalFilename: dto.originalFilename,
      storageStatus: dto.storageStatus,
      matchReasons: matchReasons,
      icon: switch (dto.type) {
        'photo' => Icons.photo_camera,
        'craft' => Icons.build,
        _ => Icons.palette,
      },
    );
  }
}
