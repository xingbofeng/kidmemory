import 'package:flutter/material.dart';

import '../../shared/models/library_models.dart';

import 'asset_library_controller.dart';
import 'asset_library_page.dart';

mixin AssetLibraryMetadataActions on State<AssetLibraryPage> {
  TextEditingController get titleController;
  TextEditingController get descriptionController;
  TextEditingController get tagsController;
  TextEditingController get capturedAtController;
  AssetVm? get selectedAsset;
  bool get metadataDirty;
  set metadataDirty(bool value);
  bool get syncingEditor;
  set syncingEditor(bool value);
  String get typeValue;
  set typeValue(String value);
  String get capturedAt;
  set capturedAt(String value);

  void syncEditor() {
    syncingEditor = true;
    metadataDirty = false;
    final asset = selectedAsset;
    titleController.text = asset?.title ?? '';
    descriptionController.text = asset?.description ?? '';
    tagsController.text = asset?.tags.join(', ') ?? '';
    final assetType =
        asset?.type ?? AssetLibraryController.defaultTypeFromOptions(widget.typeOptions);
    typeValue = AssetLibraryController.containsType(widget.typeOptions, assetType)
        ? assetType
        : AssetLibraryController.defaultTypeFromOptions(widget.typeOptions);
    capturedAt = asset?.capturedAt ?? '';
    capturedAtController.text = capturedAt;
    syncingEditor = false;
  }

  void markMetadataDirty() {
    if (syncingEditor) return;
    if (selectedAsset == null || metadataDirty) return;
    setState(() => metadataDirty = true);
  }
}
