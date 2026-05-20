part of 'asset_library_page.dart';

class _AssetLibraryPageWindow {
  const _AssetLibraryPageWindow({
    required this.currentPage,
    required this.totalPages,
    required this.pageAssets,
  });

  final int currentPage;
  final int totalPages;
  final List<AssetVm> pageAssets;
}

class _AssetLibraryController {
  const _AssetLibraryController._();

  static List<AssetVm> displayedAssets({
    required List<AssetVm> baseAssets,
    required List<AssetVm> semanticSearchResults,
    required bool semanticSearchActive,
  }) {
    return semanticSearchActive ? semanticSearchResults : baseAssets;
  }

  static AssetVm? selectedAsset(List<AssetVm> source, String? selectedAssetId) {
    if (source.isEmpty) return null;
    final id = selectedAssetId ?? source.first.id;
    return source.firstWhere(
      (asset) => asset.id == id,
      orElse: () => source.first,
    );
  }

  static _AssetLibraryPageWindow pageWindow({
    required List<AssetVm> assets,
    required int pageIndex,
    required int pageSize,
  }) {
    final totalPages = assets.isEmpty
        ? 1
        : ((assets.length - 1) ~/ pageSize) + 1;
    final currentPage = pageIndex.clamp(0, totalPages - 1).toInt();
    final pageAssets = assets
        .skip(currentPage * pageSize)
        .take(pageSize)
        .toList();
    return _AssetLibraryPageWindow(
      currentPage: currentPage,
      totalPages: totalPages,
      pageAssets: pageAssets,
    );
  }

  static List<AssetVm> selectedBasketAssets({
    required List<AssetVm> baseAssets,
    required List<AssetVm> semanticSearchResults,
    required Set<String> selectedAssetIds,
  }) {
    final byId = <String, AssetVm>{
      for (final asset in baseAssets) asset.id: asset,
      for (final asset in semanticSearchResults) asset.id: asset,
    };
    return selectedAssetIds.map((id) => byId[id]).whereType<AssetVm>().toList();
  }

  static List<AssetVm> filteredAssets({
    required List<AssetVm> assets,
    required String query,
    required String selectedFilterType,
    required String sortMode,
    required bool semanticSearchActive,
    required List<Map<String, String>> typeOptions,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = assets.where((asset) {
      if (selectedFilterType != 'all' && asset.type != selectedFilterType) {
        return false;
      }
      if (semanticSearchActive || normalizedQuery.isEmpty) return true;
      final haystack = [
        asset.title,
        asset.description,
        asset.type,
        displayType(typeOptions, asset.type),
        asset.originalFilename,
        ...asset.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList();
    if (!semanticSearchActive) {
      filtered.sort(
        (a, b) =>
            _compareBySort(a, b, sortMode: sortMode, typeOptions: typeOptions),
      );
    }
    return filtered;
  }

  static String displayType(List<Map<String, String>> options, String value) {
    final normalized = sanitizeTypeOptions(options);
    for (final option in normalized) {
      if (option['value'] == value) return option['label'] ?? value;
    }
    return value;
  }

  static bool containsType(List<Map<String, String>> options, String value) {
    return options.any((option) => option['value'] == value);
  }

  static String defaultTypeFromOptions(List<Map<String, String>> options) {
    final normalized = sanitizeTypeOptions(options);
    return normalized.isNotEmpty ? (normalized.first['value'] ?? 'all') : 'all';
  }

  static List<Map<String, String>> sanitizeTypeOptions(
    List<Map<String, String>> options,
  ) {
    final normalized = options
        .where(
          (option) =>
              (option['value'] ?? '').trim().isNotEmpty &&
              (option['label'] ?? '').trim().isNotEmpty,
        )
        .map(
          (option) => {
            'value': option['value']!.trim(),
            'label': option['label']!.trim(),
          },
        )
        .toList();
    if (normalized.isNotEmpty) return normalized;
    return [
      {'value': 'all', 'label': 'all'},
      {'value': 'artwork', 'label': 'artwork'},
      {'value': 'photo', 'label': 'photo'},
      {'value': 'craft', 'label': 'craft'},
    ];
  }

  static int _compareBySort(
    AssetVm a,
    AssetVm b, {
    required String sortMode,
    required List<Map<String, String>> typeOptions,
  }) {
    return switch (sortMode) {
      'created_asc' => _compareCapturedAt(a, b, newestFirst: false),
      'type' => _compareType(a, b, typeOptions: typeOptions),
      'title' => _compareTitle(a, b),
      _ => _compareCapturedAt(a, b, newestFirst: true),
    };
  }

  static int _compareType(
    AssetVm a,
    AssetVm b, {
    required List<Map<String, String>> typeOptions,
  }) {
    final result = _typeSortIndex(
      a.type,
      typeOptions,
    ).compareTo(_typeSortIndex(b.type, typeOptions));
    if (result != 0) return result;
    return _compareCapturedAt(a, b, newestFirst: true);
  }

  static int _typeSortIndex(
    String type,
    List<Map<String, String>> typeOptions,
  ) {
    final options = sanitizeTypeOptions(
      typeOptions,
    ).where((option) => option['value'] != 'all').toList();
    final index = options.indexWhere((option) => option['value'] == type);
    return index == -1 ? options.length : index;
  }

  static int _compareTitle(AssetVm a, AssetVm b) {
    final result = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    if (result != 0) return result;
    return a.id.compareTo(b.id);
  }

  static int _compareCapturedAt(
    AssetVm a,
    AssetVm b, {
    required bool newestFirst,
  }) {
    final aDate = DateTime.tryParse(a.capturedAt);
    final bDate = DateTime.tryParse(b.capturedAt);
    if (aDate == null && bDate == null) return _compareTitle(a, b);
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    final result = aDate.compareTo(bDate);
    if (result != 0) return newestFirst ? -result : result;
    return _compareTitle(a, b);
  }
}
