import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../shared/models/library_models.dart';

import 'asset_library_controller.dart';
import 'asset_library_page.dart';

mixin AssetLibraryLifecycleActions on State<AssetLibraryPage> {
  String get typeValue;
  set typeValue(String value);
  String get selectedFilterType;
  set selectedFilterType(String value);
  List<AssetVm> get semanticSearchResults;
  set semanticSearchResults(List<AssetVm> value);
  bool get semanticSearchActive;
  set semanticSearchActive(bool value);
  String get searchStatusMessage;
  set searchStatusMessage(String value);

  void syncEditor();
  Future<void> refreshSearchIndexingStatus();

  void initializeTypeDefaults() {
    typeValue = AssetLibraryController.containsType(widget.typeOptions, typeValue)
        ? typeValue
        : AssetLibraryController.defaultTypeFromOptions(widget.typeOptions);
    selectedFilterType = AssetLibraryController.containsType(
      widget.typeOptions,
      selectedFilterType,
    )
        ? selectedFilterType
        : AssetLibraryController.defaultTypeFromOptions(widget.typeOptions);
  }

  void handleWidgetUpdated(AssetLibraryPage oldWidget) {
    if (oldWidget.typeOptions != widget.typeOptions) {
      handleTypeOptionsChanged();
    }
    if (oldWidget.selectedChildId != widget.selectedChildId) {
      handleSelectedChildChanged();
    }
    if (oldWidget.assets != widget.assets) syncEditor();
  }

  void handleTypeOptionsChanged() {
    final defaultType = AssetLibraryController.defaultTypeFromOptions(widget.typeOptions);
    if (!AssetLibraryController.containsType(widget.typeOptions, typeValue)) {
      typeValue = defaultType;
    }
    if (!AssetLibraryController.containsType(widget.typeOptions, selectedFilterType)) {
      selectedFilterType = defaultType;
    }
    syncEditor();
  }

  void handleSelectedChildChanged() {
    semanticSearchActive = false;
    semanticSearchResults = const [];
    searchStatusMessage = AppLocalizations.of(context)!.assetLibraryPageS433;
    refreshSearchIndexingStatus();
  }
}
