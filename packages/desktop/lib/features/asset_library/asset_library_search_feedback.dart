import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

String assetLibraryMissingSemanticSearchMessage(BuildContext context) {
  return AppLocalizations.of(context)!.assetLibraryPageS483;
}

String assetLibraryMissingChildMessage(BuildContext context) {
  return AppLocalizations.of(context)!.assetLibraryPageS858;
}

String assetLibraryEmptyQueryMessage(BuildContext context) {
  return AppLocalizations.of(context)!.assetLibraryPageS867;
}

String assetLibrarySemanticSearchingMessage(BuildContext context) {
  return AppLocalizations.of(context)!.assetLibraryPageS665;
}

String assetLibraryClearedSearchMessage(BuildContext context) {
  return AppLocalizations.of(context)!.assetLibraryPageS440;
}

String assetLibrarySearchFailedMessage(BuildContext context, Object error) {
  return AppLocalizations.of(context)!.assetLibrarySearchFailedStatus(error);
}

String assetLibraryIndexingRefreshFailedMessage(BuildContext context) {
  return AppLocalizations.of(context)!.assetLibraryPageS825;
}
