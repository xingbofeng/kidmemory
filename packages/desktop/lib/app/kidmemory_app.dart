import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import 'desktop_shell.dart';

class KidMemoryApp extends StatelessWidget {
  const KidMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'KidMemory',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2faa61)),
        scaffoldBackgroundColor: const Color(0xfffffbf5),
        fontFamily: 'PingFang SC',
        useMaterial3: true,
      ),
      home: const DesktopShell(),
    );
  }
}
