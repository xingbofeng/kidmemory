part of '../../desktop_shell.dart';

extension _DesktopShellImportSummary on _DesktopShellState {
  AssetImportReport _summarizeImport(
    ImportAssetsResultDto result, {
    int fallbackImportedCount = 0,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (!result.hasCounters && result.messageValue.isEmpty) {
      if (fallbackImportedCount > 0) {
        return AssetImportReport(
          title: AppLocalizations.of(context)!.assetLibraryPageS392,
          imported: fallbackImportedCount,
          duplicates: 0,
          failed: 0,
          skipped: 0,
          message: l10n.importSummaryFallbackImportedMessage(
            fallbackImportedCount,
          ),
        );
      }
      return AssetImportReport(
        title: AppLocalizations.of(context)!.importSummaryS402,
        imported: 0,
        duplicates: 0,
        failed: 0,
        skipped: 0,
        message: AppLocalizations.of(context)!.importSummaryS676,
      );
    }

    final message = result.messageValue.isNotEmpty
        ? result.messageValue
        : (result.failedReasons.isEmpty
              ? null
              : l10n.importSummaryCountersWithFailures(
                  result.importedCount,
                  result.duplicatesCount,
                  result.skippedCount,
                  result.failedCount,
                  result.failedReasons.join(
                    l10n.importSummaryFailedReasonSeparator,
                  ),
                ));
    return AssetImportReport(
      imported: result.importedCount,
      duplicates: result.duplicatesCount,
      failed: result.failedCount,
      skipped: result.skippedCount,
      message: message ?? '',
      title: result.titleValue,
    );
  }
}
