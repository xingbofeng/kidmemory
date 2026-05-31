import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/widgets/chrome.dart';

class ShieldHomeIllustration extends StatelessWidget {
  const ShieldHomeIllustration({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 6,
          child: Container(
            width: width * 0.72,
            height: height * 0.2,
            decoration: BoxDecoration(
              color: const Color(0xffe8efd8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        Container(
          width: width * 0.72,
          height: height * 0.72,
          decoration: BoxDecoration(
            color: const Color(0xfffff7e8),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xffead7bd), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1685703c),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
        ),
        Positioned(
          top: height * 0.18,
          child: AppAssetIcon(shieldIconAsset, size: height * 0.42),
        ),
        Positioned(
          right: width * 0.18,
          bottom: height * 0.18,
          child: AppAssetIcon(leafIconAsset, size: height * 0.2),
        ),
      ],
    ),
  );
}

class EmptyDesignCard extends StatelessWidget {
  const EmptyDesignCard({
    super.key,
    required this.child,
    required this.padding,
  });

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

class MemoryBookIllustration extends StatelessWidget {
  const MemoryBookIllustration({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: MemoryBookPainter()),
  );
}

class MemoryBookPainter extends CustomPainter {
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

class WhiteCircleIcon extends StatelessWidget {
  const WhiteCircleIcon({super.key, required this.icon});

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

class DecorDot extends StatelessWidget {
  const DecorDot({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class Sparkle extends StatelessWidget {
  const Sparkle({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: SparklePainter(color)),
  );
}

class SparklePainter extends CustomPainter {
  const SparklePainter(this.color);

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
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
