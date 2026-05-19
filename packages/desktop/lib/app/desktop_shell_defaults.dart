part of 'desktop_shell.dart';

List<Map<String, String>> _defaultSearchTypeOptions(BuildContext context) => [
  {'value': 'all', 'label': AppLocalizations.of(context)!.contentTypeFilterAllLabel},
  {'value': 'artwork', 'label': AppLocalizations.of(context)!.contentCategoryDrawingLabel},
  {'value': 'photo', 'label': AppLocalizations.of(context)!.contentAssetTypePhotoLabel},
  {'value': 'craft', 'label': AppLocalizations.of(context)!.contentAssetTypeCraftLabel},
];

const _defaultGenerationTemplates = ['温暖童趣', '童话式成长记忆', '简约纪实'];

List<String> _defaultGenerationPageSizes(BuildContext context) => [
  AppLocalizations.of(context)!.desktopShellDefaultsS101,
  AppLocalizations.of(context)!.desktopShellDefaultsS100,
  AppLocalizations.of(context)!.desktopShellDefaultsS99,
];

List<String> _defaultGenerationStyles(BuildContext context) => [
  AppLocalizations.of(context)!.desktopShellDefaultsS697,
  AppLocalizations.of(context)!.desktopShellDefaultsS787,
  AppLocalizations.of(context)!.desktopShellDefaultsS826,
];

List<String> _defaultGenerationExportTargets(BuildContext context) => [
  AppLocalizations.of(context)!.desktopShellDefaultsS129,
  AppLocalizations.of(context)!.desktopShellDefaultsS935,
  AppLocalizations.of(context)!.desktopShellDefaultsS932,
];
