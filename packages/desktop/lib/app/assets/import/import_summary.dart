part of '../../desktop_shell.dart';

extension _DesktopShellImportSummary on _DesktopShellState {
  AssetImportReport _summarizeImport(
    ImportAssetsResultDto result, {
    int fallbackImportedCount = 0,
  }) {
    if (!result.hasCounters && result.messageValue.isEmpty) {
      if (fallbackImportedCount > 0) {
        return AssetImportReport(
          title: '导入完成',
          imported: fallbackImportedCount,
          duplicates: 0,
          failed: 0,
          skipped: 0,
          message: '素材库已刷新，新增 $fallbackImportedCount 项；sidecar 未返回完整导入统计',
        );
      }
      return const AssetImportReport(
        title: '导入结果未返回',
        imported: 0,
        duplicates: 0,
        failed: 0,
        skipped: 0,
        message: '没有收到 sidecar 导入统计，请检查本地服务状态',
      );
    }

    final message = result.messageValue.isNotEmpty
        ? result.messageValue
        : (result.failedReasons.isEmpty
            ? null
            : '成功 ${result.importedCount} · 重复 ${result.duplicatesCount} · 跳过 ${result.skippedCount} · 失败 ${result.failedCount}：${result.failedReasons.join('、')}');
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
