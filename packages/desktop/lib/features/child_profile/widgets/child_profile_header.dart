// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../../../shared/models/library_models.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/content.dart';
import '../../../shared/widgets/layout.dart';
import '../../../../l10n/app_localizations.dart';

class ChildProfilePortrait extends StatelessWidget {
  const ChildProfilePortrait({
    required this.childName,
    required this.imagePath,
  });

  final String childName;
  final String imagePath;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    height: 190,
    child: imagePath.trim().isEmpty
        ? WarmPicture(
            icon: Icons.child_care_rounded,
            assetPath: childIconAsset,
            label: childName,
          )
        : AssetArtworkPreview(
            path: imagePath,
            fallbackIcon: Icons.child_care_rounded,
            fallbackAssetPath: childIconAsset,
            label: childName,
            width: 190,
            height: 190,
            fit: BoxFit.cover,
          ),
  );
}

AssetVm? childProfileImageAsset(List<AssetVm> assets) {
  for (final asset in assets) {
    if (asset.previewPath.trim().isNotEmpty) {
      return asset;
    }
  }
  return null;
}

class DeleteChildButton extends StatelessWidget {
  const DeleteChildButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xffb84938),
      side: const BorderSide(color: Color(0xffe2b7ae)),
      minimumSize: Size.zero,
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: TextStyle(
        fontSize: compact ? 13 : 17,
        fontWeight: FontWeight.w900,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAssetIcon(
          deleteIconAsset,
          fallbackIcon: Icons.delete_outline_rounded,
          size: compact ? 15 : buttonIconSize,
        ),
        SizedBox(width: compact ? 6 : 8),
        Flexible(
          child: Text(
            AppLocalizations.of(context)!.assetLibraryPageS296,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class ProfileHeaderScene extends StatelessWidget {
  const ProfileHeaderScene({
    required this.children,
    required this.selectedChildId,
    required this.onChildChanged,
    required this.onTrySample,
  });

  final List<ChildVm> children;
  final String? selectedChildId;
  final ValueChanged<String> onChildChanged;
  final VoidCallback onTrySample;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox(width: 520, height: 92);
    }
    final selected = children.firstWhere(
      (child) => child.id == selectedChildId,
      orElse: () => children.first,
    );
    final currentCard = Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xfffbf8f2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffeadfcf)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppAssetIcon(childIconAsset, size: 40),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selected.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.childProfileS480,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff6f6258),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xff3aa15f),
              shape: BoxShape.circle,
            ),
          ),
          if (children.length > 1) ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ],
      ),
    );
    return SizedBox(
      width: 560,
      height: 92,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 128,
              height: 46,
              child: SecondaryButton(
                label: AppLocalizations.of(context)!.childProfileS625,
                icon: Icons.dataset_outlined,
                iconAsset: gridIconAsset,
                fullWidth: true,
                height: 46,
                fontSize: 15,
                iconSize: 18,
                onPressed: onTrySample,
              ),
            ),
            const SizedBox(width: 12),
            children.length > 1
                ? PopupMenuButton<String>(
                    tooltip: AppLocalizations.of(context)!.childProfileS276,
                    onSelected: onChildChanged,
                    position: PopupMenuPosition.under,
                    itemBuilder: (context) => [
                      for (final child in children)
                        PopupMenuItem<String>(
                          value: child.id,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.child_care_rounded, size: 18),
                              const SizedBox(width: 8),
                              Flexible(child: Text(child.name)),
                            ],
                          ),
                        ),
                    ],
                    child: currentCard,
                  )
                : currentCard,
          ],
        ),
      ),
    );
  }
}
