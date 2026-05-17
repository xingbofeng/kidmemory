part of '../../desktop_shell.dart';

extension _DesktopShellSetupActions on _DesktopShellState {
  void _runSetupAction(SetupCheckVm check) {
    final action = check.action.trim();
    final isOpenAiConfig = check.title == '大模型接口配置';
    final allowOpenAiConfigWhenBlocked =
        isOpenAiConfig && action.contains('配置');
    if (!check.actionEnabled) {
      if (allowOpenAiConfigWhenBlocked) {
        unawaited(_configureOpenAI());
        return;
      }
      _showSnackBar('请先完成上一步配置');
      return;
    }
    if (action == '刷新检测') {
      unawaited(refreshReadiness());
      return;
    }
    if (action.contains('测试') || action.contains('检测')) {
      unawaited(_runTargetedSetupCheck(check.title));
      return;
    }
    if (action.contains('安装')) {
      unawaited(_runInstallAndConfigure(check.title));
      return;
    }
    if (action.contains('启动')) {
      if (check.title == 'PostgreSQL 配置') {
        unawaited(_runPostgresSetupWorkflow());
        return;
      }
      if (check.title == _sidecarSetupTitle) {
        unawaited(_runSidecarSetupWorkflow());
        return;
      }
      _showSnackBar('暂不支持自动启动：${check.title}');
      return;
    }
    if (action.contains('目录')) {
      if (check.title == '本地数据目录') {
        unawaited(_selectLocalDataRoot());
        return;
      }
      _showSnackBar('这个目录项暂时不能在桌面端修改');
      return;
    }
    if (action.contains('配置')) {
      if (check.title == 'PostgreSQL 配置') {
        unawaited(_runPostgresSetupWorkflow());
        return;
      }
      switch (check.title) {
        case '大模型接口配置':
          unawaited(_configureOpenAI());
          return;
        case '本地数据目录':
          unawaited(_selectLocalDataRoot());
          return;
        default:
          _showSnackBar('这个配置项暂无弹窗配置');
      }
      return;
    }
    _showSnackBar('配置项“${check.title}”已记录，稍后继续检测');
  }

  Future<void> _runInstallAndConfigure(String checkTitle) async {
    switch (checkTitle) {
      case 'PostgreSQL 配置':
        await _runPostgresSetupWorkflow();
        return;
      case _sidecarSetupTitle:
        await _runSidecarSetupWorkflow();
        return;
      case 'pgvector 检测':
        await _runPgvectorSetupWorkflow();
        return;
      default:
        _showSnackBar('这个配置项暂无自动安装流程');
    }
  }
}
