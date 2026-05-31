import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';
import 'asset_library_palette.dart';

class ReadonlyToolbarField extends StatelessWidget {
  const ReadonlyToolbarField({
    super.key,
    required this.iconAsset,
    required this.label,
  });

  final String iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AssetLibraryPalette.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AssetLibraryPalette.fieldBorder),
      ),
      child: Row(
        children: [
          AppAssetIcon(iconAsset, size: compactInlineIconSize, opacity: 0.86),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AssetLibraryPalette.bodyStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ToolbarLabeledField extends StatelessWidget {
  const ToolbarLabeledField({
    super.key,
    required this.label,
    required this.child,
    required this.width,
  });

  final String label;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Text(
            '$label：',
            style: const TextStyle(
              color: AssetLibraryPalette.bodyMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class InlineStatusChip extends StatelessWidget {
  const InlineStatusChip({
    super.key,
    required this.iconAsset,
    required this.label,
    this.onPressed,
  });

  final String iconAsset;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: AppAssetIcon(iconAsset, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AssetLibraryPalette.bodyStrong,
          side: const BorderSide(color: AssetLibraryPalette.fieldBorder),
          backgroundColor: AssetLibraryPalette.fieldFill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class AssetLibraryToolbarButton extends StatelessWidget {
  const AssetLibraryToolbarButton({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onPressed,
  });

  final String iconAsset;
  final String label;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: AppAssetIcon(iconAsset, size: compactInlineIconSize),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AssetLibraryPalette.successAction,
          side: const BorderSide(
            color: AssetLibraryPalette.successStrongBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AssetLibraryPalette.successSoft,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class IndexingStatusPill extends StatelessWidget {
  const IndexingStatusPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AssetLibraryPalette.successSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AssetLibraryPalette.successBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppAssetIcon(completeIconAsset, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AssetLibraryPalette.successBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AssetLibrarySearchStatusStrip extends StatelessWidget {
  const AssetLibrarySearchStatusStrip({
    super.key,
    required this.text,
    required this.active,
    this.onClear,
  });

  final String text;
  final bool active;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: active
            ? AssetLibraryPalette.activeSoft
            : AssetLibraryPalette.neutralSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? AssetLibraryPalette.activeBorder
              : AssetLibraryPalette.neutralBorder,
        ),
      ),
      child: Row(
        children: [
          AppAssetIcon(
            active ? searchIconAsset : infoIconAsset,
            size: 16,
            opacity: active ? 1 : 0.72,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: active
                    ? AssetLibraryPalette.activeText
                    : AssetLibraryPalette.neutralText,
                fontSize: 12,
              ),
            ),
          ),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              child: Text(
                AppLocalizations.of(context)!.assetLibraryClearSearchLabel,
              ),
            ),
        ],
      ),
    );
  }
}
