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
        case 'OpenAI-compatible API':
          return await gateway.checkOpenAiDto();
        default:
          return const ReadinessCheckDto(raw: {});
      }
    })();
    if (checkResult.okOrNull == null && checkResult.message.isEmpty) {
      _showSnackBar('检测请求已发出，但 sidecar 未返回结果');
    }
    await refreshReadiness();
  }
}
