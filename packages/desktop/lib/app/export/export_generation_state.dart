part of '../desktop_shell.dart';

extension _DesktopShellExportGenerationState on _DesktopShellState {
  void _markGenerationStarted() {
    _setShellState(() {
      generating = true;
      generated = false;
      exported = false;
      exportResult = null;
      statusMessage = AppLocalizations.of(context)!.generateExportS662;
    });
    _appendLog('开始生成，当前选中 ${selectedAssets.length} 张素材');
  }

  void _applyGenerationResult(CreateBookJobResultDto result) {
    _setShellState(() {
      generating = false;
      generated = result.generated;
      jobId = result.jobId.isNotEmpty ? result.jobId : null;
      statusMessage = generated
          ? AppLocalizations.of(context)!.exportGenerationStateS736
          : (result.messageValue.isNotEmpty
                ? result.messageValue
                : AppLocalizations.of(context)!.exportGenerationStateS730);
    });
    _appendLog(generated ? '生成完成，已获得 jobId: $jobId' : AppLocalizations.of(context)!.exportGenerationStateS730);
  }

  void _applyGenerationError(Object error) {
    final message = '生成异常：$error';
    _setShellState(() {
      generating = false;
      generated = false;
      statusMessage = message;
    });
    _appendLog(message);
  }
}
