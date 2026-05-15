part of '../desktop_shell.dart';

extension _DesktopShellReadinessChecks on _DesktopShellState {
  SetupCheckVm _setupCheck({
    required String index,
    required String title,
    required String body,
    required String action,
    required String state,
    required bool? ok,
    String? secondaryActionLabel,
    String? secondaryActionPath,
  }) {
    return SetupCheckVm(
      index: index,
      title: title,
      body: body,
      action: action,
      state: state,
      ok: ok,
      secondaryActionLabel: secondaryActionLabel,
      secondaryActionPath: secondaryActionPath,
    );
  }

  List<SetupCheckVm> _buildReadinessChecks({
    required ReadinessConfigDto config,
    required ReadinessCheckDto postgres,
    required ReadinessCheckDto pgvector,
    required ReadinessCheckDto openai,
  }) {
    final defaultPaths = _defaultKidMemoryPaths();
    final dataDir = _stringOrDefault(
      config.pathConfig.dataDir,
      defaultPaths.dataDir,
    );
    final workspaceDir = _stringOrDefault(
      config.pathConfig.workspaceDir,
      defaultPaths.workspaceDir,
    );
    final exportDir = _stringOrDefault(
      config.pathConfig.exportDir,
      defaultPaths.exportDir,
    );

    final pgOk = postgres.okOrNull;
    final pgvOk = pgvector.okOrNull;
    // 仅在 sidecar 检测未通过时才做本地检测；widget tests 默认跳过真实 OS 命令。
    final detectLocal =
        widget.localReadinessDetectionEnabled &&
        Platform.environment['FLUTTER_TEST'] != 'true';
    final localPg = pgOk == true || !detectLocal
        ? _PgLocalStatus.unknown
        : _detectPgLocal();
    final localPgv = pgvOk == true || !detectLocal
        ? _PgvectorLocalStatus.unknown
        : _detectPgvectorLocal();

    final (pgAction, pgState) = _pgActionAndState(pgOk, localPg);
    final (pgvAction, pgvState) = _pgvectorActionAndState(
      pgvOk,
      pgOk,
      localPgv,
    );

    final checks = [
      _setupCheck(
        index: '1',
        title: 'PostgreSQL 配置',
        body: '为 KidMemory 提供核心数据库连接，保存孩子资料、素材和生成历史。',
        action: pgAction,
        state: pgState,
        ok: pgOk,
      ),
      _setupCheck(
        index: '2',
        title: _sidecarSetupTitle,
        body: '负责配置检测、数据库初始化、素材导入和生成任务。',
        action: '重新连接',
        state: '已启动',
        ok: true,
      ),
      _setupCheck(
        index: '3',
        title: 'pgvector 检测',
        body: 'pgvector 是 PostgreSQL 的独立扩展，需单独安装并在数据库中启用。',
        action: pgvAction,
        state: pgvState,
        ok: pgvOk,
      ),
      _setupCheck(
        index: '4',
        title: 'OpenAI-compatible API',
        body: _openAiReadinessDescription(config, openai),
        action: '配置',
        state: _readinessState(openai),
        ok: openai.okOrNull,
      ),
      _setupCheck(
        index: '5',
        title: '本地数据目录',
        body: _localDataDirectoryDescription((
          dataDir: dataDir,
          workspaceDir: workspaceDir,
          exportDir: exportDir,
        )),
        action: '配置目录',
        state: '已配置',
        ok: true,
        secondaryActionLabel: '打开目录',
        secondaryActionPath: dataDir,
      ),
    ];
    return _applySequentialSetupLocks(checks);
  }

  (String, String) _pgActionAndState(bool? pgOk, _PgLocalStatus local) {
    if (pgOk == true) return ('重新检测', '正常');

    return switch (local) {
      _PgLocalStatus.notInstalled => ('安装 PostgreSQL', '未安装'),
      _PgLocalStatus.installedNotRunning => ('启动 PostgreSQL 服务', '未启动'),
      _PgLocalStatus.running => ('配置 PostgreSQL 数据库', '待配置'),
      _PgLocalStatus.unknown => ('安装与配置', '需处理'),
    };
  }

  (String, String) _pgvectorActionAndState(
    bool? pgvOk,
    bool? pgOk,
    _PgvectorLocalStatus local,
  ) {
    if (pgvOk == true) return ('重新检测', '正常');
    if (pgOk != true) return ('先完成上方 PostgreSQL 配置', '等待 PG');

    return switch (local) {
      _PgvectorLocalStatus.notInstalled => ('安装 pgvector', '未安装'),
      _PgvectorLocalStatus.installed => ('安装与配置', '待启用'),
      _PgvectorLocalStatus.unknown => ('安装与配置', '需处理'),
    };
  }
}
