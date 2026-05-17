import 'package:flutter/material.dart';

class SampleAssetVm {
  const SampleAssetVm(
    this.id,
    this.title,
    this.type,
    this.icon,
    this.date,
    this.tags, {
    this.imagePath = '',
    this.thumbnailPath = '',
    this.previewUrl = '',
    this.matchReasons = const [],
  });

  final String id;
  final String title;
  final String type;
  final IconData icon;
  final String date;
  final List<String> tags;
  final String imagePath;
  final String thumbnailPath;
  final String previewUrl;
  final List<String> matchReasons;
}
