import 'package:flutter/material.dart';

import 'chrome.dart';

class PageFrame extends StatelessWidget {
  const PageFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    this.status,
    this.decoration,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? status;
  final Widget? decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(title),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff2e1d14),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff6f6258),
                      ),
                    ),
                  ],
                ),
              ),
              ?status,
              ?decoration,
            ],
          ),
          const SizedBox(height: 22),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor = const Color(0xffeadbc9),
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f6a4a24),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAsset,
    this.height = 58,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? iconAsset;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xff28a65a),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            textStyle: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: _ButtonLabel(label: label, icon: icon, iconAsset: iconAsset),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAsset,
    this.fullWidth = false,
    this.height,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? iconAsset;
  final bool fullWidth;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff247348),
        side: const BorderSide(color: Color(0xffb6dec0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      child: _ButtonLabel(label: label, icon: icon, iconAsset: iconAsset),
    );
    final wrappedButton = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: button,
    );
    if (!fullWidth && height == null) return wrappedButton;
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: wrappedButton,
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.label, this.icon, this.iconAsset});

  final String label;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      if ((iconAsset?.trim().isNotEmpty ?? false) || icon != null) ...[
        AppAssetIcon(iconAsset, fallbackIcon: icon, size: buttonIconSize),
        const SizedBox(width: 8),
      ],
      Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
    ],
  );
}
