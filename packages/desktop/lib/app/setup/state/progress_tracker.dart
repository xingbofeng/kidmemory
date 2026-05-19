// ignore_for_file: unused_element

part of '../../desktop_shell.dart';

class _BrewPhaseTracker {
  _BrewPhaseTracker({
    required this.baseProgress,
    required this.maxProgress,
    required this.l10n,
    required this.onUpdate,
  });

  final double baseProgress;
  final double maxProgress;
  final AppLocalizations l10n;
  final void Function(double progress, String label) onUpdate;

  double _current = 0;

  void feed(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return;

    double target;
    String label;

    if (trimmed.startsWith('==> Fetching')) {
      target = baseProgress + (maxProgress - baseProgress) * 0.15;
      label = l10n.setupFetchingResources;
    } else if (trimmed.startsWith('==> Downloading')) {
      target = baseProgress + (maxProgress - baseProgress) * 0.3;
      label = l10n.setupDownloading;
    } else if (trimmed.startsWith('==> Installing') ||
        trimmed.contains('==> Installing')) {
      target = baseProgress + (maxProgress - baseProgress) * 0.6;
      label = l10n.setupInstallingSoftware;
    } else if (trimmed.startsWith('==> Pouring') ||
        trimmed.contains('==> Pouring')) {
      target = baseProgress + (maxProgress - baseProgress) * 0.85;
      label = l10n.setupConfiguring;
    } else if (trimmed.startsWith('🍺') ||
        trimmed.startsWith('==> Summary') ||
        trimmed.startsWith('==> Linking')) {
      target = maxProgress;
      label = l10n.setupInstallCompleted;
    } else if (trimmed.startsWith('Error:') ||
        trimmed.startsWith('==> Error')) {
      label = trimmed;
      target = _current;
    } else {
      target = (_current + 0.004).clamp(baseProgress, maxProgress);
      final short = trimmed.length > 64
          ? '${trimmed.substring(0, 61)}...'
          : trimmed;
      label = short;
    }

    _current = target;
    onUpdate(_current, label);
  }
}
