import 'package:flutter/material.dart';

import 'chrome.dart';

class PageFrame extends StatelessWidget {
  const PageFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    this.status,
    this.decoration,
    this.leading,
    this.framePadding = const EdgeInsets.fromLTRB(24, 18, 24, 22),
    this.contentTopSpacing = 22,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? status;
  final Widget? decoration;
  final Widget? leading;
  final EdgeInsets framePadding;
  final double contentTopSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(title),
      padding: framePadding,
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            constraints.maxWidth < 780
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TitleBlock(
                        title: title,
                        subtitle: subtitle,
                        leading: leading,
                      ),
                      if (status != null || decoration != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [?status, ?decoration],
                        ),
                      ],
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _TitleBlock(
                          title: title,
                          subtitle: subtitle,
                          leading: leading,
                        ),
                      ),
                      ?status,
                      ?decoration,
                    ],
                  ),
            SizedBox(height: contentTopSpacing),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    required this.title,
    required this.subtitle,
    this.leading,
  });

  final String title;
  final String subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final titleContent = Column(
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
          style: const TextStyle(fontSize: 14, color: Color(0xff6f6258)),
        ),
      ],
    );
    if (leading == null) return titleContent;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading!,
        const SizedBox(width: 14),
        Expanded(child: titleContent),
      ],
    );
  }
}

class PageBackButton extends StatelessWidget {
  const PageBackButton({
    required this.tooltip,
    required this.onPressed,
    this.iconAsset = leftArrowIconAsset,
    this.fallbackIcon = Icons.arrow_back_rounded,
    super.key,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final String iconAsset;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xfffffcf6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffeadbc9)),
        ),
        child: AppAssetIcon(iconAsset, fallbackIcon: fallbackIcon, size: 24),
      ),
    ),
  );
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
        color: backgroundColor ?? const Color(0xfffcfbf9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0a000000),
            blurRadius: 10,
            offset: Offset(0, 3),
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
    this.backgroundColor = const Color(0xff28a65a),
    this.foregroundColor = Colors.white,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.fontSize = 19,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? iconAsset;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double fontSize;

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
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledForegroundColor: disabledForegroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ).copyWith(fontSize: fontSize),
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
    this.fontSize = 17,
    this.iconSize = buttonIconSize,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? iconAsset;
  final bool fullWidth;
  final double? height;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff247348),
        side: const BorderSide(color: Color(0xffc8ddcc)),
        minimumSize: Size.zero,
        padding: EdgeInsets.symmetric(horizontal: fontSize <= 14 ? 6 : 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800),
      ),
      child: _ButtonLabel(
        label: label,
        icon: icon,
        iconAsset: iconAsset,
        iconSize: iconSize,
      ),
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
  const _ButtonLabel({
    required this.label,
    this.icon,
    this.iconAsset,
    this.iconSize = buttonIconSize,
  });

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      if ((iconAsset?.trim().isNotEmpty ?? false) || icon != null) ...[
        AppAssetIcon(iconAsset, fallbackIcon: icon, size: iconSize),
        const SizedBox(width: 8),
      ],
      Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
    ],
  );
}
