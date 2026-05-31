import 'package:flutter/material.dart';

import 'asset_library_palette.dart';
import 'asset_library_toolbar_controls.dart';

class AssetLibraryStatusBar extends StatelessWidget {
  const AssetLibraryStatusBar({
    super.key,
    required this.typeOptions,
    required this.selectedType,
    required this.counts,
    required this.indexingMessage,
    required this.onChanged,
  });

  final List<Map<String, String>> typeOptions;
  final String selectedType;
  final Map<String, int> counts;
  final String indexingMessage;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final segmented = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xfffffcf7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AssetLibraryPalette.fieldBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < typeOptions.length; index++) ...[
              AssetLibrarySegmentOption(
                label: typeOptions[index]['label'] ?? '',
                count: counts[typeOptions[index]['value']] ?? 0,
                selected: selectedType == typeOptions[index]['value'],
                onTap: () => onChanged(typeOptions[index]['value'] ?? 'all'),
              ),
              if (index != typeOptions.length - 1) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
    final status = IndexingStatusPill(text: indexingMessage);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [segmented, const SizedBox(height: 8), status],
          );
        }
        return Row(
          children: [
            Expanded(child: segmented),
            const SizedBox(width: 12),
            status,
          ],
        );
      },
    );
  }
}

class AssetLibrarySegmentOption extends StatelessWidget {
  const AssetLibrarySegmentOption({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? AssetLibraryPalette.successTint
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: AssetLibraryPalette.successStrongBorder)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AssetLibraryPalette.successText
                    : AssetLibraryPalette.bodyMuted,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                color: selected
                    ? AssetLibraryPalette.successText
                    : AssetLibraryPalette.bodyMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
