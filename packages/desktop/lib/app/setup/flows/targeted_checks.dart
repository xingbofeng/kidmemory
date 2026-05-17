part of '../../desktop_shell.dart';

extension _DesktopShellSetupTargetedChecks on _DesktopShellState {
  Future<void> _runTargetedSetupCheck(String checkTitle) async {
    _appendLog('手动触发配置检测：$checkTitle');
    final checkResult = await (() async {
      switch (checkTitle) {
        case 'PostgreSQL 配置':
          return await gateway.checkPostgresDto();
        case _sidecarSetupTitle:
          final ready = await _sidecarApiReady();
          return ReadinessCheckDto.fromJson({
            'ok': ready,
            'message': ready ? 'Sidecar 已连接' : 'Sidecar 未连接',
          });
        case 'pgvector 检测':
          return await gateway.checkPgvectorDto();
        case '大模型接口配置':
          return await gateway.checkOpenAiDto();
        default:
          return ReadinessCheckDto.fromJson(const {});
      }
    })();
    final message = checkResult.message ?? '';
    if (checkResult.okOrNull == null && message.isEmpty) {
      _showSnackBar('检测请求已发出，但 sidecar 未返回结果');
    } else {
      final success = checkResult.okOrNull == true;
      final displayMessage = message.trim().isEmpty
          ? (success ? '测试连接成功' : '测试连接失败')
          : message.trim();
      _showSnackBar(success ? displayMessage : '测试连接失败：$displayMessage');
    }
    await refreshReadiness();
  }
}
