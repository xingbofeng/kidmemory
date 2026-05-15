part of '../desktop_shell.dart';

extension _DesktopShellExportGenerationState on _DesktopShellState {
  void _markGenerationStarted() {
    _setShellState(() {
      generating = true;
      generated = false;
      exported = false;
      exportResult = null;
      statusMessage = '正在调用 Claude Agent 生成作品集';
    });
    _appendLog('开始生成，当前选中 ${selectedAssets.length} 张素材');
  }

  void _applyGenerationResult(CreateBookJobResultDto result) {
    _setShellState(() {
      generating = false;
      generated = result.generated;
      jobId = result.jobId.isNotEmpty ? result.jobId : null;
      statusMessage = generated
          ? '生成完成，可预览并导出 PDF'
          : (result.message.isNotEmpty ? result.message : '生成失败，请检查 sidecar 日志');
    });
    _appendLog(
      generated ? '生成完成，已获得 jobId: $jobId' : '生成失败，请检查 sidecar 日志',
    );
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
