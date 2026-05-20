part of '../../desktop_shell.dart';

extension _DesktopShellSetupStorageTest on _DesktopShellState {
  Future<void> _testSupabaseStorage() async {
    if (!supabaseStorage.configured || supabaseStorage.testing) {
      _showSnackBar(AppLocalizations.of(context)!.setupConfigureStorageFirst);
      return;
    }
    _setShellState(() {
      supabaseStorage = supabaseStorage.copyWith(
        testing: true,
        testMessage: AppLocalizations.of(context)!.setupTestingConnection,
      );
    });
    final result = await gateway.testSupabaseStorageDto();
    if (!mounted) return;
    final cleanupMessage = result.cleanupOk
        ? ''
        : AppLocalizations.of(context)!.setupTestCleanupFailedSuffix;
    final message = result.okValue
        ? AppLocalizations.of(context)!.setupStorageTestPassed(cleanupMessage)
        : (result.messageValue.isNotEmpty
              ? result.messageValue
              : (result.codeValue.isNotEmpty
                    ? result.codeValue
                    : AppLocalizations.of(context)!.setupTestFailed));
    _setShellState(() {
      supabaseStorage = supabaseStorage.copyWith(
        testing: false,
        testMessage: message,
      );
    });
    _showSnackBar(
      result.okValue
          ? message
          : AppLocalizations.of(
              context,
            )!.setupTestConnectionFailedWithMessage(message),
    );
  }
}
