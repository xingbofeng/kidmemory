import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../shared/widgets/layout.dart';
import '../generate_export_assets.dart';

class SmartGenerateActions extends StatefulWidget {
  const SmartGenerateActions({
    required this.selectedCount,
    required this.generating,
    required this.selectedCreationType,
    required this.creationGoal,
    required this.onGoalChanged,
    required this.onCreationTypeChanged,
    required this.onGenerate,
    super.key,
  });

  final int selectedCount;
  final bool generating;
  final String selectedCreationType;
  final String creationGoal;
  final ValueChanged<String>? onGoalChanged;
  final ValueChanged<String>? onCreationTypeChanged;
  final VoidCallback? onGenerate;

  @override
  State<SmartGenerateActions> createState() => _SmartGenerateActionsState();
}

class _SmartGenerateActionsState extends State<SmartGenerateActions> {
  late final TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: widget.creationGoal);
  }

  @override
  void didUpdateWidget(covariant SmartGenerateActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.creationGoal != oldWidget.creationGoal &&
        widget.creationGoal != _goalController.text) {
      _goalController.text = widget.creationGoal;
      _goalController.selection = TextSelection.collapsed(
        offset: _goalController.text.length,
      );
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canStart =
        widget.selectedCount > 0 &&
        !widget.generating &&
        widget.onGenerate != null;
    final canEdit = !widget.generating;
    final l10n = AppLocalizations.of(context)!;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.generateExportS237,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.generateExportGoalSubtitle,
            style: const TextStyle(
              color: Color(0xff6f6258),
              height: 1.35,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xfffffdf9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffeadccf)),
            ),
            child: Row(
              children: [
                const AppAssetIcon(magicStarIconAsset, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    enabled: canEdit && widget.onGoalChanged != null,
                    maxLength: 200,
                    buildCounter:
                        (
                          context, {
                          required currentLength,
                          required isFocused,
                          required maxLength,
                        }) => const SizedBox.shrink(),
                    onChanged: (value) {
                      setState(() {});
                      widget.onGoalChanged?.call(value);
                    },
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: l10n.generateExportGoalHint,
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintStyle: const TextStyle(
                        color: Color(0xff8f8072),
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_goalController.text.length} / 200',
                  style: TextStyle(
                    color: Color(0xff8f8072),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.generateExportCreationTypeTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: _CreativeTypeCard(
                  title: AppLocalizations.of(context)!.generateExportS721,
                  description: l10n.generateExportStorybookDescription,
                  tagText: l10n.generateExportStorybookTag,
                  iconAsset: creationComposeIconAsset,
                  iconSize: 80,
                  selected: widget.selectedCreationType == 'storybook',
                  onPressed: widget.onCreationTypeChanged == null
                      ? null
                      : () => widget.onCreationTypeChanged!('storybook'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _CreativeTypeCard(
                  title: AppLocalizations.of(context)!.generateExportS740,
                  description: l10n.generateExportMemoryBookDescription,
                  tagText: l10n.generateExportMemoryBookTag,
                  iconAsset: bearDocumentIconAsset,
                  iconSize: 76,
                  selected: widget.selectedCreationType == 'memory_book',
                  onPressed: widget.onCreationTypeChanged == null
                      ? null
                      : () => widget.onCreationTypeChanged!('memory_book'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _CreativeTypeCard(
                  title: AppLocalizations.of(
                    context,
                  )!.assetLibraryBatchGenerateVideoLabel,
                  description: l10n.generateExportMemoryVideoDescription,
                  tagText: l10n.generateExportMemoryVideoTag,
                  iconAsset: creationVideoBoardIconAsset,
                  iconSize: 76,
                  selected: widget.selectedCreationType == 'memoir_video',
                  onPressed: widget.onCreationTypeChanged == null
                      ? null
                      : () => widget.onCreationTypeChanged!('memoir_video'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          _AssetStatusStrip(selectedCount: widget.selectedCount),
          const SizedBox(height: 7),
          PrimaryButton(
            label: AppLocalizations.of(
              context,
            )!.generateExportStartPlanningAction,
            onPressed: canStart ? widget.onGenerate : null,
            height: 42,
            fontSize: 15,
            backgroundColor: const Color(0xff3f9460),
            disabledBackgroundColor: const Color(0xffd7dfd6),
            disabledForegroundColor: const Color(0xfff6faf7),
          ),
          if (!canStart) ...[
            const SizedBox(height: 9),
            Center(
              child: Text(
                l10n.generateExportSelectAssetsBeforeStart,
                style: const TextStyle(
                  color: Color(0xffc0aa90),
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreativeTypeCard extends StatelessWidget {
  const _CreativeTypeCard({
    required this.title,
    required this.description,
    required this.tagText,
    required this.iconAsset,
    this.iconSize = 42,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String tagText;
  final String iconAsset;
  final double iconSize;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? const Color(0xff157b41)
        : const Color(0xff2d241c);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(minHeight: 124),
        padding: const EdgeInsets.fromLTRB(17, 14, 13, 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffedf8ef) : const Color(0xfffffcf8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xffa9d6b4) : const Color(0xffe6d9c9),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAssetIcon(iconAsset, size: iconSize),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foreground,
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
                          ),
                        ),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff7a6a5b),
                            fontSize: 12.8,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xfffff0dc),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tagText,
                            style: const TextStyle(
                              color: Color(0xff8d6025),
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: selected ? 10 : 11,
                height: selected ? 10 : 11,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xff4aa062)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? const Color(0xff4aa062)
                        : const Color(0xffd6c9b7),
                    width: selected ? 0 : 1,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetStatusStrip extends StatelessWidget {
  const _AssetStatusStrip({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        color: const Color(0xfffffcf7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffeadccf)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppAssetIcon(imageIconAsset, size: 21),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.generateExportS821,
                        style: const TextStyle(
                          color: Color(0xff5b4f45),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        l10n.generateExportSelectedAssetCount(selectedCount),
                        style: const TextStyle(
                          color: Color(0xff2e261f),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        l10n.generateExportAssetRecommendation,
                        style: const TextStyle(
                          color: Color(0xff7a6a5b),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 252,
            child: Column(
              children: [
                const Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: Color(0xffd9a48f)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Divider(
                          color: Color(0xffdfd4c6),
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                    ),
                    CircleAvatar(radius: 4, backgroundColor: Color(0xff86ad87)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Divider(
                          color: Color(0xffdfd4c6),
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                    ),
                    CircleAvatar(radius: 4, backgroundColor: Color(0xffc9c2b7)),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.generateExportAssetProgressCurrent,
                      style: const TextStyle(
                        color: Color(0xffbe957f),
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      l10n.generateExportAssetProgressRecommended,
                      style: const TextStyle(
                        color: Color(0xff4f8d58),
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      l10n.generateExportAssetProgressBetter,
                      style: const TextStyle(
                        color: Color(0xff8b8074),
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 19,
            height: 19,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffd9cbbb)),
              color: const Color(0xfffffcf7),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '?',
              style: TextStyle(
                color: Color(0xff9f907f),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedOutlineBox extends StatelessWidget {
  const DashedOutlineBox({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedRRectPainter(),
      child: ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = const Color(0xffb98f68)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            border.strokeWidth / 2,
            border.strokeWidth / 2,
            size.width - border.strokeWidth,
            size.height - border.strokeWidth,
          ),
          const Radius.circular(14),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        const dash = 8.0;
        const gap = 4.0;
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), border);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return false;
  }
}

class AssetInputCard extends StatelessWidget {
  const AssetInputCard({
    required this.count,
    required this.onViewSelectedAssets,
    super.key,
  });

  final int count;
  final VoidCallback onViewSelectedAssets;

  @override
  Widget build(BuildContext context) {
    final hasAssets = count > 0;
    final l10n = AppLocalizations.of(context)!;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.generateExportAssetPreparationTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.generateExportAssetPreparationSubtitle,
                  style: const TextStyle(
                    color: Color(0xff7a6a5b),
                    fontSize: 13,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: const AppAssetIcon(leafIconAsset, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: DashedOutlineBox(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 94),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    color: const Color(0xfffffdf9),
                    child: Row(
                      children: [
                        const AppAssetIcon(
                          creationEmptyPhotosIconAsset,
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasAssets
                                    ? l10n.generateExportSelectedAssetCount(
                                        count,
                                      )
                                    : l10n.generateExportNoSelectedAssets,
                                style: const TextStyle(
                                  color: Color(0xff2e261f),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                hasAssets
                                    ? l10n.generateExportSelectedAssetsReadyHint
                                    : l10n.generateExportSelectAssetsEmptyHint,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff7a6a5b),
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 188,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SecondaryButton(
                      label: AppLocalizations.of(context)!.generateExportS324,
                      iconAsset: gridIconAsset,
                      onPressed: onViewSelectedAssets,
                      fullWidth: true,
                      height: 32,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 6),
                    SecondaryButton(
                      label: l10n.generateExportS102,
                      iconAsset: magicStarIconAsset,
                      onPressed: onViewSelectedAssets,
                      fullWidth: true,
                      height: 32,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
