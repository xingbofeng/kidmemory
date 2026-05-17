import 'dart:async';

import 'package:flutter/material.dart';

import 'chrome.dart';
import 'layout.dart';

enum AppToastTone { success, info, warning, error }

class AppToast {
  const AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppToastTone tone = AppToastTone.info,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _AppToastOverlay(
        title: title,
        message: message,
        tone: tone,
        onDismissed: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    required this.title,
    required this.message,
    required this.tone,
    required this.onDismissed,
  });

  final String? title;
  final String message;
  final AppToastTone tone;
  final VoidCallback onDismissed;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _dismissTimer = Timer(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 22;
    final palette = _ToastPalette.forTone(widget.tone);
    return Positioned(
      top: top,
      left: 24,
      right: 24,
      child: IgnorePointer(
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(
            opacity: _opacity,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.background,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: palette.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: palette.accent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: AppAssetIcon(
                            palette.iconAsset,
                            fallbackIcon: palette.icon,
                            size: buttonIconSize,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.title != null) ...[
                                Text(
                                  widget.title!,
                                  style: TextStyle(
                                    color: palette.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                widget.message,
                                style: TextStyle(
                                  color: palette.text,
                                  fontSize: 14,
                                  fontWeight: widget.title == null
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  height: 1.35,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastPalette {
  const _ToastPalette({
    required this.background,
    required this.border,
    required this.accent,
    required this.text,
    required this.icon,
    required this.iconAsset,
  });

  final Color background;
  final Color border;
  final Color accent;
  final Color text;
  final IconData icon;
  final String iconAsset;

  static _ToastPalette forTone(AppToastTone tone) => switch (tone) {
    AppToastTone.success => const _ToastPalette(
      background: Color(0xfff0fbf2),
      border: Color(0xffbfe4c6),
      accent: Color(0xff2faa61),
      text: Color(0xff166534),
      icon: Icons.check_rounded,
      iconAsset: completeIconAsset,
    ),
    AppToastTone.warning => const _ToastPalette(
      background: Color(0xfffff6df),
      border: Color(0xffffd48a),
      accent: Color(0xffe88913),
      text: Color(0xff7a4a0b),
      icon: Icons.priority_high_rounded,
      iconAsset: infoIconAsset,
    ),
    AppToastTone.error => const _ToastPalette(
      background: Color(0xfffff1ed),
      border: Color(0xffffc1b2),
      accent: Color(0xffd94a32),
      text: Color(0xff842214),
      icon: Icons.close_rounded,
      iconAsset: stopIconAsset,
    ),
    AppToastTone.info => const _ToastPalette(
      background: Color(0xfffffbf5),
      border: Color(0xffeadbc9),
      accent: Color(0xff2f8f5b),
      text: Color(0xff3f332b),
      icon: Icons.info_outline_rounded,
      iconAsset: infoIconAsset,
    ),
  };
}

class ReadyStatus extends StatelessWidget {
  const ReadyStatus({super.key});

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        CircleAvatar(
          backgroundColor: Color(0xff2faa61),
          child: AppAssetIcon(completeIconAsset, size: 24),
        ),
        SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '环境已就绪',
              style: TextStyle(
                color: Color(0xff168542),
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '检测结果来自 sidecar',
              style: TextStyle(fontSize: 12, color: Color(0xff77685e)),
            ),
          ],
        ),
      ],
    ),
  );
}

class ReadinessStatus extends StatelessWidget {
  const ReadinessStatus({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final disconnected = message.startsWith('Sidecar 未连接');
    final ready = _readinessComplete(message);
    final accent = disconnected
        ? const Color(0xffd68622)
        : (ready ? const Color(0xff2faa61) : const Color(0xffffbd54));
    final title = disconnected ? '本地服务准备中' : (ready ? '环境已就绪' : '检测中');
    final detail = disconnected ? '正在连接 KidMemory 本地服务' : message;
    final icon = disconnected
        ? linkIconAsset
        : (ready ? completeIconAsset : refreshIconAsset);
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: accent,
            child: AppAssetIcon(icon, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: disconnected
                      ? const Color(0xff9c5d12)
                      : (ready
                            ? const Color(0xff168542)
                            : const Color(0xffa96d12)),
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(fontSize: 12, color: Color(0xff77685e)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _readinessComplete(String value) {
    final match = RegExp(r'^已完成\s+(\d+)\s*/\s*(\d+)').firstMatch(value);
    if (match == null) return false;
    final done = int.tryParse(match.group(1) ?? '');
    final total = int.tryParse(match.group(2) ?? '');
    return done != null && total != null && total > 0 && done >= total;
  }
}

class SuccessBanner extends StatelessWidget {
  const SuccessBanner({required this.title, required this.text, super.key});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xfff0fbf2),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xffbfe4c6)),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xff2faa61),
          child: AppAssetIcon(completeIconAsset, size: 24),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  color: Color(0xff20954d),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(text),
            ],
          ),
        ),
      ],
    ),
  );
}
