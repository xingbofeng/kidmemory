part of '../desktop_shell.dart';

extension _DesktopShellReadiness on _DesktopShellState {
  Future<void> refreshReadiness() async {
    try {
      final snapshot = await controllers.readiness.load();
      final loadedUiConfig = _parseUiConfig(snapshot.uiConfig);
      _applyReadinessUiConfig(loadedUiConfig);

      if (!snapshot.available) {
        _markSidecarUnavailable('读取 sidecar 配置失败，初始化未完成。');
        return;
      }
      _applyReadinessStorageAndPaths(snapshot.config);

      if (!mounted) return;
      final checks = [snapshot.postgres, snapshot.pgvector, snapshot.openai];
      final readyCount = checks.where((check) => check.isOk).length;
      final schemaReady = snapshot.schema.isOk;
      if (!schemaReady) {
        final message = snapshot.schema.message.isNotEmpty
            ? snapshot.schema.message
            : 'schema 初始化未成功';
        _appendLog('schema 初始化未完成：$message');
      }
      _setShellState(() {
        readinessMessage = schemaReady
            ? '初始化成功，已完成 $readyCount / 3 项 readiness 检测'
            : 'Sidecar 已启动，schema 初始化未完成';
        readinessChecks = _buildReadinessChecks(
          config: snapshot.config,
          postgres: snapshot.postgres,
          pgvector: snapshot.pgvector,
          openai: snapshot.openai,
        );
        _applyStartupConfigurationGate(
          needsConfiguration: !schemaReady || _needsStartupConfiguration(checks: checks),
        );
      });
      if (schemaReady) {
        await refreshDataset();
      }
    } catch (error) {
      debugPrint('KidMemory readiness refresh failed: $error');
      _markSidecarUnavailable('初始化失败：$error');
      return;
    }
  }

}
