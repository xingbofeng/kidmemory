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
    required ReadinessCheckDto openai,
  }) {
    final paths = _defaultKidMemoryPaths();
    final checks = [
      _setupCheck(
        index: '1',
        title: '大模型接口配置',
        body: _openAiReadinessDescription(),
        action: '测试连接',
        secondaryActionLabel: '修改配置',
        secondaryActionPath: '__action__:配置',
        state: _readinessState(openai),
        ok: openai.okOrNull,
      ),
      _setupCheck(
        index: '2',
        title: '本地数据目录',
        body: _localDataDirectoryDescription(paths),
        action: '配置目录',
        state: '已配置',
        ok: true,
        secondaryActionLabel: '打开目录',
        secondaryActionPath: paths.dataDir,
      ),
    ];
    return _applySequentialSetupLocks(checks);
  }
}
