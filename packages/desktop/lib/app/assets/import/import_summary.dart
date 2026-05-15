part of '../../desktop_shell.dart';

extension _DesktopShellImportSummary on _DesktopShellState {
  AssetImportReport _summarizeImport(
    ImportAssetsResultDto result, {
    int fallbackImportedCount = 0,
  }) {
    if (!result.hasCounters && result.message.isEmpty) {
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

    final message = result.message.isNotEmpty
        ? result.message
        : (result.failedReasons.isEmpty
            ? null
            : '成功 ${result.imported} · 重复 ${result.duplicates} · 跳过 ${result.skipped} · 失败 ${result.failed}：${result.failedReasons.join('、')}');
    return AssetImportReport(
      imported: result.imported,
      duplicates: result.duplicates,
      failed: result.failed,
      skipped: result.skipped,
      message: message ?? '',
      title: result.title,
    );
  }
}
