import 'package:flutter/material.dart';

import '../../shared/widgets/chrome.dart';

Color childProfileSoftAccent(String key) {
  if (key.contains('camera') || key.contains('photo')) {
    return const Color(0xff5d9be8);
  }
  if (key.contains('palette') || key.contains('artwork')) {
    return const Color(0xffffbd54);
  }
  if (key.contains('book') || key.contains('portfolio')) {
    return const Color(0xff6f9af8);
  }
  return const Color(0xff2faa61);
}
String childProfileAssetIconAsset(String type) {
  return switch (type) {
    'photo' => cameraIconAsset,
    'craft' => bearDocumentIconAsset,
    _ => paletteIconAsset,
  };
}
