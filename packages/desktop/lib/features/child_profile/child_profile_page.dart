import 'package:flutter/material.dart';

import 'widgets/child_profile_content.dart';
import 'widgets/child_profile_empty_state.dart';
import 'widgets/child_profile_header.dart';

import '../../shared/models/library_models.dart';
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
      return EmptyChildProfilePage(
        onAddProfile: onAddProfile,
        onTrySample: onTrySample,
      );
    }
    return PageFrame(
      title: AppLocalizations.of(context)!.childProfileTitle,
      subtitle: AppLocalizations.of(context)!.childProfileS715,
      decoration: ProfileHeaderScene(
        children: children,
        selectedChildId: child.id,
        onChildChanged: onChildChanged,
        onTrySample: onTrySample,
      ),
      child: ChildProfileContent(
        child: child,
        assets: assets,
        onAddProfile: onAddProfile,
        onEditProfile: onEditProfile,
        onDeleteProfile: onDeleteProfile,
      ),
    );
  }
}
