import '../../shared/models/library_models.dart';

import 'asset_library_controller.dart';

String? selectedAssetLibraryChildName(
  List<ChildVm> children,
  String? selectedChildId,
) {
  if (selectedChildId == null) {
    return children.isEmpty ? null : children.first.name;
  }
  for (final child in children) {
    if (child.id == selectedChildId) return child.name;
  }
  return children.isEmpty ? null : children.first.name;
}

Map<String, int> assetLibraryTypeCounts(List<AssetVm> assets) {
  final counts = <String, int>{'all': assets.length};
  for (final asset in assets) {
    counts[asset.type] = (counts[asset.type] ?? 0) + 1;
  }
  return counts;
}

String assetLibraryDisplayType(
  List<Map<String, String>> typeOptions,
  String value,
) {
  return AssetLibraryController.displayType(typeOptions, value);
}
