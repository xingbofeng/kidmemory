// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'child_profile_empty_hero.dart';
import 'child_profile_empty_privacy.dart';
import '../../../shared/widgets/chrome.dart';
import '../../../../l10n/app_localizations.dart';

class EmptyChildProfilePage extends StatelessWidget {
  const EmptyChildProfilePage({
    required this.onAddProfile,
    required this.onTrySample,
  });

  final VoidCallback onAddProfile;
  final VoidCallback onTrySample;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('empty-child-profile-page'),
    padding: const EdgeInsets.fromLTRB(44, 38, 44, 42),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xfffffcf6), Color(0xfffbf6ed)],
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final medium = constraints.maxWidth < 1180;
        final horizontalGap = medium ? 20.0 : 28.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EmptyProfileTitleBlock(),
            SizedBox(height: medium ? 26 : 34),
            Expanded(
              child: compact
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 620,
                            child: EmptyHeroCard(
                              onAddProfile: onAddProfile,
                              onTrySample: onTrySample,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const SizedBox(
                            height: 620,
                            child: EmptyPrivacyCard(),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: medium ? 16 : 21,
                          child: EmptyHeroCard(
                            onAddProfile: onAddProfile,
                            onTrySample: onTrySample,
                          ),
                        ),
                        SizedBox(width: horizontalGap),
                        Expanded(
                          flex: medium ? 9 : 10,
                          child: const EmptyPrivacyCard(),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    ),
  );
}

class EmptyProfileTitleBlock extends StatelessWidget {
  const EmptyProfileTitleBlock();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAssetIcon(leafIconAsset, size: 25),
          SizedBox(width: 9),
          Text(
            'KidMemory',
            style: TextStyle(
              color: Color(0xff3f9d56),
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      const SizedBox(height: 42),
      Text(
        AppLocalizations.of(context)!.childProfileTitle,
        style: const TextStyle(
          color: Color(0xff28170f),
          fontSize: 46,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: -1.4,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        AppLocalizations.of(context)!.childProfileS715,
        style: const TextStyle(
          color: Color(0xff8a8177),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}
