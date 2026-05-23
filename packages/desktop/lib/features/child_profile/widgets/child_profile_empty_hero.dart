// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../../../shared/widgets/chrome.dart';
import '../../../../l10n/app_localizations.dart';
import 'child_profile_empty_artwork.dart';
import 'child_profile_empty_features.dart';

class EmptyHeroCard extends StatelessWidget {
  const EmptyHeroCard({required this.onAddProfile, required this.onTrySample});

  final VoidCallback onAddProfile;
  final VoidCallback onTrySample;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, outerConstraints) {
      final medium = outerConstraints.maxWidth < 760;
      final compactHeight = outerConstraints.maxHeight < 690;
      return EmptyDesignCard(
        padding: medium
            ? const EdgeInsets.fromLTRB(34, 42, 34, 34)
            : const EdgeInsets.fromLTRB(54, 62, 54, 54),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final veryNarrow = constraints.maxWidth < 520;
            final medium = constraints.maxWidth < 760;
            return Stack(
              children: [
                Positioned(
                  left: 22,
                  top: 110,
                  child: DecorDot(size: 10, color: const Color(0xff9fc284)),
                ),
                Positioned(
                  left: 62,
                  top: 72,
                  child: Sparkle(size: 22, color: const Color(0xfff4d487)),
                ),
                Positioned(
                  left: 6,
                  bottom: 198,
                  child: DecorDot(size: 20, color: const Color(0xffeef2dc)),
                ),
                Positioned.fill(
                  child: compactHeight
                      ? SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            children: [
                              veryNarrow
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MemoryBookIllustration(
                                          size: medium ? 220 : 280,
                                        ),
                                        const SizedBox(height: 22),
                                        EmptyHeroCopy(
                                          onAddProfile: onAddProfile,
                                          onTrySample: onTrySample,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          flex: medium ? 7 : 8,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: MemoryBookIllustration(
                                              size: medium ? 240 : 360,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: medium ? 18 : 28),
                                        Expanded(
                                          flex: medium ? 10 : 9,
                                          child: EmptyHeroCopy(
                                            onAddProfile: onAddProfile,
                                            onTrySample: onTrySample,
                                          ),
                                        ),
                                      ],
                                    ),
                              const SizedBox(height: 28),
                              Container(
                                height: 1,
                                color: const Color(0xffe5ded4),
                              ),
                              const SizedBox(height: 26),
                              const EmptyFeatureStrip(),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: veryNarrow
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MemoryBookIllustration(
                                          size: medium ? 220 : 280,
                                        ),
                                        const SizedBox(height: 22),
                                        EmptyHeroCopy(
                                          onAddProfile: onAddProfile,
                                          onTrySample: onTrySample,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          flex: medium ? 7 : 8,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: MemoryBookIllustration(
                                              size: medium ? 240 : 360,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: medium ? 18 : 28),
                                        Expanded(
                                          flex: medium ? 10 : 9,
                                          child: EmptyHeroCopy(
                                            onAddProfile: onAddProfile,
                                            onTrySample: onTrySample,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 28),
                            Container(
                              height: 1,
                              color: const Color(0xffe5ded4),
                            ),
                            const SizedBox(height: 26),
                            const EmptyFeatureStrip(),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

class EmptyHeroCopy extends StatelessWidget {
  const EmptyHeroCopy({required this.onAddProfile, required this.onTrySample});

  final VoidCallback onAddProfile;
  final VoidCallback onTrySample;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 330;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 14 : 18,
                vertical: compact ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffe8f2e0),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppAssetIcon(leafIconAsset, size: 20),
                  const SizedBox(width: 9),
                  Text(
                    AppLocalizations.of(context)!.childProfileS645,
                    style: TextStyle(
                      color: const Color(0xff419a57),
                      fontSize: compact ? 14 : 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: compact ? 20 : 30),
          Text(
            AppLocalizations.of(context)!.childProfileS887,
            style: TextStyle(
              color: const Color(0xff28170f),
              fontSize: compact ? 34 : 44,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -1.2,
            ),
          ),
          SizedBox(height: compact ? 18 : 24),
          Text(
            AppLocalizations.of(context)!.childProfileEmptyDescription,
            style: TextStyle(
              color: const Color(0xff766b61),
              fontSize: compact ? 15 : 18,
              fontWeight: FontWeight.w700,
              height: 1.65,
            ),
          ),
          SizedBox(height: compact ? 26 : 38),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: compact ? 50 : 58,
                  child: FilledButton(
                    onPressed: onAddProfile,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff43a955),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0x3343a955),
                      textStyle: TextStyle(
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const WhiteCircleIcon(icon: Icons.add_rounded),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.childProfileS693,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: compact ? 50 : 58,
                  child: OutlinedButton(
                    onPressed: onTrySample,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff247348),
                      side: const BorderSide(color: Color(0xffc8ddcc)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: TextStyle(
                        fontSize: compact ? 15 : 17,
                        fontWeight: FontWeight.w900,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppAssetIcon(gridIconAsset, size: 20),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.childProfileS625,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
