import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/models/library_models.dart';
import '../../shared/widgets/chrome.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/layout.dart';
import '../../../l10n/app_localizations.dart';

class ChildProfilePage extends StatelessWidget {
  const ChildProfilePage({
    required this.children,
    required this.assets,
    required this.selectedChildId,
    required this.onAddProfile,
    required this.onTrySample,
    required this.onEditProfile,
    required this.onDeleteProfile,
    required this.onChildChanged,
    super.key,
  });

  final List<ChildVm> children;
  final List<AssetVm> assets;
  final String? selectedChildId;
  final VoidCallback onAddProfile;
  final VoidCallback onTrySample;
  final ValueChanged<ChildVm> onEditProfile;
  final ValueChanged<ChildVm> onDeleteProfile;
  final ValueChanged<String> onChildChanged;

  @override
  Widget build(BuildContext context) {
    ChildVm? child;
    for (final item in children) {
      if (item.id == selectedChildId) child = item;
    }
    child ??= children.isNotEmpty ? children.first : null;
    if (child == null) {
      return _EmptyChildProfilePage(
        onAddProfile: onAddProfile,
        onTrySample: onTrySample,
      );
    }
    return PageFrame(
      title: AppLocalizations.of(context)!.childProfileTitle,
      subtitle: AppLocalizations.of(context)!.childProfileS715,
      decoration: _ProfileHeaderScene(
        children: children,
        selectedChildId: child.id,
        onChildChanged: onChildChanged,
        onTrySample: onTrySample,
      ),
      child: _ChildProfileContent(
        child: child,
        assets: assets,
        onAddProfile: onAddProfile,
        onEditProfile: onEditProfile,
        onDeleteProfile: onDeleteProfile,
      ),
    );
  }
}

class _EmptyChildProfilePage extends StatelessWidget {
  const _EmptyChildProfilePage({
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
            const _EmptyProfileTitleBlock(),
            SizedBox(height: medium ? 26 : 34),
            Expanded(
              child: compact
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 620,
                            child: _EmptyHeroCard(
                              onAddProfile: onAddProfile,
                              onTrySample: onTrySample,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const SizedBox(
                            height: 620,
                            child: _EmptyPrivacyCard(),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: medium ? 16 : 21,
                          child: _EmptyHeroCard(
                            onAddProfile: onAddProfile,
                            onTrySample: onTrySample,
                          ),
                        ),
                        SizedBox(width: horizontalGap),
                        Expanded(
                          flex: medium ? 9 : 10,
                          child: const _EmptyPrivacyCard(),
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

class _EmptyProfileTitleBlock extends StatelessWidget {
  const _EmptyProfileTitleBlock();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
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
      SizedBox(height: 42),
      Text(
        AppLocalizations.of(context)!.childProfileTitle,
        style: TextStyle(
          color: Color(0xff28170f),
          fontSize: 46,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: -1.4,
        ),
      ),
      SizedBox(height: 24),
      Text(
        AppLocalizations.of(context)!.childProfileS715,
        style: TextStyle(
          color: Color(0xff8a8177),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}

class _EmptyHeroCard extends StatelessWidget {
  const _EmptyHeroCard({required this.onAddProfile, required this.onTrySample});

  final VoidCallback onAddProfile;
  final VoidCallback onTrySample;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, outerConstraints) {
      final medium = outerConstraints.maxWidth < 760;
      final compactHeight = outerConstraints.maxHeight < 690;
      return _EmptyDesignCard(
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
                  child: _DecorDot(size: 10, color: const Color(0xff9fc284)),
                ),
                Positioned(
                  left: 62,
                  top: 72,
                  child: _Sparkle(size: 22, color: const Color(0xfff4d487)),
                ),
                Positioned(
                  left: 6,
                  bottom: 198,
                  child: _DecorDot(size: 20, color: const Color(0xffeef2dc)),
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
                                        _MemoryBookIllustration(
                                          size: medium ? 220 : 280,
                                        ),
                                        const SizedBox(height: 22),
                                        _EmptyHeroCopy(
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
                                            child: _MemoryBookIllustration(
                                              size: medium ? 240 : 360,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: medium ? 18 : 28),
                                        Expanded(
                                          flex: medium ? 10 : 9,
                                          child: _EmptyHeroCopy(
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
                              const _EmptyFeatureStrip(),
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
                                        _MemoryBookIllustration(
                                          size: medium ? 220 : 280,
                                        ),
                                        const SizedBox(height: 22),
                                        _EmptyHeroCopy(
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
                                            child: _MemoryBookIllustration(
                                              size: medium ? 240 : 360,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: medium ? 18 : 28),
                                        Expanded(
                                          flex: medium ? 10 : 9,
                                          child: _EmptyHeroCopy(
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
                            const _EmptyFeatureStrip(),
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

class _EmptyHeroCopy extends StatelessWidget {
  const _EmptyHeroCopy({required this.onAddProfile, required this.onTrySample});

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
            '先添加孩子，再开始记录素材、成长时间轴\n和作品集，珍藏每一个值得记住的瞬间。',
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _WhiteCircleIcon(icon: Icons.add_rounded),
                        SizedBox(width: 10),
                        Flexible(child: Text(AppLocalizations.of(context)!.childProfileS693)),
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppAssetIcon(gridIconAsset, size: 20),
                        SizedBox(width: 10),
                        Flexible(child: Text(AppLocalizations.of(context)!.childProfileS625)),
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

class _EmptyFeatureStrip extends StatelessWidget {
  const _EmptyFeatureStrip();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 680) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 16,
          children: [
            _FeaturePill(
              iconAsset: imageIconAsset,
              title: AppLocalizations.of(context)!.childProfileS842,
              text: AppLocalizations.of(context)!.childProfileS706,
            ),
            _FeaturePill(
              iconAsset: timelineIconAsset,
              title: AppLocalizations.of(context)!.childProfileS495,
              text: AppLocalizations.of(context)!.childProfileS925,
            ),
            _FeaturePill(
              iconAsset: starIconAsset,
              title: AppLocalizations.of(context)!.childProfileS231,
              text: AppLocalizations.of(context)!.childProfileS714,
            ),
          ],
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FeaturePill(
            iconAsset: imageIconAsset,
            title: AppLocalizations.of(context)!.childProfileS842,
            text: AppLocalizations.of(context)!.childProfileS706,
          ),
          _FeatureDivider(),
          _FeaturePill(
            iconAsset: timelineIconAsset,
            title: AppLocalizations.of(context)!.childProfileS495,
            text: AppLocalizations.of(context)!.childProfileS925,
          ),
          _FeatureDivider(),
          _FeaturePill(iconAsset: starIconAsset, title: AppLocalizations.of(context)!.childProfileS231, text: AppLocalizations.of(context)!.childProfileS714),
        ],
      );
    },
  );
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.iconAsset,
    required this.title,
    required this.text,
  });

  final String iconAsset;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xfffffbef),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xffeee5d7)),
        ),
        child: AppAssetIcon(iconAsset, size: 31),
      ),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff423329),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xff9a9188),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ],
  );
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 52,
    margin: const EdgeInsets.symmetric(horizontal: 28),
    color: const Color(0xffe7dfd4),
  );
}

class _EmptyPrivacyCard extends StatelessWidget {
  const _EmptyPrivacyCard();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 780;
      return _EmptyDesignCard(
        padding: compact
            ? const EdgeInsets.fromLTRB(34, 30, 34, 28)
            : const EdgeInsets.fromLTRB(44, 48, 44, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: _ShieldHomeIllustration(
                width: compact ? 228 : 288,
                height: compact ? 132 : 184,
              ),
            ),
            SizedBox(height: compact ? 18 : 28),
            Text(
              AppLocalizations.of(context)!.childProfileS224,
              style: TextStyle(
                color: Color(0xff28170f),
                fontSize: 27,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -0.6,
              ),
            ),
            SizedBox(height: compact ? 12 : 16),
            Text(
              AppLocalizations.of(context)!.childProfileS499,
              style: TextStyle(
                color: Color(0xff756a60),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            SizedBox(height: compact ? 18 : 24),
            _PrivacyRow(
              iconAsset: lockIconAsset,
              title: AppLocalizations.of(context)!.childProfileS602,
              text: AppLocalizations.of(context)!.childProfileS500,
              compact: true,
            ),
            SizedBox(height: compact ? 12 : 16),
            _PrivacyRow(
              iconAsset: leafIconAsset,
              title: AppLocalizations.of(context)!.childProfileS785,
              text: AppLocalizations.of(context)!.childProfileS556,
              compact: true,
            ),
            SizedBox(height: compact ? 12 : 16),
            _PrivacyRow(
              iconAsset: childIconAsset,
              title: AppLocalizations.of(context)!.childProfileS223,
              text: AppLocalizations.of(context)!.childProfileS342,
              compact: true,
            ),
            SizedBox(height: compact ? 16 : 20),
            const _DataOwnershipBanner(compact: true),
          ],
        ),
      );
    },
  );
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({
    required this.iconAsset,
    required this.title,
    required this.text,
    this.compact = false,
  });

  final String iconAsset;
  final String title;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: compact ? 56 : 64,
        height: compact ? 56 : 64,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xfff2f4e8),
          shape: BoxShape.circle,
        ),
        child: AppAssetIcon(iconAsset, size: compact ? 28 : 32),
      ),
      SizedBox(width: compact ? 16 : 20),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff2f2118),
                fontSize: 17,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xff8c8178),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _DataOwnershipBanner extends StatelessWidget {
  const _DataOwnershipBanner({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    height: compact ? 56 : 68,
    padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 22),
    decoration: BoxDecoration(
      color: const Color(0xfffbfcf0),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xffe5e8cc), width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0a91845f),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: const Row(
      children: [
        AppAssetIcon(shieldIconAsset, size: 28),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.childProfileS238,
            style: TextStyle(
              color: Color(0xff58a05a),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyDesignCard extends StatelessWidget {
  const _EmptyDesignCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: const Color(0xfffffefd).withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: const Color(0xffeadfce), width: 1.1),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0f9b7a51),
          blurRadius: 28,
          offset: Offset(0, 14),
        ),
      ],
    ),
    child: child,
  );
}

class _MemoryBookIllustration extends StatelessWidget {
  const _MemoryBookIllustration({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _MemoryBookPainter()),
  );
}

class _MemoryBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..isAntiAlias = true;
    final shadow = Paint()
      ..color = const Color(0x1685703c)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.save();
    canvas.translate(w * 0.04, h * 0.02);
    canvas.rotate(-0.07);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.43, h * 0.9),
        width: w * 0.86,
        height: h * 0.14,
      ),
      paint..color = const Color(0xffedf1dc),
    );
    final cover = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.18, w * 0.72, h * 0.68),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(cover.shift(Offset(w * 0.02, h * 0.03)), shadow);
    canvas.drawRRect(cover, paint..color = const Color(0xfffff1d0));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.2, w * 0.06, h * 0.64),
        Radius.circular(w * 0.025),
      ),
      paint..color = const Color(0xffbdd0a0),
    );
    final page = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.25, w * 0.55, h * 0.5),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(page, paint..color = const Color(0xfffff7e6));
    final dashPaint = Paint()
      ..color = const Color(0xffe8c989)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    _drawDashedRRect(canvas, page.deflate(w * 0.028), dashPaint);
    canvas.drawCircle(
      Offset(w * 0.45, h * 0.48),
      w * 0.17,
      paint..color = const Color(0xfff6ead4),
    );
    _paintChildFace(canvas, Offset(w * 0.45, h * 0.49), w * 0.26);
    _paintLeaves(canvas, Offset(w * 0.75, h * 0.75), w * 0.23);
    canvas.restore();
  }

  void _paintChildFace(Canvas canvas, Offset center, double size) {
    final paint = Paint()..isAntiAlias = true;
    canvas.drawCircle(
      center,
      size * 0.34,
      paint..color = const Color(0xffffd69b),
    );
    canvas.drawCircle(
      center + Offset(-size * 0.34, size * 0.02),
      size * 0.09,
      paint..color = const Color(0xffffd69b),
    );
    canvas.drawCircle(
      center + Offset(size * 0.34, size * 0.02),
      size * 0.09,
      paint..color = const Color(0xffffd69b),
    );
    final hair = Paint()
      ..color = const Color(0xff6f4922)
      ..style = PaintingStyle.fill;
    final hairPath = Path()
      ..moveTo(center.dx - size * 0.32, center.dy - size * 0.15)
      ..quadraticBezierTo(
        center.dx - size * 0.1,
        center.dy - size * 0.48,
        center.dx + size * 0.26,
        center.dy - size * 0.2,
      )
      ..quadraticBezierTo(
        center.dx + size * 0.06,
        center.dy - size * 0.3,
        center.dx - size * 0.04,
        center.dy - size * 0.08,
      )
      ..quadraticBezierTo(
        center.dx - size * 0.14,
        center.dy - size * 0.27,
        center.dx - size * 0.32,
        center.dy - size * 0.15,
      );
    canvas.drawPath(hairPath, hair);
    canvas.drawCircle(
      center + Offset(-size * 0.12, 0),
      size * 0.025,
      paint..color = const Color(0xff352016),
    );
    canvas.drawCircle(
      center + Offset(size * 0.12, 0),
      size * 0.025,
      paint..color = const Color(0xff352016),
    );
    canvas.drawCircle(
      center + Offset(-size * 0.2, size * 0.08),
      size * 0.055,
      paint..color = const Color(0xffffa57b),
    );
    canvas.drawCircle(
      center + Offset(size * 0.2, size * 0.08),
      size * 0.055,
      paint..color = const Color(0xffffa57b),
    );
    final smile = Paint()
      ..color = const Color(0xff6f4922)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: center + Offset(0, size * 0.08),
        width: size * 0.22,
        height: size * 0.16,
      ),
      0.12,
      math.pi - 0.24,
      false,
      smile,
    );
    final shirt = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center + Offset(0, size * 0.42),
        width: size * 0.5,
        height: size * 0.2,
      ),
      Radius.circular(size * 0.06),
    );
    canvas.drawRRect(shirt, paint..color = const Color(0xffedf1dc));
    canvas.drawLine(
      Offset(center.dx - size * 0.2, center.dy + size * 0.39),
      Offset(center.dx + size * 0.2, center.dy + size * 0.39),
      Paint()
        ..color = const Color(0xff89a773)
        ..strokeWidth = size * 0.026
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintLeaves(Canvas canvas, Offset root, double size) {
    final stem = Paint()
      ..color = const Color(0xff6c9d5a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(root, root + Offset(size * 0.48, -size * 0.64), stem);
    final leafPaint = Paint()..color = const Color(0xffa5c98c);
    for (final item in [
      (0.12, -0.16, -0.7),
      (0.28, -0.35, 0.8),
      (0.42, -0.52, -0.8),
      (0.52, -0.72, 0.7),
    ]) {
      canvas.save();
      canvas.translate(root.dx + size * item.$1, root.dy + size * item.$2);
      canvas.rotate(item.$3);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size * 0.22,
          height: size * 0.42,
        ),
        leafPaint,
      );
      canvas.restore();
    }
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + 12);
        canvas.drawPath(extract, paint);
        distance += 24;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShieldHomeIllustration extends StatelessWidget {
  const _ShieldHomeIllustration({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: CustomPaint(painter: _ShieldHomePainter()),
  );
}

class _ShieldHomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..isAntiAlias = true;
    canvas.drawArc(
      Rect.fromLTWH(w * 0.12, h * 0.66, w * 0.76, h * 0.28),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xffd9e6c8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    for (final point in [
      Offset(w * 0.2, h * 0.28),
      Offset(w * 0.1, h * 0.45),
      Offset(w * 0.87, h * 0.43),
      Offset(w * 0.83, h * 0.27),
    ]) {
      canvas.drawCircle(point, 4.5, paint..color = const Color(0xffdce6c0));
    }
    _paintPlant(canvas, Offset(w * 0.22, h * 0.72), -1);
    _paintPlant(canvas, Offset(w * 0.78, h * 0.72), 1);
    final shield = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.76, h * 0.24)
      ..quadraticBezierTo(w * 0.76, h * 0.63, w * 0.5, h * 0.78)
      ..quadraticBezierTo(w * 0.24, h * 0.63, w * 0.24, h * 0.24)
      ..close();
    canvas.drawPath(
      shield.shift(Offset(0, 5)),
      Paint()
        ..color = const Color(0x1f4c7f42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(shield, paint..color = const Color(0xff6eaa6d));
    canvas.drawPath(
      shield,
      Paint()
        ..color = const Color(0xffd9ead1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    final house = Path()
      ..moveTo(w * 0.36, h * 0.44)
      ..lineTo(w * 0.5, h * 0.29)
      ..lineTo(w * 0.64, h * 0.44)
      ..lineTo(w * 0.6, h * 0.44)
      ..lineTo(w * 0.6, h * 0.6)
      ..lineTo(w * 0.4, h * 0.6)
      ..lineTo(w * 0.4, h * 0.44)
      ..close();
    canvas.drawPath(house, paint..color = Colors.white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.48, h * 0.5, w * 0.04, h * 0.07),
        const Radius.circular(2),
      ),
      paint..color = const Color(0xff6eaa6d),
    );
  }

  void _paintPlant(Canvas canvas, Offset root, int direction) {
    final stem = Paint()
      ..color = const Color(0xffa7c98f)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final leaf = Paint()..color = const Color(0xffc3d9a6);
    for (var i = 0; i < 3; i++) {
      final end = root + Offset(direction * (16.0 + i * 8), -18.0 - i * 18);
      canvas.drawLine(root, end, stem);
      canvas.save();
      canvas.translate(end.dx, end.dy);
      canvas.rotate(direction * (0.8 + i * 0.15));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 18, height: 40),
        leaf,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WhiteCircleIcon extends StatelessWidget {
  const _WhiteCircleIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: Color(0xff43a955), size: 22),
  );
}

class _DecorDot extends StatelessWidget {
  const _DecorDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _SparklePainter(color)),
  );
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.38,
        size.width,
        size.height / 2,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.62,
        size.width / 2,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.62,
        0,
        size.height / 2,
      )
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.38,
        size.width / 2,
        0,
      );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ChildProfileContent extends StatelessWidget {
  const _ChildProfileContent({
    required this.child,
    required this.assets,
    required this.onAddProfile,
    required this.onEditProfile,
    required this.onDeleteProfile,
  });

  final ChildVm child;
  final List<AssetVm> assets;
  final VoidCallback onAddProfile;
  final ValueChanged<ChildVm> onEditProfile;
  final ValueChanged<ChildVm> onDeleteProfile;

  static const double _actionButtonWidth = 86;
  static const double _actionButtonHeight = 34;

  @override
  Widget build(BuildContext context) {
    final childName = child.name;
    final artworkCount = assets
        .where((asset) => asset.type == 'artwork')
        .length;
    final photoCount = assets.where((asset) => asset.type == 'photo').length;
    final craftCount = assets.where((asset) => asset.type == 'craft').length;
    final profileImage = _profileImageAsset(assets);
    Widget buildActionButtons(double maxWidth) => ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.end,
        children: [
          SizedBox(
            width: _actionButtonWidth,
            height: _actionButtonHeight,
            child: SecondaryButton(
              label: AppLocalizations.of(context)!.childProfileS554,
              icon: Icons.add_rounded,
              iconAsset: addIconAsset,
              fullWidth: true,
              height: _actionButtonHeight,
              fontSize: 13,
              iconSize: 15,
              onPressed: onAddProfile,
            ),
          ),
          SizedBox(
            width: _actionButtonWidth,
            height: _actionButtonHeight,
            child: SecondaryButton(
              label: AppLocalizations.of(context)!.childProfileS834,
              icon: Icons.edit_rounded,
              iconAsset: editIconAsset,
              fullWidth: true,
              height: _actionButtonHeight,
              fontSize: 13,
              iconSize: 15,
              onPressed: () => onEditProfile(child),
            ),
          ),
          SizedBox(
            width: _actionButtonWidth,
            height: _actionButtonHeight,
            child: _DeleteChildButton(
              compact: true,
              onPressed: () => onDeleteProfile(child),
            ),
          ),
        ],
      ),
    );

    final content = Row(
      children: [
        Expanded(
          child: Column(
            children: [
              SurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: buildActionButtons(_actionButtonWidth * 3 + 20),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ChildPortrait(
                          childName: childName,
                          imagePath: profileImage?.previewPath ?? '',
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                childName,
                                style: const TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('已关联素材：${assets.length} 项'),
                              const SizedBox(height: 18),
                              Text(
                                assets.isEmpty
                                    ? AppLocalizations.of(context)!.childProfileS401
                                    : AppLocalizations.of(context)!.childProfileS486,
                                style: TextStyle(color: Colors.brown.shade600),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  Chip(label: Text('素材 ${assets.length}')),
                                  Chip(label: Text('绘画 $artworkCount')),
                                  Chip(label: Text('照片 $photoCount')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _GrowthStatsPanel(
                        assetCount: assets.length,
                        artworkCount: artworkCount,
                        photoCount: photoCount,
                        craftCount: craftCount,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _DistributionPanel(
                        artworkCount: artworkCount,
                        photoCount: photoCount,
                        craftCount: craftCount,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _RecentAssetsPanel(assets: assets)),
                    const SizedBox(width: 18),
                    const Expanded(child: _CollectionRecordsPanel()),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 340,
          child: _ProfileAsidePanel(child: child, assets: assets),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight >= 660) return content;
        return SingleChildScrollView(
          child: SizedBox(height: 660, child: content),
        );
      },
    );
  }
}

class _ChildPortrait extends StatelessWidget {
  const _ChildPortrait({required this.childName, required this.imagePath});

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

class _DeleteChildButton extends StatelessWidget {
  const _DeleteChildButton({required this.onPressed, this.compact = false});

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
        const Flexible(child: Text('删除', overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}

class _ProfileHeaderScene extends StatelessWidget {
  const _ProfileHeaderScene({
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

AssetVm? _profileImageAsset(List<AssetVm> assets) {
  bool looksLikeChildPortrait(AssetVm asset) {
    final text = '${asset.title} ${asset.description} ${asset.tags.join(' ')}';
    return text.contains(AppLocalizations.of(context)!.childProfileS757) ||
        text.contains(AppLocalizations.of(context)!.childProfileS366) ||
        text.contains(AppLocalizations.of(context)!.assetLibraryChildLabel) ||
        text.contains(AppLocalizations.of(context)!.childProfileS425) ||
        text.contains('笑') ||
        text.toLowerCase().contains('child');
  }

  for (final asset in assets) {
    if (asset.type == 'photo' &&
        asset.previewPath.trim().isNotEmpty &&
        looksLikeChildPortrait(asset)) {
      return asset;
    }
  }
  for (final asset in assets) {
    if (asset.type == 'photo' && asset.previewPath.trim().isNotEmpty) {
      return asset;
    }
  }
  for (final asset in assets) {
    if (asset.previewPath.trim().isNotEmpty) return asset;
  }
  return null;
}

class _GrowthStatsPanel extends StatelessWidget {
  const _GrowthStatsPanel({
    required this.assetCount,
    required this.artworkCount,
    required this.photoCount,
    required this.craftCount,
  });

  final int assetCount;
  final int artworkCount;
  final int photoCount;
  final int craftCount;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(iconAsset: gridIconAsset, title: '成长统计'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricTile(label: AppLocalizations.of(context)!.contentMetricTotalLabel, value: '$assetCount'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(label: AppLocalizations.of(context)!.contentCategoryDrawingLabel, value: '$artworkCount'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(label: AppLocalizations.of(context)!.contentAssetTypePhotoLabel, value: '$photoCount'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(label: AppLocalizations.of(context)!.contentAssetTypeCraftLabel, value: '$craftCount'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _DistributionPanel extends StatelessWidget {
  const _DistributionPanel({
    required this.artworkCount,
    required this.photoCount,
    required this.craftCount,
  });

  final int artworkCount;
  final int photoCount;
  final int craftCount;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(iconAsset: paletteIconAsset, title: '素材分布'),
        const SizedBox(height: 18),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              _DistributionChart(
                artworkCount: artworkCount,
                photoCount: photoCount,
                craftCount: craftCount,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendRow(
                      iconAsset: paletteIconAsset,
                      label: AppLocalizations.of(context)!.contentCategoryDrawingLabel,
                      value: artworkCount,
                    ),
                    _LegendRow(
                      iconAsset: cameraIconAsset,
                      label: AppLocalizations.of(context)!.contentAssetTypePhotoLabel,
                      value: photoCount,
                    ),
                    _LegendRow(
                      iconAsset: bearDocumentIconAsset,
                      label: AppLocalizations.of(context)!.contentAssetTypeCraftLabel,
                      value: craftCount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DistributionChart extends StatelessWidget {
  const _DistributionChart({
    required this.artworkCount,
    required this.photoCount,
    required this.craftCount,
  });

  final int artworkCount;
  final int photoCount;
  final int craftCount;

  @override
  Widget build(BuildContext context) {
    final total = artworkCount + photoCount + craftCount;
    final values = [artworkCount, photoCount, craftCount];
    const colors = [Color(0xfff4be57), Color(0xff6e9ee3), Color(0xff70c19b)];
    return SizedBox(
      width: 116,
      height: 116,
      child: CustomPaint(
        painter: _PieChartPainter(values: values, colors: colors, total: total),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter({
    required this.values,
    required this.colors,
    required this.total,
  });

  final List<int> values;
  final List<Color> colors;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const strokeGap = 0.03;
    var start = -math.pi / 2;
    final safeTotal = total <= 0 ? 1 : total;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / safeTotal) * math.pi * 2;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, start, sweep - strokeGap, true, paint);
      start += sweep;
    }
    final holePaint = Paint()..color = const Color(0xfffcfbf9);
    canvas.drawCircle(center, radius * 0.4, holePaint);
    final borderPaint = Paint()
      ..color = const Color(0xffe5ddd2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.values != values;
  }
}

class _RecentAssetsPanel extends StatelessWidget {
  const _RecentAssetsPanel({required this.assets});

  final List<AssetVm> assets;

  @override
  Widget build(BuildContext context) {
    final recentAssets = assets.take(3).toList();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(iconAsset: imageIconAsset, title: '最近作品'),
          const SizedBox(height: 18),
          Expanded(
            child: recentAssets.isEmpty
                ? _EmptyPanelHint(
                    iconAsset: imageIconAsset,
                    text: AppLocalizations.of(context)!.childProfileS400,
                  )
                : Row(
                    children: [
                      for (
                        var index = 0;
                        index < recentAssets.length;
                        index++
                      ) ...[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == recentAssets.length - 1 ? 0 : 8,
                            ),
                            child: AssetArtworkPreview(
                              path: recentAssets[index].previewPath,
                              fallbackIcon: recentAssets[index].icon,
                              fallbackAssetPath: _assetIconAsset(
                                recentAssets[index].type,
                              ),
                              label: recentAssets[index].title,
                              height: 120,
                              onTap: () => showAssetArtworkPreviewDialog(
                                context: context,
                                label: recentAssets[index].title,
                                path: recentAssets[index].previewPath,
                                fallbackIcon: recentAssets[index].icon,
                                fallbackAssetPath: _assetIconAsset(
                                  recentAssets[index].type,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CollectionRecordsPanel extends StatelessWidget {
  const _CollectionRecordsPanel();

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(iconAsset: bookIconAsset, title: AppLocalizations.of(context)!.contentPortfolioRecordTitle),
        SizedBox(height: 18),
        Expanded(
          child: _EmptyPanelHint(
            iconAsset: bookIconAsset,
            text: AppLocalizations.of(context)!.childProfileS733,
          ),
        ),
      ],
    ),
  );
}

// ignore: unused_element
class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline({required this.assets});

  final List<AssetVm> assets;

  @override
  Widget build(BuildContext context) {
    final timelineItems = assets.isEmpty
        ? const [
            _TimelineItem(AppLocalizations.of(context)!.childProfileS287, AppLocalizations.of(context)!.childProfileS222, childIconAsset),
            _TimelineItem(AppLocalizations.of(context)!.childProfileS399, AppLocalizations.of(context)!.childProfileS487, imageIconAsset),
            _TimelineItem(AppLocalizations.of(context)!.childProfileS720, AppLocalizations.of(context)!.childProfileS487, bookIconAsset),
          ]
        : assets
              .take(5)
              .map(
                (asset) => _TimelineItem(
                  asset.title,
                  asset.capturedAt.isEmpty ? AppLocalizations.of(context)!.contentDateMissingLabel : asset.capturedAt,
                  _assetIconAsset(asset.type),
                ),
              )
              .toList();

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(iconAsset: timelineIconAsset, title: '成长时间轴'),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var index = 0; index < timelineItems.length; index++) ...[
                Expanded(child: _TimelineNode(item: timelineItems[index])),
                if (index != timelineItems.length - 1)
                  Container(
                    width: 34,
                    height: 2,
                    color: const Color(0xffd7e8d9),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAsidePanel extends StatelessWidget {
  const _ProfileAsidePanel({required this.child, required this.assets});

  final ChildVm child;
  final List<AssetVm> assets;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final showRail = constraints.maxHeight >= 760;
      return Column(
        children: [
          Expanded(
            child: SurfaceCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      iconAsset: infoIconAsset,
                      title: AppLocalizations.of(context)!.childProfileS633,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      iconAsset: childIconAsset,
                      label: AppLocalizations.of(context)!.childProfileS367,
                      value: child.name,
                    ),
                    _InfoRow(
                      iconAsset: gridIconAsset,
                      label: AppLocalizations.of(context)!.contentMetricTotalLabel,
                      value: '${assets.length} 项',
                    ),
                    _InfoRow(
                      iconAsset: imageIconAsset,
                      label: AppLocalizations.of(context)!.childProfileS574,
                      value: assets.isEmpty ? AppLocalizations.of(context)!.childProfileS566 : assets.first.title,
                    ),
                    const Divider(height: 24),
                    _SectionHeader(
                      iconAsset: bearHeadIconAsset,
                      title: AppLocalizations.of(context)!.childProfileS497,
                    ),
                    const SizedBox(height: 12),
                    _MilestoneRow(
                      text: assets.isEmpty ? AppLocalizations.of(context)!.childProfileS799 : AppLocalizations.of(context)!.childProfileS446,
                    ),
                    const _MilestoneRow(text: '时间线按素材日期自动更新'),
                    const _MilestoneRow(text: '作品集记录保存在本地'),
                  ],
                ),
              ),
            ),
          ),
          if (showRail) ...[
            const SizedBox(height: 18),
            Expanded(
              flex: 2,
              child: _ProfileArtworkRail(
                title: AppLocalizations.of(context)!.childProfileS670,
                text: AppLocalizations.of(context)!.childProfileS832,
                compact: true,
              ),
            ),
          ],
        ],
      );
    },
  );
}

class _ProfileArtworkRail extends StatelessWidget {
  const _ProfileArtworkRail({
    required this.title,
    required this.text,
    this.compact = false,
  });

  final String title;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: compact ? 94 : 112,
          height: compact ? 94 : 112,
          decoration: BoxDecoration(
            color: const Color(0xfff7f3ec),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xffeadbc9)),
          ),
          child: AppAssetIcon(userShieldIconAsset, size: compact ? 50 : 58),
        ),
        SizedBox(height: compact ? 12 : 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 15 : 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xff77685e), height: 1.5),
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.iconAsset, required this.title});

  final String iconAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    final accent = _softAccent(iconAsset);
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(label, style: const TextStyle(color: Color(0xff8c7663))),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  final String iconAsset;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        _LegendDot(color: _softAccent(iconAsset)),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _EmptyPanelHint extends StatelessWidget {
  const _EmptyPanelHint({required this.iconAsset, required this.text});

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    final accent = _softAccent(iconAsset);
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 3,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xff77685e)),
            ),
          ],
        ),
      ),
    );
  }
}

Color _softAccent(String key) {
  if (key.contains('camera') || key.contains(AppLocalizations.of(context)!.contentAssetTypePhotoLabel)) {
    return const Color(0xff5d9be8);
  }
  if (key.contains('palette') || key.contains(AppLocalizations.of(context)!.childProfileS872)) {
    return const Color(0xffffbd54);
  }
  if (key.contains('book') || key.contains(AppLocalizations.of(context)!.childProfileS217)) {
    return const Color(0xff6f9af8);
  }
  return const Color(0xff2faa61);
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.item});

  final _TimelineItem item;

  @override
  Widget build(BuildContext context) {
    final accent = _softAccent(item.iconAsset);
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.38)),
          ),
          child: Text(
            item.title.isEmpty ? '•' : item.title.substring(0, 1),
            style: TextStyle(color: accent, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item.date,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xff77685e), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _TimelineItem {
  const _TimelineItem(this.title, this.date, this.iconAsset);

  final String title;
  final String date;
  final String iconAsset;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  final String iconAsset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Center(
              child: AppAssetIcon(
                iconAsset,
                fallbackIcon: Icons.brightness_1_rounded,
                size: 18,
                opacity: 0.92,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xff7d7065),
                fontSize: 16,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Center(
            child: AppAssetIcon(
              completeIconAsset,
              fallbackIcon: Icons.check_circle_rounded,
              size: 18,
              opacity: 0.96,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 16, height: 1.0)),
        ),
      ],
    ),
  );
}

String _assetIconAsset(String type) {
  return switch (type) {
    'photo' => cameraIconAsset,
    'craft' => bearDocumentIconAsset,
    _ => paletteIconAsset,
  };
}
