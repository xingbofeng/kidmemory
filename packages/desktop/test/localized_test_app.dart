import 'package:flutter/material.dart';
import 'package:kidmemory_desktop/l10n/app_localizations.dart';

MaterialApp localizedTestApp({required Widget home}) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
