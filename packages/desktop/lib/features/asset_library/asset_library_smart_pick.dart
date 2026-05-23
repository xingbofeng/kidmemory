import '../../shared/models/library_models.dart';

List<AssetVm> buildAssetLibrarySmartSuggestion({
  required List<AssetVm> assets,
  required String target,
  required int seed,
}) {
  final sorted = [...assets];

  switch (target) {
    case 'memory_video':
      sorted.sort((a, b) {
        final scoreA = assetLibrarySmartAssetScore(a, preferPhoto: true);
        final scoreB = assetLibrarySmartAssetScore(b, preferPhoto: true);
        return scoreB.compareTo(scoreA);
      });
      break;
    case 'memory_album':
      sorted.sort((a, b) {
        final scoreA = assetLibrarySmartAssetScore(a, preferCraft: true);
        final scoreB = assetLibrarySmartAssetScore(b, preferCraft: true);
        return scoreB.compareTo(scoreA);
      });
      break;
    case 'picture_book':
    default:
      sorted.sort((a, b) {
        final scoreA = assetLibrarySmartAssetScore(a, preferArtwork: true);
        final scoreB = assetLibrarySmartAssetScore(b, preferArtwork: true);
        return scoreB.compareTo(scoreA);
      });
      break;
  }

  if (sorted.length > 1) {
    final shift = seed % sorted.length;
    final rotated = [...sorted.skip(shift), ...sorted.take(shift)];
    return rotated.take(12).toList();
  }
  return sorted.take(12).toList();
}

int assetLibrarySmartAssetScore(
  AssetVm asset, {
  bool preferArtwork = false,
  bool preferPhoto = false,
  bool preferCraft = false,
}) {
  var score = 0;
  if (preferArtwork && asset.type == 'artwork') score += 4;
  if (preferPhoto && asset.type == 'photo') score += 4;
  if (preferCraft && asset.type == 'craft') score += 4;
  if (asset.tags.isNotEmpty) score += 2;
  if (asset.description.trim().isNotEmpty) score += 1;
  if (asset.capturedAt.trim().isNotEmpty) score += 1;
  return score;
}
