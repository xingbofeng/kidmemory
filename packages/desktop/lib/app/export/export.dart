part of '../desktop_shell.dart';

extension _DesktopShellExportFlow on _DesktopShellState {
  Future<void> generateBook({bool skipCover = false}) async {
    desktopTraceContext.beginAction();
    final nextTraceId = desktopTraceContext.traceId;
    final nextRequestId = desktopTraceContext.nextRequestId();
    api.setRequestContext(traceId: nextTraceId, requestId: nextRequestId);
    _setShellState(() {
      traceId = nextTraceId;
      requestId = nextRequestId;
    });
    unawaited(
      desktopLogger.append(
        level: DesktopLogLevel.info,
        event: 'desktop.action.generate_book',
        traceId: nextTraceId,
        requestId: nextRequestId,
        data: {
          'selectedCount': selectedAssets.length,
          'childId': selectedChildId,
          'coverPolicy': skipCover ? 'skip' : 'auto',
        },
      ),
    );
    _markGenerationStarted();
    try {
      final result = await gateway.createBookJobDto(
        payload: CreateBookJobRequest(
          assetIds: selectedAssets.toList(),
          childId: selectedChildId,
          coverPolicy: skipCover ? 'skip' : 'auto',
        ),
      );
      if (!mounted) return;
      _applyGenerationResult(result);
    } catch (error) {
      if (!mounted) return;
      _applyGenerationError(error);
    } finally {
      api.clearRequestContext();
    }
  }

  Future<void> exportPdf() async {
    desktopTraceContext.beginAction();
    final nextTraceId = desktopTraceContext.traceId;
    final nextRequestId = desktopTraceContext.nextRequestId();
    api.setRequestContext(traceId: nextTraceId, requestId: nextRequestId);
    _setShellState(() {
      traceId = nextTraceId;
      requestId = nextRequestId;
    });
    unawaited(
      desktopLogger.append(
        level: DesktopLogLevel.info,
        event: 'desktop.action.export_pdf',
        traceId: nextTraceId,
        requestId: nextRequestId,
        data: {'jobId': jobId, 'target': generationExportTarget},
      ),
    );
    if (jobId == null) {
      _setShellState(() => statusMessage = '请先完成生成，再导出');
      _appendLog('导出失败：缺少 jobId');
      api.clearRequestContext();
      return;
    }
    final target = _exportTargetFromLabel(generationExportTarget);
    final exportLabel = _exportLabel(target);

    _setShellState(() => statusMessage = '正在准备导出目录...');
    _appendLog('点击导出，准备读取当前导出目录');

    final targetDirectoryPath = currentExportDir.trim().isEmpty
        ? _defaultKidMemoryPaths().exportDir
        : currentExportDir.trim();

    try {
      Directory(targetDirectoryPath).createSync(recursive: true);
    } catch (error) {
      if (!mounted) return;
      _setShellState(() => statusMessage = '创建导出目录失败：$error');
      _appendLog('创建导出目录失败：$error');
      return;
    }
    final destinationPath = _buildExportTargetPath(
      targetDirectoryPath,
      _exportFileNameForJob(jobId!, target),
    );
    _setShellState(() => statusMessage = '正在导出到 $destinationPath');
    _appendLog('准备导出到 $destinationPath');
    try {
      final result = await gateway.exportBookDto(
        payload: ExportBookRequest(
          jobId: jobId!,
          targetPath: destinationPath,
          format: target == _ExportTarget.pdf
              ? 'pdf'
              : (target == _ExportTarget.longImageJpg ? 'jpg' : 'png'),
        ),
      );
      if (!mounted) return;
      final exportedOk = result.exported.ok;
      final actualPath = result.exported.path.trim().isNotEmpty
          ? result.exported.path
          : destinationPath;
      final syncedResult = exportedOk
          ? await _maybeSyncExportArtifact(result.artifactId)
          : _ExportSyncResult.localOnly();
      if (!mounted) return;
      _applyExportResultState(
        target: target,
        exportLabel: exportLabel,
        exportedOk: exportedOk,
        actualPath: actualPath,
        syncedResult: syncedResult,
        exportedMessage: result.exported.message,
      );
      _appendLog(
        exportedOk ? '$exportLabel 导出成功：$actualPath' : '$exportLabel 导出失败',
      );
    } catch (error) {
      if (!mounted) return;
      final message = '$exportLabel 导出异常：$error';
      _applyExportExceptionState(target: target, message: message);
      _appendLog(message);
    } finally {
      api.clearRequestContext();
    }
  }
}
