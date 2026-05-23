import 'package:flutter/material.dart';

import '../../shared/widgets/status.dart';
import '../../../l10n/app_localizations.dart';
import 'asset_library_models.dart';

void showAssetLibraryImportToast(BuildContext context, AssetImportReport report) {
    final imported = report.imported;
    final duplicates = report.duplicates;
    final failed = report.failed;
    final skipped = report.skipped;
    final message = report.message.isNotEmpty
        ? report.message
        : AppLocalizations.of(context)!.assetLibraryImportSummaryMessage(
            imported,
            duplicates,
            skipped,
            failed,
          );
    final title =
        (report.title.isNotEmpty ? report.title : null) ??
        (report.failed > 0
            ? (report.imported > 0
                  ? AppLocalizations.of(context)!.assetLibraryPageS403
                  : AppLocalizations.of(
                      context,
                    )!.sampleDatasetImportFailedTitle)
            : report.imported > 0
            ? AppLocalizations.of(context)!.assetLibraryPageS392
            : AppLocalizations.of(context)!.assetLibraryPageS581);
    final tone = report.failed > 0
        ? AppToastTone.error
        : report.imported > 0
        ? AppToastTone.success
        : AppToastTone.info;
    AppToast.show(context, title: title, message: message, tone: tone);
  }

  
